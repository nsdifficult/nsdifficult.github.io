# iOS中并发编程之Operation Queues（二）
##简介
Operation Queue是 concurrent dispatch queue在Cocoa上的同等实现，由NSOperationQueue类实现。不同于dispatch queues的FIFO运行方式，Operation Queues中的任务执行顺序也会考虑其他因素，其中主要考虑任务的依赖性。你在创建任务时需要定义其依赖性来实现复杂的任务执行顺序图。<!--more-->  

你提交给Operation Queue的任务必须是NSOperation的实例，这是一个Objective-C的对象，它是一个基类，但Foundation Framework也包括了一些其子类以供开发者使用。 
 
Operation对象实现了KVO协议以方便开发者监控任务的执行进程。虽然 operation queue 总是并发地执行任务,你 可以使用依赖,在需要时确保顺序执行。  
##Operation Objects介绍
类 | 描述 
------------ | -------------
NSInvocationOperation | 可以直接使用的类,基于应用的一个对象和 selector 来创 建 operation object。如果你已经有现有的方法来执行需要 的任务,就可以使用这个类。
NSBlockOperation | 可以直接使用的类,用来并发地执行一个或多个 block 对 象。operation object 使用“组”的语义来执行多个 block 对 象,所有相关的 block 都执行完成之后,operation object 才算完成。
NSOperation | 基类,用来自定义子类 operation object。继承 NSOperation 可以完全控制 operation object 的实现,包括修改操作执 行和状态报告的方式。

####所有 operation objects 都支持以下关键特性:

* 支持建立基于图的operation objects依赖。可以阻止某个operation 运行,直到它依赖的所有 operation 都已经完成。
* 支持可选的 completion block,在 operation 的主任务完成后调用。
* 支持应用使用 KVO 通知来监控 operation 的执行状态。
* 支持 operation 优先级,从而影响相对的执行顺序
* 支持取消,允许你中止正在执行的任务


##并发VS非并发Operations

通常我们通过将operation添加到operation queue中来执行该操作。但是我们也可以手动调用start方法来执行一个operation对象,这样做不保证operation会并发执行。NSOperation类对象的isConcurrent方法告诉你这个operation相对于调用start方法的线程,是同步还是异步执行的isConcurrent方法默认返回NO,表示operation与调用线程同步执行。   


如果你需要实现并发operation,也就是相对调用线程异步执行的操作。你必须添加额外的代码,来异步地启动操作。例如生成一个线程、调用异步系统函数,以确保start方法启动任务,并立即返回。   


多数开发者从来都不需要实现并发operation对象,我们只需要将operations添加到operation queue。当你提交非并发operation到operation queue时,queue会创建线程来运行你的操作,因此也能达到异步执行的目的。只有你不希望使用operation queue来执行operation时,才需要定义并发operations。

##创建一个 NSInvocationOperation 对象

如果已经先有一个方法,需要并发地执行,就可以直接创建 NSInvocationOperation 对象,而不需要自己继承 NSOperation。   
NSInvocationOpertaion例子：

```
@implementation MyCustomClass

- (NSOperation*)taskWithData:(id)data {

    NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self

                    selector:@selector(myTaskMethod:) object:data];

 

   return theOp;

}

 

// This is the method that does the actual work of the task.

- (void)myTaskMethod:(id)data {

    // Perform the task.

}

@end
```


##创建一个 NSBlockOperation 对象

NSBlockOperation 对象用于封装一个或多个 block 对象,一般创建时 会添加至少一个 block,然后再根据需要添加更多的 block。
当 NSBlockOperation 对象执行时,会把所有 block 提交到默认优先级的 并发 dispatch queue。然后 NSBlockOperation 对象等待所有 block 完成 执行,最后标记自己已完成。因此可以使用 block operation 来跟踪一组 执行中的 block,有点类似于 thread join 等待多个线程的结果。区别在于 block operation 本身也运行在一个单独的线程,应用的其它线程在等
待 block operation 完成时可以继续工作。

```
NSBlockOperation* theOp = [NSBlockOperation blockOperationWithBlock: ^{

      NSLog(@"Beginning operation.\n");

      // Do some work.

   }];
```



使用 addExecutionBlock: 可以添加更多 block 到这个 block operation 对象。如果需要顺序地执行 block,你必须直接提交到所需的 dispatch queue。


##自定义Operation对象

如果 block operation 和 invocation operation 对象不符合应用的需求, 你可以直接继承 NSOperation,并添加任何你想要的行为。NSOperation 类提供通用的子类继承点,而且实现了许多重要的基础设施来处理依赖 和 KVO 通知。继承所需的工作量主要取决于你要实现非并发还是并发的 operation。  

定义非并发 operation 要简单许多,只需要执行主任务,并正确地响 应取消事件;NSOperation 处理了其它所有事情。对于并发 operation, 你必须替换某些现有的基础设施代码。

