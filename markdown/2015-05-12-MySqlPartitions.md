---
layout: post
title: "MySql分区调研笔记"
date: 2015-05-12 16:06
comments: true
categories: 
---
##先介绍索引分类
###key
通常是index的同义词
###index
索引，同key
###primary key
主键，也是unique key（即unique index）。每个表只能有一个。
###unique key
即唯一索引，每个表可以有多个。<!--more-->
###unique index
即唯一索引，同unique key
##MySQL分区简介[转载自文章：MySQL分区](http://breezey.blog.51cto.com/2400275/1568014) 
当mysql一张数据表中的数据达到一定的量时，在其中查询某一个数据，需要花费大量的时间。为了避免这种查询的等待，可以对一张大的数据表做拆分。将其拆分成多张小的数据表。可以基于__物理的拆分__，将一张表拆分成多张小表，分别存放于不同的服务器上，以分散对mysql服务器的写的压力。也可以基于__逻辑的拆分__，将一张表存放到不同的区块或磁盘上，以提高mysql的读写性能。   

mysql数据拆分基于拆分方式的不同，又分为__水平拆分__和__垂直拆分__，水平拆分也叫基于行的拆分，它不改变表结构，只是把多行数据分成多个表来进行存放，每个表只存放其中一部分行的数据。垂直拆分也叫基于列的拆分，它是将一张表中的多个列分开，拆分后的每张表只存放一部分列。    

mysql分区是一种基于__逻辑__的__水平拆分__的方式。  

##MySQL分区类型
这里只简单介绍下，详细可以看[官方文档](http://dev.mysql.com/doc/refman/5.7/en/partitioning-types.html)
###RANGE Partitioning
根据某个字段的范围来分区，如时间
###LIST Partitioning
类似RANGE Partitioning，但不是根据范围，而是一个预设的list来分区
###COLUMNS Partitioning
类似RANGE Partitioning，不过是针对多个列的范围来分区
###HASH Partitioning
HASH分区主要用来确保数据在预先确定数目的分区中平均分布，你所要做的只是基于将要被哈希的列值指定一个列值或表达式，以 及指定被分区的表将要被分割成的分区数量。 
###KEY Partitioning
按照KEY进行分区类似于按照HASH分区，除了HASH分区使用的用户定义的表达式，而KEY分区的哈希函数是由MySQL 服务器提供。
###Subpartitioning
也被称之为子分区。是分区表中每个分区的再次分割，子分区既可以使用HASH希分区，也可以使用KEY分区。

##详细说下分区限制
这里只简单介绍下，详细可以看[官方文档](http://dev.mysql.com/doc/refman/5.6/en/partitioning-limitations-partitioning-keys-unique-keys.html)
先说结论：
>> The rule governing this relationship can be expressed as follows: All columns used in the partitioning expression for a partitioned table must be part of every unique key that the table may have.     
In other words, every unique key on the table must use every column in the table's partitioning expression. (This also includes the table's primary key, since it is by definition a unique key. This particular case is discussed later in this section.) s

即：**不能对每个UNIQUE KEY都包括的字段之外的字段进行分区**
##其他
###分区对SQL语句透明
###可以通过`SHOW PLUGINS`来看使用的MySql版本是否支持分区

```
 partition                   | ACTIVE | STORAGE ENGINE     | NULL    | GPL
```
###查看某个表的数据在各个分区的分布

```sql
SELECT PARTITION_NAME,TABLE_ROWS  FROM INFORMATION_SCHEMA.PARTITIONS  WHERE TABLE_NAME = 'user';
```

关于分区的使用，查询等这里不做介绍了（不符合项目需求，没有使用，所以就不多说了～）。想仔细理解可以看看[官方的文档](http://dev.mysql.com/doc/refman/5.7/en/partitioning.html)

##疑问
话说mysql的分区限制这么死，你们都怎么用的？
