---
layout: post
title: "MySql索引的使用笔记"
date: 2015-04-20 17:06
comments: true
categories: 

---

##什么是数据库索引？
数据库索引，是数据库管理系统中一个排序的数据结构，以协助快速查询、更新数据库表中数据。
##MySql中索引使用的数据结构？
BTree。MyISAM引擎使用B+Tree作为索引结构；InnoDB存储引擎也使用B+Tree作为索引结构，但两者的具体实现方式不同，具体见[MySQL索引背后的数据结构及算法原理](http://blog.codinglabs.org/articles/theory-of-mysql-index.html)
##什么是聚集索引和非聚集索引？
数据记录本身被存于索引<!--more-->（一颗B+Tree）的叶子节点上，这种索引叫**聚集索引**，InnoDB使用聚集索引。反之则为**非聚集索引**，MyISAM使用非聚集索引，它的叶子节点的data域指向数据记录的地址，而不是存储数据记录本身；  
##MySql支持聚集索引吗？
MySQL有没有支持聚集索引，取决于采用哪种存储引擎。MySQL InnoDB一定会建立聚集索引。InnoDB的数据文件本身就是索引文件，且按主键聚集   
关于聚集索引还需注意：   
1. 如果声声明了主键(primary key)，则这个列会被做为聚集索引。  
2. 如果没有声明主键，则会用一个唯一且不为空的索引列做为主键，成为此表的聚集索引。
3. 上面二个条件都不满足，InnoDB会自己产生一个虚拟的字段作为聚集索引，这个字段长度为6个字节，类型为长整形。   

##MySql有几种索引？
普通索引；主键索引；唯一索引；联合索引；全文索引。
##索引特性：   
1. B+树的性质决定：索引的字段（数据项）长度越小，树的高度越低，查询次数越少，即磁盘IO次数越少（所以尽量使用字段类型较小的字段作为索引，如尽量使用int型而不是long型字段）。   
2. 索引的最左匹配特性    

##建索引的几个原则（转自[MySQL索引原理及慢查询优化](http://tech.meituan.com/mysql-index.html)）
1. 最左前缀匹配原则，非常重要的原则，mysql会一直向右匹配直到遇到范围查询(>、<、between、like)就停止匹配，比如a = 1 and b = 2 and c > 3 and d = 4 如果建立(a,b,c,d)顺序的索引，d是用不到索引的，如果建立(a,b,d,c)的索引则都可以用到，a,b,d的顺序可以任意调整。
2. =和in可以乱序，比如a = 1 and b = 2 and c = 3 建立(a,b,c)索引可以任意顺序，mysql的查询优化器会帮你优化成索引可以识别的形式。
3. 尽量选择区分度高的列作为索引,区分度（Selectivity）的公式是count(distinct col)/count(*)，表示字段不重复的比例，比例越大我们扫描的记录数越少，唯一键的区分度是1，而一些状态、性别字段可能在大数据面前区分度就是0，那可能有人会问，这个比例有什么经验值吗？使用场景不同，这个值也很难确定，一般需要join的字段我们都要求是0.1以上，即平均1条扫描10条记录。
4. 索引列不能参与计算，保持列“干净”，比如from_unixtime(create_time) = ’2014-05-29’就不能使用到索引，原因很简单，b+树中存的都是数据表中的字段值，但进行检索时，需要把所有元素都应用函数才能比较，显然成本太大。所以语句应该写成create_time = unix_timestamp(’2014-05-29’);
5. 尽量的扩展索引，不要新建索引。比如表中已经有a的索引，现在要加(a,b)的索引，那么只需要修改原来的索引即可。
6. 尽量不使用like，非要使用注意like '%XXX'不会使用索引，而like 'XXX%'可以。
7. 如果直接使用字段建索引太长，可以考虑建立前缀索引（即不直接使用整个字段，而是根据上文提到的Selectivity来使用字段的前缀）。如
```
ALTER TABLE employees.employees ADD INDEX `first_name_last_name4` (first_name, last_name(4));
```

##sql查询语句在使用索引方面的注意事项
1. 不要在索引列上进行运算（如+，-，*，/，! 等）；
2. 不要在索引列上运用函数（如avg等）；
3. 不要在like语句中将百分号在前（如"%--"）；
4. 字符型字段为数字时在where条件里不添加引号；
5. 当where条件中有索引字段，需要排序时尽量对索引字段进行排序；

##参考文章
1. [MySQL索引原理及慢查询优化](http://tech.meituan.com/mysql-index.html)
2. [MySQL索引背后的数据结构及算法原理](http://blog.codinglabs.org/articles/theory-of-mysql-index.html)
3. [由浅入深理解索引的实现(1)](http://www.zhdba.com/mysqlops/2011/11/24/understanding_index/)
[MYSQL索引失效的各种情形总结](http://blog.sina.com.cn/s/blog_6e322ce7010101i7.html)
