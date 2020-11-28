---
layout: post
title: "多线程开发（一）"
date: 2014-02-12 15:06
comments: true
categories: 
---
## 线程定义
从技术角度来看,一个线程就是一个需要管理执行代码的内核级和应用级数据结构组合。  
线程是系统的最小调度单位，进程是资源分配的最小单位。<!--more-->  
[维基百科对线程的解释](http://zh.wikipedia.org/wiki/%E7%BA%BF%E7%A8%8B)：线程（英语：thread）是操作系统能够进行运算调度的最小单位。它被包含在进程之中，是进程中的实际运作单位。一条线程指的是进程中一个单一顺序的控制流，一个进程中可以并发多个线程，每条线程并行执行不同的任务。在Unix System V及SunOS中也被称为轻量进程（lightweight processes），但轻量进程更多指内核线程(kernel thread)，而把用户线程(user thread)称为线程。  
##线程术语

* **线程(thread)**用于指代独立执行的代码段。   
* **进程(process)**用于指代一个正在运行的可执行程序,它可以包含多个线程。   
* **任务(task)**用于指代抽象的概念,表示需要执行的工作。
 

## 多线程的替代方法
出于一些原因你可能不需要使用多线程，如：1.使用多线程会带来大量的开销，包括内存消耗和CPU占用。2.你是否真的需要多线程或者并发。3.自己创建多线程代码会给你的代码带来不确定性。  
iOS和OS X提供了一些线程替代技术   

技术 | 描述 
------------ | -------------
Operation objects | [Concurrency Programming Guide.](https://developer.apple.com/library/ios/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008091)
Grand Central Dispatch (GCD) | [Concurrency Programming Guide.](https://developer.apple.com/library/ios/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008091)
Idle-time notifications |   [Notification Programming Topics.](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Notifications/Introduction/introNotifications.html#//apple_ref/doc/uid/10000043i)
Asynchronous functions |  系统接口包括一些异步函数为开发者提供了自动同步。当你设计你的应用时，可以使用那些提供异步行为的函数而不是同步的函数。
Timers |  [Timer Sources.](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html#//apple_ref/doc/uid/10000057i-CH16-SW21)
Separate processes (单独进程)|  尽管比线程更加重量级，但有时候开发者的确需要创建独立无关于应用的进程。

## 线程支持
如果你已经有代码使用了多线程,Mac OS X和iOS提供几种技术来在你的应用程序里面创建多线程。此外,两个系统都提供了管理和同步你需要在这些线程里面处理的工作。以下几个部分描述了一些你在Mac OS X和iOS上面使用多线程的时候需要注意的关键技术。  
###线程包
虽然多线程的底层实现机制是Mach的线程,你很少(即使有)使用 Mach 级的线程机会。相反,你会经常使用到更多易用的POSIX的API或者它的衍生工具。Mach的实现没有提供多线程的基本特征,但是包括抢占式的执行模型和调度线程的能力,所以它们是相互独立的。  
你可以在你的应用程序使用的线程技术：  

技术 | 描述 
------------ | -------------
Cocoa threads | Cocoa使用NSThread类实现了线程。Cocoa也提供了在已经运行的线程上给NSObject提供了创建线程的方法。更多见[Using NSThread](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Multithreading/CreatingThreads/CreatingThreads.html#//apple_ref/doc/uid/10000057i-CH15-SW11)和[Using NSObject to Spawn a Thread](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Multithreading/CreatingThreads/CreatingThreads.html#//apple_ref/doc/uid/10000057i-CH15-SW13) 
POSIX threads | Cocoa使用NSThread类实现了线程。Cocoa也提供了在已经运行的线程上给NSObject提供了创建线程的方法。更多见[Using POSIX Threads](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/Multithreading/CreatingThreads/CreatingThreads.html#//apple_ref/doc/uid/10000057i-CH15-SW12)  
Multiprocessing Services（多进程服务） | Multiprocessing Services是老版本的的Mac OS中的应用使用的遗留的基于C的接口。这个技术仅仅使用在OS X中，且需要尽量避免在新的开发中使用。作为替代，开发者应该使用NSTread类和POSIX线程。如果你需要更多相关信息，见Multiprocessing Services Programming Guide。  




