---
layout: post
title: "spring事务管理"
date: 2014-06-02 19:06
comments: true
categories: 
---

##事务解释
###定义

一个数据库事务通常包含了一个序列的对数据库的读/写操作。它的存在包含有以下两个目的：  
 
1. 为数据库操作序列提供了一个从失败中恢复到正常状态的方法，同时提供了数据库即使在异常状态下仍能保持一致性的方法。  
2. 当多个应用程序在并发访问数据库时，可以在这些应用程序之间提供一个隔离方法，以防止彼此的操作互相干扰。<!--more-->  

当事务被提交给了DBMS（数据库管理系统），则DBMS（数据库管理系统）需要确保该事务中的所有操作都成功完成且其结果被永久保存在数据库中，如果事务中有的操作没有成功完成，则事务中的所有操作都需要被回滚，回到事务执行前的状态;同时，该事务对数据库或者其他事务的执行无影响，所有的事务都好像在独立的运行。   

但在现实情况下，失败的风险很高。在一个数据库事务的执行过程中，有可能会遇上事务操作失败、数据库系统/操作系统失败，甚至是存储介质失败等情况。这便需要DBMS对一个执行失败的事务执行恢复操作，将其数据库状态恢复到一致状态（数据的一致性得到保证的状态）。为了实现将数据库状态恢复到一致状态的功能，DBMS通常需要维护事务日志以追踪事务中所有影响数据库数据的操作。  

###事务的ACID特性  

并非任意的对数据库的操作序列都是数据库事务。数据库事务拥有以下四个特性，习惯上被称之为ACID特性。

* 原子性（Atomicity）：事务作为一个整体被执行，包含在其中的对数据库的操作要么全部被执行，要么都不执行。
* 一致性（Consistency）：事务应确保数据库的状态从一个一致状态转变为另一个一致状态。一致状态的含义是数据库中的数据应满足完整性约束。
* 隔离性（Isolation）：多个事务并发执行时，一个事务的执行不应影响其他事务的执行。
* 持久性（Durability）：已被提交的事务对数据库的修改应该永久保存在数据库中。

