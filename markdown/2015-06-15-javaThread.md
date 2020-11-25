---
layout: post
title: "《Java编程思想》读书笔记之多线程(一)"
date: 2015-06-15 09:06
comments: true
categories: 
---


##线程状态 
new->runnable->running->block->dead<!--more-->   

1. 新建(new)：新创建了一个线程对象。   
2. 可运行(runnable)：线程对象创建后，其他线程(比如main线程）调用了该对象的start()方法。该状态的线程位于可运行线程池中，等待被线程调度选中，获取cpu 的使用权 。   
3. 运行(running)：可运行状态(runnable)的线程获得了cpu 时间片（timeslice） ，执行程序代码。   
4. 阻塞(block)：阻塞状态是指线程因为某种原因放弃了cpu 使用权，也即让出了cpu timeslice，暂时停止运行。直到线程进入可运行(runnable)状态，才有机会再次获得cpu timeslice 转到运行(running)状态。阻塞的情况分三种：   
	a. 等待阻塞：运行(running)的线程执行o.wait()方法，JVM会把该线程放入等待队列(waitting queue)中。
	b. 同步阻塞：运行(running)的线程在获取对象的同步锁时，若该同步锁被别的线程占用，则JVM会把该线程放入锁池(lock pool)中。
	c. 其他阻塞：运行(running)的线程执行Thread.sleep(long ms)或t.join()方法，或者发出了I/O请求时，JVM会把该线程置为阻塞状态。当sleep()状态超时、join()等待线程终止或者超时、或者I/O处理完毕时，线程重新转入可运行(runnable)状态。   
5. 死亡(dead)：线程run()、main() 方法执行结束，或者因异常退出了run()方法，则该线程结束生命周期。死亡的线程不可再次复生。 

##yield()方法   

在run方法中对静态方法`Thread.yield()`的调用是对线程调度器（Java线程机制的一部分，可以将cpu丛一个线程转移到另一个线程）的一种建议，它在声明：“我已经执行完声明周期中最重要的部分了，此刻正是切换给其他任务执行一段是 jain的大好时机。”。   

##如何创建线程   

1. 实现Runnable接口，并将其传入Thread的构造函数，其中run方法中负责执行任务；
2. 继承Thread类。

##使用Executors   
Java SE5的java.util.concurrent包中的Executors将为你管理Thread对象，丛而简化了并发编程。   
Executors提供了一系列工厂方法用于创先线程池，返回的线程池都实现了ExecutorService接口。   

1. public static ExecutorService newFixedThreadPool(int nThreads)   
	创建固定数目线程的线程池。
2. public static ExecutorService newCachedThreadPool()   
	创建一个可缓存的线程池，调用execute将重用以前构造的线程（如果线程可用）。如果现有线程没有可用的，则创建一个新线   程并添加到池中。终止并从缓存中移除那些已有 60 秒钟未被使用的线程。
3. public static ExecutorService newSingleThreadExecutor()    
	创建一个单线程化的Executor。
4. public static ScheduledExecutorService newScheduledThreadPool(int corePoolSize)    
	创建一个支持定时及周期性的任务执行的线程池，多数情况下可用来替代Timer类。
	

##从任务中返回值   
使用Callable接口代替Runnable接口，其call()中为任务代码，且会返回执行结果。但必须使用ExecutorService.submit()方法调用它。   

```java
public class TaskWithResult implements Callable<String>{	
	private int id;
	
	public TaskWithResult(int id) {
		super();
		this.id = id;
	}

	@Override
	public String call() throws Exception {
		return "result of TaskWithResult "+id;
	}

}

public class CallableDemo {

	//从任务中返回值：Callable,call(),submit()
	public static void main(String[] args) {
		ExecutorService exec = Executors.newCachedThreadPool();
		ArrayList<Future<String>> results = new ArrayList<Future<String>>();
		
		for (int i = 0; i < 10; i++) {
			results.add(exec.submit(new TaskWithResult(i)));
		}
		
		for (Future<String> fs: results) {
			try {
				System.out.println(fs.get());
			} catch(InterruptedException e) {
				System.out.println(e);
				return;
			}  catch(ExecutionException e) {
				System.out.println(e);
			} finally {
				exec.shutdown();
			}
		}
	}
}
```

##休眠（sleep）与等待（wait）
sleep：使线程进入休眠，但不放弃对象的锁。Java SE5引入了更加显式的sleep()版本：`TimeUnit.MILLSESECONDS.sleep(100)`。sleep行为本身可以被中断，因此需要捕获InterruptedException异常。  
wait：使线程进入阻塞且放弃锁。必须使用notify或者notifyAlll或者指定睡眠时间来唤醒当前等待池中的线程。


##join方法    
>join() method suspends the execution of the calling thread until the object called finishes its execution.
也就是说，t.join()方法阻塞调用此方法的线程(calling thread)，直到线程t完成，此线程再继续；通常用于在main()主线程内，等待其它线程完成再结束main()主线程。  
注意，对join()方法的调用可以被中断，做法是在调用线程上调用interrupt()方法，这时需要用到try-catch子句。   

```java
class Sleeper extends Thread {
	private int duration;
	
	public Sleeper(String name, int sleepTime) {
		super(name);
		duration = sleepTime;
		start();
	}
	
	public void run() {
		try {
			sleep(duration);
		} catch (InterruptedException e) {
			System.out.println(getName() + " was interrupted. " + "isInterrupted(): " + isInterrupted());
			return;
		}
		System.out.println(getName() + " has awakened");
	}
}

class Joiner extends Thread {
	private Sleeper sleeper;
	public Joiner (String name ,Sleeper sleeper) {
		super(name);
		this.sleeper = sleeper;
		start();
	}
	
	public void run() {
		try {
			sleeper.join();
		} catch(InterruptedException e) {
			System.out.println("Interrupted");
		}
		System.out.println(getName()+" join completed"); 
	}
	
}

public class Joining {

	public static void main(String[] args) {
		Sleeper sleepy = new Sleeper("Sleepy",1500),
				grumpy = new Sleeper("Grumpy",1500);
		Joiner dopey = new Joiner("Dopey",sleepy),
				doc = new Joiner("Doc",grumpy);
		grumpy.interrupt();
	}

}
```

输出   

```
Grumpy was interrupted. isInterrupted(): false
Doc join completed
Sleepy has awakened
Dopey join completed
```


##处理线程中的异常   
 
Thread的run方法是不抛出任何检查型异常(checked exception)的,但是它自身却可能因为一个异常而被终止，导致这个线程的终结。即异常不能跨线程传播回main()，所以必须在本地处理所有在线程内部产生的异常。    
所以要处理线程的异常有两个方法：    
 
1. 在run中加入try...catch
2. 给每个thread统一传入一个Thread.UncaughtExceptionHandler对象
但麻烦的是，在线程中抛出的异常即使使用try...catch也无法截获，因此可能导致一些问题出现，比如异常的时候无法回收一些系统资源，或者没有关闭当前的连接等等。    

推荐使用Thread.UncaughtExceptionHandler对象，原因有：   

1. Thread.UncaughtExceptionHandler统一管理一类Thread更方便，使用try...catch必须对每个run方法中都进行try...catch，很容易忘记一些事情。
2. try...catch很容易将正常情况下的InterruptedException也捕获了。

下面的代码不捕获异常，导致程序在碰到异常后停止，executor没有退出。   

```java
public class RunnableBlog {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        ScheduledExecutorService executor = Executors.newSingleThreadScheduledExecutor();
        
        executor.scheduleAtFixedRate(new Runnable() {
            @Override
            public void run() {
                    System.out.println(Thread.currentThread().getName() + " -> " + System.currentTimeMillis());
                    throw new RuntimeException("game over");
            }
        }, 0, 1000, TimeUnit.MILLISECONDS).get();
        
        System.out.println("exit");
        executor.shutdown();
    }
}
```   

下面的代码捕获异常（两种方式），使得程序能按照预定的情况一直执行   

```java
public class RunnableBlog2 {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        ScheduledExecutorService executor = Executors.newSingleThreadScheduledExecutor();

        executor.scheduleAtFixedRate(new Runnable() {
            @Override
            public void run() {
                try {
                    System.out.println(Thread.currentThread().getName() + " -> " + System.currentTimeMillis());
                    throw new RuntimeException("game over");
                } catch (RuntimeException e) {
                    e.printStackTrace();
                }
            }
        }, 0, 1000, TimeUnit.MILLISECONDS).get();

        System.out.println("exit");
        executor.shutdown();
    }
}
```

UncaughtExceptionHandler方式：


```java
public class RunnableBlog3 {
	public static void main(String[] args) throws ExecutionException, InterruptedException {
        ScheduledExecutorService executor = Executors.newSingleThreadScheduledExecutor();

        executor.scheduleAtFixedRate(new Runnable() {
            @Override
            public void run() {
                try {
                    System.out.println(Thread.currentThread().getName() + " -> " + System.currentTimeMillis());
                    throw new RuntimeException("game over");
                } catch (RuntimeException e) {
                    Thread t = Thread.currentThread();
                    t.getUncaughtExceptionHandler().uncaughtException(t, e);
                }
            }
        }, 0, 1000, TimeUnit.MILLISECONDS).get();

        System.out.println("exit");
        executor.shutdown();
    }
}
```