```
@interface MyNonConcurrentOperation : NSOperation

@property id (strong) myData;

-(id)initWithData:(id)data;

@end

 

@implementation MyNonConcurrentOperation

- (id)initWithData:(id)data {

   if (self = [super init])

      myData = data;

   return self;

}

 

-(void)main {

   @try {

      // Do some work on myData and report the results.

   }

   @catch(...) {

      // Do not rethrow exceptions.

   }

}

@end
```

###响应取消事件

operation开始执行之后,会一直执行任务直到完成,或者显式地取消操作。取消可能在任何时候发生,甚至在operation执行之前。尽管NSOperation提供了一个方法,让应用取消一个操作,但是识别出取消事件则是你的事情。如果operation直接终止,可能无法回收所有已分配的内存或资源。因此operation对象需要检测取消事件,并优雅地退出执行。   

operation对象定期地调用isCancelled方法,如果返回YES(表示已取消),则立即退出执行。不管是自定义NSOperation子类,还是使用系统提供的两个具体子类,都需要支持取消。isCancelled方法本身非常轻量,可以频繁地调用而不产生大的性能损失。以下地方可能需要调用isCancelled:

* 在执行任何实际代码工作之前
* 在循环的每次迭代过程中,如果每个迭代相对较长可能需要调用多次
* 代码中相对比较容易中止操作的任何地方   

```
- (void)main {

   @try {
      BOOL isDone = NO;
      while (![self isCancelled] && !isDone) {
          // Do some work and set isDone to YES when finished
      }
   }
   @catch(...) {
      // Do not rethrow exceptions.
   }
}
	}
}
```



##为并发执行配置operations

Operation对象默认按同步方式执行,也就是在调用 start 方法的那 个线程中直接执行。由于 operation queue 为非并发operation提供了线 程支持,对应用来说,多数 operations 仍然是异步执行的。但是如果你 希望手工执行 operations,而且仍然希望能够异步执行操作,你就必须 采取适当的措施,通过定义 operation 对象为并发操作来实现:

方法 | 描述 
------------ | -------------
start | (必须)所有并发操作都必须覆盖这个方法,以自定义的实现替换 默认行为。手动执行一个操作时,你会调用 start 方法。因此你对这 个方法的实现是操作的起点,设置一个线程或其它执行环境,来执 行你的任务。你的实现在任何时候都绝对不能调用 super。
main | (可选)这个方法通常用来实现 operation 对象相关联的任务。尽管 你可以在 start 方法中执行任务,使用 main 来实现任务可以让你的 代码更加清晰地分离设置和任务代码
isExecuting isFinished |(必须)并发操作负责设置自己的执行环境,并向外部 client 报告 执行环境的状态。因此并发操作必须维护某些状态信息,以知道是 否正在执行任务,是否已经完成任务。使用这两个方法报告自己的 状态。 这两个方法的实现必须能够在其它多个线程中同时调用。另外这些 方法报告的状态变化时,还需要为相应的 key path 产生适当的 KVO 通知。
isConcurrent | (必须)标识一个操作是否并发 operation,覆盖这个方法并返回 YES

定义一个并发线程

```
@interface MyOperation : NSOperation {
    BOOL        executing;
    BOOL        finished;
}
- (void)completeOperation;

@end

@implementation MyOperation

- (id)init {
    self = [super init];
    if (self) {
        executing = NO;
        finished = NO;
    }
    return self;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}

@end
```

即使操作被取消,你也应该通知 KVO observers,你的操作已经完成。 当某个 operation 对象依赖于另一个 operation 对象的完成时,它会监测 后者的 isFinished key path。只有所有依赖的对象都报告已经完成,第一 个 operation 对象才会开始运行。如果你的 operation 对象没有产生完成 通知,就会阻止其它依赖于你的 operation 对象运行。  


###维护KVO依从

NSOperation 类的 key-value observing(KVO)依从于以下 key paths:

*   isCancelled
*   isConcurrent
*   isExecuting
*   isFinished
*   isReady
*   dependencies
*   queuePriority
*   completionBlock

###自定义一个Operation对象的执行行为
对 Operation 对象的配置发生在创建对象之后,将其添加到queue之前。

####配置operation之间的依赖关系

依赖关系可以顺序地执行相关的 operation 对象,依赖于其它操作, 则必须等到该操作完成之后自己才能开始。你可以创建一对一的依赖关 系,也可以创建多个对象之间的依赖图。

使用 NSOperation 的addDependency: 方法在两个operation对象之 间建立依赖关系。表示当前 operation 对象将依赖于参数指定的目标 operation 对象。依赖关系不局限于相同 queue 中的 operations 对象, Operation 对象会管理自己的依赖,因此完全可以在不同的 queue 之间 的 Operation 对象创建依赖关系。

唯一的限制是不能创建环形依赖,这是程序员的错误,所有受影响的 operations 都无法运行!

####修改Operation的执行优先级

