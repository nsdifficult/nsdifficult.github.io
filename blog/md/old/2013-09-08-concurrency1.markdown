# iOS中并发编程之GCD（一）

##概述  
  
   Grand Central Dispatch(GCD)包含了语言特点，运行时库，和系统增强特点以支持系统级别的，综合的提高。从而支持在iOS或OS X的多核硬件上并行代码的执行。<!--more-->   
     
   BSD子系统，核心框架，和Cocoa APIs都被扩展来使用这些增强去帮助包括系统和你的应用去运行的更快，更高效，和提高响应速度。考虑下一个单个应用在不同多个计算核心上如何更高效的使用多核，或多个应用应如何竞争多核心吧。GCD，可以在系统级别上运行来更好的使这些正在运行的应用的需求以一种平衡的状态来匹配这些可用的系统资源。  
      
   这个文档描述了支持了在Unix系统级别异步运行的GCD技术的API。你可以使用GCD API去管理与文件描述符的交互，端口、信号量、定时器的匹配。在OS X v10.7及以上版本，你可以使用GCD去处理一般目的操作文件描述符的异步I/O操作。   
      
   GCD并不限于在系统级别应用上使用，但在你用之于更高级别应用前应考虑类似功能的由Cocoa的功能的技术（如[NSOperation](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/NSOperation_class/Reference/Reference.html#//apple_ref/occ/cl/NSOperation)和block对象），这些技术可能更适合你的需求。更多信息可以看[Concurrency Programming Guide](https://developer.apple.com/library/ios/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008091)。    
      
##功能   
      
###创建和管理队列    
```
dispatch_get_global_queue   

dispatch_get_main_queue   

dispatch_queue_create   

dispatch_get_current_queue   

dispatch_queue_get_label   

dispatch_set_target_queue   

dispatch_main   
```   

###dispatch_queue_create

创建一个新的调度队列。   

```
dispatch_queue_t dispatch_queue_create(
   const char *label
   dispatch_queue_attr_t attr);
```

dispatch_queue_attr_t attr解释： 
>In OS X v10.7 and later, specify DISPATCH_QUEUE_SERIAL (or NULL) to create a serial queue or specify DISPATCH_QUEUE_CONCURRENT to create a concurrent queue. In earlier versions of OS X, you must specify NULL for this parameter. 

即在OS X v10.7之后，传入NULL/DISPATCH_QUEUE_SERIAL可创建一个串行的任务调度队列，传入 DISPATCH_QUEUE_CONCURRENT创建一个并发的任务调度队列。在之前系统版本(<OS X v10.7)只能传入NULL。

###为调度查询任务（Queuing Tasks for Dispatch）  
GCD为应用程序可以以block对象的方式提交任务而提供先进先出（FIFO）的队列并负责管理。提交给调度队列的block形式的任务在由系统管理的线程池上执行。没法保证任务在哪一个线程上执行。GCD提供三种队列：   
   
   
* **Main（主线程）**： 任务在程序主线程上顺序执行   
* **Concurrent（同步/并发）**： 任务以先进先出（FIFO）的顺序出列，但同步/并发执行且可能以任何顺序执行完成
* **Serial（串行）**：以FIFO的方式每次执行一个任务，这个串行任务队列在主线程之外的另一个线程（Thread）执行任务。   
   
**Main（主线程）**    


系统会自动创建主队列且关联程序的主线程。程序中使用一种且只能使用一种下面三种方式之一去调用blocks给主队列提交任务： 
   
   
1. 调用 dispatch_main  
2. 调用 UIApplicationMain (iOS) 或者 NSApplicationMain (OS X)   
3. 在主线程（main thread）使用一个CFRunLoopRef   
   
   
**Concurrent（同步/并发）**    

使用同步/并发队列可以同步/并发执行大量任务。GCD为程序自动创建三个全局的同步/并发调度对列，他们的唯一区别就是优先级不同。你的程序使用dispatch_get_global_queue函数来请求使用这些队列。你不需要去retain或者release这些队列，因为这些同步/并发队列对于你的程序来说是全局的。在OS X v10.7及以后，你还可以在你自己的代码模块中创建额外的同步/并发队列。   
    
**Serial（串行）**    

使用串行（serial）队列可以保证任务以期望的串行执行。去为每一个串行队列标明一个特殊目的是一个好的代码实践，比如为了保护资源或者同步关键步骤。你的程序必须显示创建并管理这些串行队列。如果必须你可以创建这些串行队列，但应避免使用它们，而是使用同步/并发队列去执行一些同步/并发的任务。   
这个串行任务队列在主线程之外的另一个线程执行任务。且你可以创建很多串行任务队列，但每个队列同一时间只执行一个任务。  

>The currently executing task runs on a distinct thread (which can vary from task to task) that is managed by the dispatch queue.

> 重要：GCD是一个C语言级别的API，它不能捕捉任何高级别语言的异常。你的程序必须在异常返回给调度队列前捕捉所有异常。   
   
以上`总结自`：[Grand Central Dispatch (GCD) Reference](https://developer.apple.com/library/ios/documentation/Performance/Reference/GCD_libdispatch_Ref/Reference/reference.html)
      
##创建和管理   

###获取全局同步/并发调度队列    
    
系统给每个应用提供三个并发 dispatch queue,所有应用全局共享,三个 queue 的区别是优先级。你不需要显式地创建这些 queue,使
用 dispatch_get_global_queue 函数来获取这三个 queue:    

  
```
dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
```      

除了默认优先级的并发 queue,你还可以获得高和低优先级的两个,分别使 用 DISPATCH_QUEUE_PRIORITY_HIGH 和 DISPATCH_QUEUE_PRIORITY_LOW 常量 来调用上面函数。   

虽然 dispatch queue 是引用计数的对象,但你不需要 retain 和 release 全局并 发 queue。因为这些 queue 对应用是全局的,retain 和 release 调用会被忽略。   


你也不需要存储这三个 queue 的引用,每次都直接调 用 dispatch_get_global_queue 获得 queue 就行了。  

###创建串行调度队列   
   
应用的任务需要按特定顺序执行时,就需要使用串行 Dispatch Queue,串行 queue 每次只能执行一个任务。你可以使用串行 queue 来替代锁,保护共享资源 或可变的数据结构。和锁不一样的是,串行 queue 确保任务按可预测的顺序执行。 而且只要你异步地提交任务到串行 queue,就永远不会产生死锁。    

你必须显式地创建和管理所有你使用的串行 queue,应用可以创建任意数量 的串行 queue,但不要为了同时执行更多任务而创建更多的串行 queue。如果你 需要并发地执行大量任务,应该把任务提交到全局并发 Queue。   

创建串行 queue 时,你需要明确自己的目的,如保护共享资源,或同步应用 的某些关键行为。  
 
dispatch_queue_create 函数创建串行 queue,两个参数分别是 queue 名和一 组 queue 属性。调试器和性能工具会显示 queue 的名字,便于你跟踪任务的执 行。   
  
```
dispatch_queue_t queue;

queue = dispatch_queue_create("com.example.MyQueue", NULL);
```
###在运行时获取公共队列  
 
1. 使用 dispatch_get_current_queue 函数作为调试用途,或者测试当前 queue 的标识。在 block 对象中调用这个函数会返回 block 提交到的 queue (这个时候 queue 应该正在执行中)。在 block 对象之外调用这个函数会 返回应用的默认并发 queue。   
2. 使用 dispatch_get_main_queue 函数获得应用主线程关联的串行 dispatch queue。Cocoa 应用、调用了 dispatch_main 函数或配置了 run loop (CFRunLoopRef 类型 或一个 NSRunLoop 对象)的应用,会自动创建这 个 queue。   
3. 使用 dispatch_get_global_queue 来获得共享的并发 queue
##添加任务到队列  

要执行一个任务,你需要将它 dispatch 到一个适当的 dispatch queue,你可 以同步或异步地 dispatch 一个任务,也可以单个或按组来 dispatch。一旦进入到 queue,queue 会负责尽快地执行你的任务。  
### 添加单个任务到队列
  
你可以异步或同步地添加一个任务到 Queue。
     
```

		dispatch_queue_t myCustomQueue;
        myCustomQueue = dispatch_queue_create("com.example.MyCustomQueue", NULL);
        dispatch_async(myCustomQueue, ^{
            printf("Do some work here.\n");
        });
        printf("The first block may or may not have run.\n");
        dispatch_sync(myCustomQueue, ^{
            printf("Do some more work here.\n");
        });
        
        printf("Both blocks have completed.\n");
        
```   

###并发执行循环迭代（Performing Loop Iterations Concurrently）  
如果每次迭代执行的任务与其它迭代独立无关,而且循环迭代执行顺序也无 关紧要的话,你可以调用dispatch_apply 或 dispatch_apply_f 函数来替换循环。

```
		for (unsigned int i = 0; i < 100; i++) {
            printf("%u\n",i);
        }
        //下面与上面for循环等价
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        static const int Length = 100;
        dispatch_apply(Length, queue, ^(size_t i) {
            printf("%u\n",i);
        });
```

>绝对不要在任务中调用 dispatch_sync 或 dispatch_sync_f 函数,并同步 dispatch 新任务到当前正在执行的 queue。对于串行 queue 这一点特别重要,因 为这样做肯定会导致死锁;而并发 queue 也应该避免这样做。   

###使用Dispatch Semaphore控制有限资源的使用  

使用 dispatch semaphore 的过程如下:

1. 使用 dispatch_semaphore_create 函数创建 semaphore,指定正数值表示资源的可用数量.
2. 在每个任务中,调用 dispatch_semaphore_wait 来等待 Semaphore
3. 当上面调用返回时,获得资源并开始工作
4. 使用完资源后,调用 dispatch_semaphore_signal 函数释放和 signal 这个semaphore

信号量的例子

```
// Create the semaphore, specifying the initial pool size
dispatch_semaphore_t fd_sema = dispatch_semaphore_create(getdtablesize() / 2);
// Wait for a free file descriptor
dispatch_semaphore_wait(fd_sema, DISPATCH_TIME_FOREVER);
fd = open("/etc/services", O_RDONLY);
// Release the file descriptor when done
close(fd);
dispatch_semaphore_signal(fd_sema);
``` 

当你创建信号量时需要指定可用资源数量。这个值成为了信号量的初始的变量。每次你等待信号量时，dispatch_semaphore_wait会将该变量减一。如果变量结果为负，该函数会告诉内核阻塞你的线程。另一方面，dispatch_semaphore_signal函数会将该变量加1来表示线程释放了该资源。如果有其他线程在等待该资源，它们中的一个会停止被阻塞并执行。   

###等待队列中的组任务  

Dispatch group 用来阻塞一个线程,直到一个或多个任务完成执行。  
基本的流程是设置一个组,dispatch 任务到 queue,然后等待结果。你需要 使用 dispatch_group_async 函数,会关联任务到相关的组和 queue。使用 dispatch_group_wait 等待一组任务完成。  

```
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_group_t group = dispatch_group_create();
        
        dispatch_block_t task1 = ^(void) {
            
            NSLog(@"task1 run");
            
        };
        dispatch_block_t task2 = ^(void) {
            
            NSLog(@"task2 run");
            
        };
        // Add a task to the group
        dispatch_group_async(group, queue, task1);
        dispatch_group_async(group, queue, task2);
                
        // Do some other work while the tasks execute.
        
        // When you cannot make any more forward progress,
        
        // wait on the group to block the current thread.
        NSLog(@"Do some other work while the tasks execute.");
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        NSLog(@" end");
        // Release the group when it is no longer needed.
```   

运行结果：  


```
2013-10-11 17:29:27.131 CMD[4667:1303] task2 run
2013-10-11 17:29:27.131 CMD[4667:303] Do some other work while the tasks execute.
2013-10-11 17:29:27.131 CMD[4667:1203] task1 run
2013-10-11 17:29:27.134 CMD[4667:303]  end   
```



以上`总结自`：[Concurrency Programming Guide之Dispatch Queues](https://developer.apple.com/library/ios/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html#//apple_ref/doc/uid/TP40008091-CH102-SW1)  

另外两篇文章：  
 
1. [深入浅出Cocoa多线程编程之 block 与 dispatch quene](http://www.cppblog.com/kesalin/archive/2011/08/26/154411.html)
2. [使用GCD](http://blog.devtang.com/blog/2012/02/22/use-gcd/)