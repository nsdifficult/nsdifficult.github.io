---
layout: post
title: "关于异常的一些问答"
date: 2015-04-06 01:06
comments: true
categories: 
--- 

##1、什么叫做异常？
异常处理，是编程语言或计算机硬件里的一种机制，用于处理软件或信息系统中出现的异常状况（即超出程序正常执行流程的某些特殊条件）。
##2、Java中关于异常／错误怎么理解？
Java的基本理念是：“结构不佳的代码不能运行”。   
发现错误的最佳时机是在编译阶段。但编译期间不能找出所有的错误，余下的错误只能在运行期解决。这就需要错误源能通过某种方式，把适当的信息传递给某个接收者（该接收者知道该如何处理这个错误）。Java使用异常来提供一致的错误报告模型。<!--more-->
##3、Java中异常的分类？
在Java中,异常分为受检查异常,与运行时异常. 两者都在异常类层次结构中.其最大的区别受检查异常是必须要捕获和处理的，否则编译期不通过，运行时异常则不需要。
##4、Java中的异常的类结构图？
![Diagram of Exception Hierarchy](/images/exception/1.jpeg "Diagram of Exception Hierarchy ")    
粉红色的是受检查的异常(checked exceptions),其必须被 try{}catch语句块所捕获,或者在方法签名里通过throws子句声明.受检查的异常必须在编译时被捕捉处理,命名为 CHecked Exception 是因为Java编译器要进行检查,Java虚拟机也要进行检查,以确保这个规则得到遵守.   

绿色的异常是运行时异常(runtime exceptions),需要程序员自己分析代码决定是否捕获和处理,比如 空指针,被0除...。而声明为Error的，则属于严重错误,需要根据业务信息进行特殊处理,Error不需要捕捉。  
##5、那么问题来了，RuntimeException异常为什么是非检查异常？且可以不捕获处理？
1. 首先，Java认为RuntimeException为错误，无法解决。如除以0，空指针等。  
2. 其次，RuntimeException会自动被虚拟机抛出，无需在程序中再单独列出来。  
3. 最后，如果RuntimeException不被捕获和处理，会直达main方法，最后程序退出（程序退出前自动调用异常的printStatck方法）。

##6、运行时异常（RuntimeException）不捕获也不会有编译错误，那么该何时捕获，何时不捕获？
看你的需求：
1. 如果你希望发生异常后立即停止程序，就不捕获。
2. 如果你希望发生异常后还继续运行，就捕获。

##7、异常管理的最佳实践？
如果能处理异常就捕获并处理，不能就抛出。

##8、异常处理流程：捕获－》处理－》清理（可选，如关闭打开的连接，文件等）

```java
try {
     ...
} catch(Exception e) {//1、捕获异常
     //2、处理异常
} finaly  {
	//3、最后要做的，如清理工作
}
```
##9、Java中的方法声明为什么跟着throws XXException？
这个叫做异常声明，通常我们的程序不会同源代码一同发布，这样客户程序调用我们的方法就不能知道我们的方法可能会抛出哪些异常，便不能处理了。Java为了解决这个问题，便提供了异常声明这个语法。
##10、为什么我的程序什么错误都没有报错(没有输出错误信息)，就直接退出了？
因为你的代码没有捕获一个特定的运行时异常，且由于某些原因还导致了异常丢失(没有输出错误信息)。（如在finaly里return了，这里是个人理解和猜测，欢迎指正）。
##11、如何捕获所有异常，包括可能的运行时异常？  
捕获Exception。
##12、一般不要调用fillInStackTrace，这样会丢失栈信息
即不要使用Exception的fillInStackTrace()方法。因为调用后，调用行就成了异常的新发地了。
##13、自定义异常要注意不要丢失原始异常链
要将原始Exception传入自定义异常（通常通过构造器）。如：`throw new MyException(e,"msg");`
##什么是异常限制（待续）？

###参考
* [《Java编程思想》](http://book.douban.com/subject/2130190/)
* [ Diagram of Exception Hierarchy ](http://www.programcreek.com/2009/02/diagram-for-hierarchy-of-exception-classes/)
* [ Top 10 Questions about Java Exceptions ](http://www.programcreek.com/2013/10/top-10-questions-about-java-exceptions/)
* [Java 异常处理的误区和经验总结](http://www.ibm.com/developerworks/cn/java/j-lo-exception-misdirection/)