对于添加到 queue 的 Operations,执行顺序首先由已入队列的operations 是否准备好,然后再根据所有 operations 的相对优先级确定。是否准备好由对象的依赖关系确定,优先级等级则是 operation 对象本身的一个属性。默认所有 operation 都拥有“普通”优先级,不过你可以通过 setQueuePriority: 方法来提升或降低 operation 对象的优先级。  
优先级只能应用于相同 queue 中的 operations。如果应用有多个 operation queue,每个 queue 的优先级等级是互相独立的。因此不同 queue 中的低优先级操作仍然可能比高优先级操作更早执行。  

优先级不能替代依赖关系,优先级只是 queue 对已经准备好的 operations 确定执行顺序。先满足依赖关系,然后再根据优先级从所有 准备好的操作中选择优先级最高的那个执行。

####修改底层线程的优先级

Mac OS X 10.6 之后,我们可以配置 operation 底层线程的执行优先级, 线程直接由内核管理,通常优先级高的线程会给予更多的执行机会。对 于 operation 对象,你指定线程优先级为 0.0 到 1.0 之间的某个数值,0.0 表示最低优先级,1.0 表示最高优先级。默认线程优先级为 0.5   

要设置 operation 的线程优先级,你必须在将 operation 添加到 queue 之前,调用setThreadPriority: 方法进行设置。当queue执行该operation 时,默认的 start 方法会使用你指定的值来修改当前线程的优先级。不 过新的线程优先级只在 operation 的 main 方法范围内有效。其它所有代 码仍然(包括 completion block)运行在默认线程优先级。

如果你创建了并发 operation,并覆盖了 start 方法,你必须自己配置 线程优先级。

####设置一个completion block

在 Mac OS X 10.6 之后,operation 可以在主任务完成之后执行一个 completion block。你可以使用这个 completion block 来执行任何不属于 主任务的工作。例如你可以使用这个 block 来通知相关的 client,操作已 经执行完成。而并发 operation 对象则可以使用这个 block 来产生最终的 KVO 通知。


##执行Operations

###添加Operations到Operation Queue

执行 Operations 最简单的方法是添加到 operation queue,后者 是 NSOperationQueue 对象。应用负责创建和维护自己使用的所 有 NSOperationQueue 对象。  

注意 Operations 添加到 queue 之后,绝对不要再修改 Operations 对 象。因为 Operations 对象可能会在任何时候运行,因此改变依赖或数据 会产生不利的影响。你只能通过 NSOperation 的方法来查看操作的状态, 是否正在运行、等待运行、已经完成等。  

虽然 NSOperationQueue 类设计用于并发执行 Operations,你也可以 强制单个 queue 一次只能执行一个 Operation。  

setMaxConcurrentOperationCount: 方法可以配置 operation queue 的最 大并发操作数量。设为 1 就表示 queue 每次只能执行一个操作。不过 operation 执行的顺序仍然依赖于其它因素,像操作是否准备好和优先级 等。因此串行化的 operation queue 并不等同于 GCD 中的串行 dispatch queue。  

`setMaxConcurrentOperationCount这个方法只是设置最大并发数，达到最大时仍可继续往queue中添加operation，但会等待。`
 
`加入queue的operation只能取消，不能暂停。`

###手动执行Operations 

手动执行 Operation,要求 Operation 已经准备好,isReady 返回 YES, 此时你才能调用 start 方法来执行它。isReady 方法与 Operations 依赖是 结合在一起的。  
调用 start 而不是 main 来手动执行 Operation,因为 start 在执行你的 自定义代码之前,会首先执行一些安全检查。而且 start 还会产生 KVO通知,以正确地支持 Operations 的依赖机制。start 还能处理 Operations
已经被取消的情况,此时会抛出一个异常。  

手动执行 Operation 对象之前,还需要调用 isConcurrent 方法,如 果返回 NO,你的代码可以决定在当前线程同步执行这个 Operation,或 者创建一个独立的线程以异步执行。   

##取消Operations

`一旦添加到 operation queue,queue 就拥有了这个对象并且不能被 删除,唯一能做的事情是取消。`

你可以调用 Operation 对象的 cancel 方 法取消单个操作,也可以调用 operation queue 的 cancelAllOperations 方 法取消当前 queue 中的所有操作。

##挂起和继续Queue

如果你想临时挂起 Operations 的执行,可以使用 setSuspended: 方 法暂停相应的 queue。不过挂起一个 queue 不会导致正在执行的 Operation 在任务中途暂停,只是简单地阻止调度新 Operation 执行。你 可以在响应用户请求时,挂起一个 queue,来暂停等待中的任务。稍后 根据用户的请求,可以再次调用 setSuspended: 方法继续 Queue 中操作 的执行。

以上`总结自`：[Concurrency Programming Guide之Operation Queues](https://developer.apple.com/library/ios/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationObjects/OperationObjects.html#//apple_ref/doc/uid/TP40008091-CH101-SW1) 