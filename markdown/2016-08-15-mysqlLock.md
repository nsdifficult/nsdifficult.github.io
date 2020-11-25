---
layout: post
title: "InnoDB锁学习笔记"
date: 2016-08-15 17:06
comments: true
categories: 

---

###Shared and Exclusive Locks
即s锁/共享锁/读锁 和 x锁/排他锁/写锁。   
s锁只允许别的事务在其持有数据上加s锁。顾名思义，x锁会让其他请求其数据的事务等待。<!--more--> 
###Intention Locks
Intention Locks的目的是InnoDB为支持不同粒度的锁而引入的一种锁，它是表级锁。简单点儿说就是在一个事务要确定对哪些范围的数据加锁前，先使用Intention Locks。同样，它也分： Intention shared (IS)锁和Intention exclusive (IX)锁。   
这些规则可以总结为以下的锁兼容矩阵：   

|   | X | IX    | S  | IS |
|-------|:---:|-----------|-------|:-------:|
| X  | Confict | Confict     | Confict | Confict |
| IX | Confict  | Compatible      |  Confict  | Confict |
| S  | Confict  | Confict | Compatible     | Confict |
| IS  | Confict   | Compatible | Compatible     | Confict |

如果一个事务请求的锁和已经存在的锁兼容，则此事务会得到锁，否则不能得到锁。事务会等待直到已有的冲突锁被释放。如果一个锁请求和已有的锁发生冲突，则它不会得到锁，因为会发生死锁并引发错误。    

###Record Locks   
Record Locks是加在特定记录上的锁，该记录对应列为索引列。例如，SELECT c1 FOR UPDATE FROM t WHERE c1 = 10;可以防止任何其它事务插入、 更新或删除t.c1等于10的行。   
###Gap Locks 
Gap Locks是加在一个索引范围内记录上的锁，或者索引开始记录前，索引结束记录后的这一范围的锁。即Gap Locks锁定一个范围，不锁定记录本身。Gap Locks主要为了解决幻读问题（隔离级别为Reapted Read）。   
在InnoDB中，间隙锁是“完全被抑制”的，意思是它只阻止其它事务给往间隙中插入。它们不阻止其他事务在同一个间隙上获得间隙锁。因此，一个间隙X锁和一个间隙S锁效果一样。    
可以显式禁用间隙锁。如果你更改事务隔离级别为READ COMMITTED或启用innodb_locks_unsafe_for_binlog系统变量 （现已废弃），禁用会生效。在这些情况下，间隙锁在查找和索引扫描时会被禁用，仅在外键约束检查和重复键检查时启用。
###Next-Key Locks 
Record Locks和Gap Locks的结合，锁定一个范围的记录。即锁定范围且锁定记录本身。
###Insert Intention Locks   
一个Insert Intention Locks是插入操作在插入某行或者某些行记录前放置的一种Gap Lock锁。它的存在是为了保证不同的事务如果要往不同的Gap里插入记录，而不互相影响。
###AUTO-INC Locks 
AUTO-INC Locks是一种表锁，当往自增列插入时会使用AUTO-INC Locks。    
innodb_autoinc_lock_mode配置可以调整该锁。    

* ```innodb_autoinc_lock_mode=0```通过表锁的方式进行，也就是所有类型的insert都用AUTO-inc locking。

* ```innodb_autoinc_lock_mode=1```默认值，对于simple insert 自增长值的产生使用互斥量对内存中的计数器进行累加操作，对于bulk insert 则还是使用表锁的方式进行。

* ```innodb_autoinc_lock_mode=2```对所有的insert-like 自增长值的产生使用互斥量机制完成，性能最高，并发插入可能导致自增值不连续，可能会导致Statement 的 Replication 出现不一致，使用该模式，需要用 Row Replication的模式。

###Predicate Locks for Spatial Indexes
空间索引预测锁，暂时用不到。忽略。   
##MySql锁
###锁超时设置与查看    
参数支持范围为Session和Global，且支持动态修改，所以可以通过两种方法修改；    
查看：   


```java
show variables like 'innodb_lock_wait_timeout'; -- 查看
```
修改：


```java
set  innodb_lock_wait_timeout = 10;   -- 设置
```

或者修改my.cnf文件

```sql
innodb_lock_wait_timeout = 50 
```
更详细了解可以看看这篇文章[深入理解JDBC的超时设置](http://www.importnew.com/2466.html)
###未提交事务查看
information_schema库下事务和锁的一些描述：   
* innodb_trx  当前运行的所有事务
* innodb_locks  当前出现的锁
* innodb_lock_waits  锁等待的对应关系 


##如何查看SQL语句使用什么锁
###InnoDB行锁
InnoDB行锁是通过给索引上的索引项加锁来实现的，这一点MySQL与Oracle不同，后者是通过在数据块中对相应数据行加锁来实现的。InnoDB这种行锁实现特点意味着：只有通过索引条件检索数据，InnoDB才使用行级锁，否则，InnoDB将使用表锁！    
1. 在不通过索引条件查询的时候，InnoDB确实使用的是表锁，而不是行锁。    
2. 由于MySQL的行锁是针对索引加的锁，不是针对记录加的锁，所以虽然是访问不同行的记录，但是如果是使用相同的索引键，是会出现锁冲突的。应用设计的时候要注意这一点。   
3. 当表有多个索引的时候，不同的事务可以使用不同的索引锁定不同的行，另外，不论是使用主键索引、唯一索引或普通索引，InnoDB都会使用行锁来对数据加锁。    
4. 即便在条件中使用了索引字段，但是否使用索引来检索数据是由MySQL通过判断不同执行计划的代价来决定的，如果MySQL认为全表扫描效率更高，比如对一些很小的表，它就不会使用索引，这种情况下InnoDB将使用表锁，而不是行锁。因此，在分析锁冲突时，别忘了检查SQL的执行计划，以确认是否真正使用了索引。

###举例说明

```sql
CREATE TABLE person (
        id int NOT NULL, 
        name varchar(100), 
        age int, 
        address varchar(255),
        PRIMARY KEY (id), 
        CONSTRAINT nameIdx UNIQUE (name), 
        INDEX ageIdx (age)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO person (id, name, age, address) VALUES (3, '900', 10, 'BeiJing');
INSERT INTO person (id, name, age, address) VALUES (5, '800', 5, 'ShangHai');
INSERT INTO person (id, name, age, address) VALUES (10, '930', 20, 'NanJing');
INSERT INTO person (id, name, age, address) VALUES (15, '950', 20, 'NanJing');
```

仅分析事务隔离级别为Reapted Read级别情况下的加锁情况。   
####执行如下sql：

```sql
delete from person where id = '5';//1
delete from person where name = '900';//2
delete from person where age = '20';//3
delete from person where address = 'NanJing';//4
```

1. Record Lock 
	主键id对应为5的记录加Record Lock
2. Record Lock 
	索引nameIdx为900对应的记录加Record Lock，同时满足主键为3的记录也被加Record Lock
3. Record Lock 和 Gap Lock
	ageIdx为20的记录加Record Lock，同时满足(5,20],(20,+∞)的Gap被加Gap Lock(解决幻读)。
4. Record Lock 和 Gap Lock
	所有记录都加了Record Lock 和 所有主键索引间的Gap都加了Gap Lock（解决幻读）

关于具体sql分析，可以参考这篇文章: [MySQL 加锁处理分析](http://hedengcheng.com/?p=771)   
官方参考文章: [15.5.1 InnoDB Locking](http://dev.mysql.com/doc/refman/5.7/en/innodb-locking.html#innodb-gap-locks)