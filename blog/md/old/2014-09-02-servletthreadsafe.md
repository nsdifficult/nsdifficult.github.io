---
layout: post
title: "Servlet是线程安全的吗"
date: 2014-09-02 18:06
comments: true
categories: 
---
##线程安全解释
线程安全的解释有很多。
[中文维基百科](http://zh.wikipedia.org/wiki/%E7%BA%BF%E7%A8%8B%E5%AE%89%E5%85%A8)   
>线程安全是编程中的术语，指某个函数、函数库在多线程环境中被调用时，能够正确地处理各个线程的局部变量，使程序功能正确完成。<!--more-->

[英文维基百科](http://en.wikipedia.org/wiki/Thread_safety)   
>Thread safety is a computer programming concept applicable in the context of multi-threaded programs. A piece of code is thread-safe if it only manipulates shared data structures in a manner that guarantees safe execution by multiple threads at the same time. There are various strategies for making thread-safe data structures.

我的理解：  
>线程安全指某块代码在被多个线程同时执行的情况下能正确执行，且能输出期望的结果。   

##线程不安全的原因
线程安全主要是因为实例变量（声明在类中且任何方法外的属性）引起。

##线程不安全的解决办法
先提出两个概念：**有状态**,**无状态**。   
关于这两个概念的解释见[代码之丑（十二）--无状态方法，郑晔，ThoughtWorks公司首席咨询师](http://www.infoq.com/cn/news/2012/06/ugly-code-12)：   
>衡量一个方法是否是有状态的，就看它是否改动了其它的东西，比如全局变量，比如实例的字段。format方法在运行过程中改动了SimpleDateFormat的calendar字段，所以，它是有状态的。  

所以，无状态的类，方法永远都是线程安全的。  
借鉴刚才提到的那篇文章中的例子：SimpleDateFormat不是线程安全的。所以下面这样写是不对的

```java
class Sample {
  private static final DateFormat format = new SimpleDateFormat("yyyy.MM.dd");

  public String getCurrentDateText() {
    return format.format(new Date());
  }
}
```

getCurrentDateText是有状态的，所以是线程不安全的。要进行改造，则需要将format这个实例变量改成局部变量。   

```java
public class Sample {
    public String getCurrentDateText() {
        return new SimpleDateFormat("yyyy.MM.dd").format(new Date());
    }
}
```

##Servlet的线程安全问题
讲了这么多，那么Servlet是线程安全的吗？答案是：不安全。  
###解释   
见这篇文章的解释：[深入理解Servlet线程安全问题 ](http://blog.csdn.net/lcore/article/details/8974590)

####Servlet线程池   
serlvet采用多线程来处理多个请求同时访问，Tomcat容器维护了一个线程池来服务请求。线程池实际上是等待执行代码的一组线程叫做工作组线程(Worker Thread)，Tomcat容器使用一个调度线程来管理工作组线程(Dispatcher Thead)。   

当容器收到一个Servlet请求，Dispatcher线程从线程池中选出一个工作组线程，将请求传递给该线程，然后由该线程来执行Servlet的service方法。    

当这个线程正在执行的时候，容器收到另一个请求，调度者线程将从线程池中选出另外一个工作组线程来服务则个新的请求，容器并不关心这个请求是否访问的是同一个Servlet还是另一个Servlet。当容器收到对同一个Servlet的多个请求的时候，那这个servlet的service方法将在多线程中并发的执行。   

####servlet线程安全问题
多线程和单线程Servlet具体区别：多线程下每个线程对局部变量都会有自己的一份copy，这样对局部变量的修改只会影响到自己的copy而不会对别的线程产生影响，线程安全的。但是对于实例变量来说，由于servlet在Tomcat中是以单例模式存在的，所有的线程共享实例变量。多个线程对共享资源的访问就造成了线程不安全问题。   

####设计线程安全的Servlet   

1. 避免使用实例变量   
2. 避免使用非线程安全的集合    
3. 在多个Servlet中对某个外部对象(例如文件)的修改是务必加锁（Synchronized，或者ReentrantLock），互斥访问。   
4. 属性的线程安全：ServletContext、HttpSession是线程安全的；ServletRequest是非线程安全的。  

####一个线程不安全的Servlet   

```java
package com.edgar.servlet;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class ThreadServlet
 */
@WebServlet("/ThreadServlet")
public class ThreadServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private String message = "";

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public ThreadServlet() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		this.doPost(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException, IOException {
		synchronized(message){
			message = request.getParameter("message");
			PrintWriter printWriter = response.getWriter();
			try {
				Thread.sleep(5000);
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			printWriter.write(message);
		}
		
	}

}
```

当有大量请求的时候，会出现返回的不是预期（不正确）的message。   
解决的办法就是将message设置为局部变量。