以上内容来自[维基百科](https://zh.wikipedia.org/zh-cn/%E6%95%B0%E6%8D%AE%E5%BA%93%E4%BA%8B%E5%8A%A1)

## Java事务的类型

Java事务的类型有三种：JDBC事务、JTA（Java Transaction API）事务、容器事务。   

###JDBC事务
JDBC 事务是用 Connection 对象控制的

###JTA事务
JTA是一种高层的，与实现无关的，与协议无关的API，应用程序和应用服务器可以使用JTA来访问事务。

###容器事务
容器事务主要是J2EE应用服务器提供的，容器事务大多是基于JTA完成，这是一个基于JNDI的，相当复杂的API实现。

##Spring事务
在Spring中，事务是通过 TransactionDefinition 接口来定义的。  

	public interface TransactionDefinition{
		int getIsolationLevel();
		int getPropagationBehavior();
		int getTimeout();
		boolean isReadOnly();
	}
	
###事务隔离级别

隔离级别是指若干个并发的事务之间的隔离程度。TransactionDefinition 接口中定义了五个表示隔离级别的常量：  


* TransactionDefinition.ISOLATION_DEFAULT：这是默认值，表示使用底层数据库的默认隔离级别。对大部分数据库而言，通常这值就是TransactionDefinition.ISOLATION_READ_COMMITTED。
* TransactionDefinition.ISOLATION_READ_UNCOMMITTED：该隔离级别表示一个事务可以读取另一个事务修改但还没有提交的数据。该级别不能防止脏读和不可重复读，因此很少使用该隔离级别。  
* TransactionDefinition.ISOLATION_READ_COMMITTED：该隔离级别表示一个事务只能读取另一个事务已经提交的数据。该级别可以防止脏读，这也是大多数情况下的推荐值。
* TransactionDefinition.ISOLATION_REPEATABLE_READ：该隔离级别表示一个事务在整个过程中可以多次重复执行某个查询，并且每次返回的记录都相同。即使在多次查询之间有新增的数据满足该查询，这些新增的记录也会被忽略。该级别可以防止脏读和不可重复读。
* TransactionDefinition.ISOLATION_SERIALIZABLE：所有的事务依次逐个执行，这样事务之间就完全不可能产生干扰，也就是说，该级别可以防止脏读、不可重复读以及幻读。但是这将严重影响程序的性能。通常情况下也不会用到该级别。  

###事务传播行为

所谓事务的传播行为是指，如果在开始当前事务之前，一个事务上下文已经存在，此时有若干选项可以指定一个事务性方法的执行行为。在TransactionDefinition定义中包括了如下几个表示传播行为的常量：  

* TransactionDefinition.PROPAGATION_REQUIRED：如果当前存在事务，则加入该事务；如果当前没有事务，则创建一个新的事务。
* TransactionDefinition.PROPAGATION_REQUIRES_NEW：创建一个新的事务，如果当前存在事务，则把当前事务挂起。
* TransactionDefinition.PROPAGATION_SUPPORTS：如果当前存在事务，则加入该事务；如果当前没有事务，则以非事务的方式继续运行。
* TransactionDefinition.PROPAGATION_NOT_SUPPORTED：以非事务方式运行，如果当前存在事务，则把当前事务挂起。
* TransactionDefinition.PROPAGATION_NEVER：以非事务方式运行，如果当前存在事务，则抛出异常。
* TransactionDefinition.PROPAGATION_MANDATORY：如果当前存在事务，则加入该事务；如果当前没有事务，则抛出异常。
* TransactionDefinition.PROPAGATION_NESTED：如果当前存在事务，则创建一个事务作为当前事务的嵌套事务来运行；如果当前没有事务，则该取值等价于TransactionDefinition.PROPAGATION_REQUIRED。

这里需要指出的是，前面的六种事务传播行为是 Spring 从 EJB 中引入的，他们共享相同的概念。而 PROPAGATION_NESTED是 Spring 所特有的。以 PROPAGATION_NESTED 启动的事务内嵌于外部事务中（如果存在外部事务的话），此时，内嵌事务并不是一个独立的事务，它依赖于外部事务的存在，只有通过外部的事务提交，才能引起内部事务的提交，嵌套的子事务不能单独提交。如果熟悉 JDBC 中的保存点（SavePoint）的概念，那嵌套事务就很容易理解了，其实嵌套的子事务就是保存点的一个应用，一个事务中可以包括多个保存点，每一个嵌套子事务。另外，外部事务的回滚也会导致嵌套子事务的回滚。  

###spring中事务管理的方式
包括编程式事务管理和声明式事务管理。
####编程式事务管理

	public class BankServiceImpl implements BankService {
	private BankDao bankDao;
	private TransactionDefinition txDefinition;
	private PlatformTransactionManager txManager;

	public boolean transfer(Long fromId， Long toId， double amount) {
		TransactionStatus txStatus = txManager.getTransaction(txDefinition);
		boolean result = false;
		try {
			result = bankDao.transfer(fromId， toId， amount);
			txManager.commit(txStatus);
		} catch (Exception e) {
			result = false;
			txManager.rollback(txStatus);
			System.out.println("Transfer Error!");
		}
		return result;
	}
	}

####声明式事务管理

	<bean id="hb_transactionManager"
		class="org.springframework.orm.hibernate3.HibernateTransactionManager">
		<property name="sessionFactory">
			<ref local="sessionFactory" />
		</property>
	</bean>
	<bean id="baseTransactionProxy"
		class="org.springframework.transaction.interceptor.TransactionProxyFactoryBean"
		abstract="true">
		<property name="proxyTargetClass" value="true" />
		<property name="transactionManager" ref="hb_transactionManager" />
		<property name="transactionAttributes">
			<props>
				<prop key="addNew*">PROPAGATION_REQUIRED</prop>
				<prop key="delete*">PROPAGATION_REQUIRED</prop>
				<prop key="update*">PROPAGATION_REQUIRED</prop>
				<prop key="insert*">PROPAGATION_REQUIRED</prop>
				<prop key="get*">PROPAGATION_REQUIRED</prop>
			</props>
		</property>
	</bean>
	
	
参考文章：  
https://zh.wikipedia.org/zh-cn/%E6%95%B0%E6%8D%AE%E5%BA%93%E4%BA%8B%E5%8A%A1
http://www.ibm.com/developerworks/cn/education/opensource/os-cn-spring-trans/   
http://www.iteye.com/topic/78674