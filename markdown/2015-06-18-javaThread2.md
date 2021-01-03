---
layout: post
title: "《Java编程思想》读书笔记之多线程(二)"
date: 2015-06-18 09:06
comments: true
categories: 
---

# 《Java编程思想》读书笔记之多线程(二)

## 共享受限资源
基本上所有的并发模式在解决线程冲突问题的时候，都是采用序列化访问共享资源的方案。这意味着在给定时刻只允许一个任务访问共享资源。通常这是通过在代码前加上一条锁语句来实现的，这就使得一段时间内只有一个任务可以运行这段代码。因为锁语句产生了一种互相排斥的效果，所以这种机制称为互赤量(mutex)。   
共享资源一般是以对象的形式存在的内存片段，但也可以是文件、输入/输出端口，或者是打印机。<!--more-->   
##### 何时使用同步
可以运用Brian的同步规则：
>如果你正在写一个变量，它可能接下来将被另一个线程读取，或者正在读取一个上一次已经被另一个线程写过的变量，那么你必须使用同步，并且，读写线程都必须用相同的监视器锁同步。     

使用锁有两种方式：    
### 使用synchronized
#### 对象有锁。
所有对象都自动包含有单一的锁（也称为监视器）。当在对象上调用其任意的synchronized方法的时候，此对象都被加锁，这时对象上的其他synchronzied方法只有等到前一个方法调用完毕并释放了锁之后才能被调用。   
一个线程可以多次获得对象的锁。JVM采用计数的方式处理：JVM负责跟踪对象被加锁的次数。只有首先获得了锁的任务才能允许继续获取多个锁。    
#### 类也有锁。
所以synchronized static 方法可以在类的范围内防止对static数据的并发访问。    
##### synchronized之临界区
有时你只是希望多个线程同时访问方法内部的部分代码而不是防止同时访问整改方法。通过这种方式分离出来的代码段被称为临界区（critical section），它也是使用synchronized关键字建立。在这里，synchronized被用来指定某个对象，此对象的锁被用来对花括号内的代码进行同步控制。    

```java
synchronized(syncObject) {
	//This code can be accessed by only one task at a time
}
```

通过使用同步控制块而不是对整个方法进行同步控制，可以使多个任务访问对象的时间性能得到显著提高。   

### 使用显示的Lock对象
Java SE5的java.util.concurrent类库还包含有定义在java.util.concurrent.locks中的显式地创建、锁定和释放。因此，它与内建的锁形式相比缺少优雅性。但是，对于解决某些类型的问题来说，它更加灵活。    

```java
class X {
   private final ReentrantLock lock = new ReentrantLock();
   // ...

   public void m() {
     lock.lock();  // block until condition holds
     try {
       // ... method body
     } finally {
       lock.unlock()
     }
   }
 }}
```
### synchronized与Lock区别
#### 使用synchronized时在线程失败时，没有机会做任何清理工作，而Lock可以
#### 使用Lock可以进行更细粒度的控制，如尝试获得锁，没有则先做其他工作。

```java
public class AttemptLocking {
	
	private ReentrantLock lock = new ReentrantLock();
	
	public void untimed() {
		boolean captured = lock.tryLock();
		
		try {
			System.out.println("tryLock(): "+captured);
		} finally {
			if (captured) {
				lock.unlock();
			}
		}
		
	}
	
	public void timed() {
		boolean captured = false;
		
		try {
			captured = lock.tryLock(2, TimeUnit.SECONDS);
		} catch(InterruptedException e) {
			throw new RuntimeException(e);
		}
		
		try {
			System.out.println("tryLock(2,TimeUnit.SECONDS): "+captured);
		} finally {
			if (captured) {
				lock.unlock();
			}
		}
	}
	
	public static void main(String[] args) {
		final AttemptLocking al = new AttemptLocking();
		al.untimed();
		al.timed();
		new Thread() {
			{setDaemon(true);}
			public void run() {
				al.lock.lock();
				System.out.println("acquired");
			}
		}.start();
		Thread.yield();
		al.untimed();
		al.timed();
	}
}
```    

输出结果为：

```java
tryLock(): true
tryLock(2,TimeUnit.SECONDS): true
tryLock(): true
tryLock(2,TimeUnit.SECONDS): true
acquired
```

ReentrantLock允许你尝试获取但最终未获取锁，这样如果其他人已经获取了这个锁，那你可以决定离开去执行其他一些事情，而不是等待直至这个锁被释放，就像在untimed()方法中所看到。在time()中，作出了尝试去获取锁，该尝试可以在2秒之后失败。在main()中，作为匿名类而创建了一个单独的Thread，它将获取锁，这使得 untimed()和timed()方法对某些事物将产生竞争。    
### 原子性
#### 原子性解释
>原子（atom）本意是“不能被进一步分割的最小粒子”，而原子操作（atomic operation）意为"不可被中断的一个或一系列操作"，在java中就是不能被线程调度机制中断的操作 。   
在java中可以通过锁（synchronized或者lock）和循环CAS的方式来实现原子操作。    

原子性可以应用于除long和double之外的所有基本类型之上的简单操作（如读取和写入）。这些操作会被当作不可分（原子）的操作来操作内存。但是JVM可以将64位（long和double变量）的读取和写入当作两个分离的32位操作来执行，这就产生了在一个读取和写入操作中间发生上文切换，从而导致不同的任务可以看到不正确的结果的可能性。    
#### volatile
但是当定义long和double变量时，使用volatile关键字，就会获得原子性。不同的JVM可以任意地提供更强的保证，但是你不应该依赖于平台相关的特性。    
##### volatile可见性
volatile是轻量的synchronized，它在多处理器开发中保证了共享变量的可见性。可见性的意思是当一个线程修改一个变量时，另外一个线程能读到这个修改的值。     
Java语言规范第三版中对volatile的定义如下：    
>java编程语言允许线程访问共享变量，为了确保共享变量能被准确和一致的更新，线程应该确保通过排他锁单独获得这个变量。Java语言提供了volatile，在某些情况下比锁更加方便。如果一个字段被声明成volatile，java线程内存模型确保所有线程看到这个变量的值是一致的。   

关于更多的volatile的解释见[ 聊聊并发（一）——深入分析Volatile的实现原理](http://www.infoq.com/cn/articles/ftf-java-volatile)    
##### 原子类
Java SE5引入了诸如AtomicInteger、AtomicLong、AtomicReference等特殊的原子性变量类。

#### 可以对this对象同步，也可以针对另一个对象同步。
下面的例子演示了两个任务可以同时进入同一个对象，只要这个对象上的方法是在不同的锁上同步的即可：    

```java
class DualSynch {
	private Object syncObject = new Object();
	
	public synchronized void f() {
		for (int i=0; i < 5; i++) {
			System.out.println("f()");
			Thread.yield();
		}
	}
	
	public void g() {
		synchronized (syncObject) {
			for (int i=0; i < 5; i++) {
				System.out.println("g()");
				Thread.yield();
			}
		}
	}
}

public class SyncObject {
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		final DualSynch ds = new DualSynch();
		new Thread() {
			public void run() {
				ds.f();
			};
		}.start();
		ds.g();
	}

}
```

#### 线程本地存储
防止任务在共享资源上产生冲突的第二种方式就是根除对变量的共享。可以使用java.lang.ThreadLocal   
### 终结线程（任务）
可以使用Thread类的interrupt()方法来终止一个阻塞的线程。   

