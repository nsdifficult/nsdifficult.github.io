---
layout: post
title: "《Java编程思想》读书笔记之容器(二)"
date: 2015-05-07 17:06
comments: true
categories: 

---
##理解Map
映射表（也称关联数组）的基本思想是它维护的键-值对关联，因此你可以使用键来查找值。标准的Java类库中包含了Map的几种基本实现，包括：HashMap,TreeMap,LinkedHashMap,WeakHashMap,ConcurrentHashMap,IdentiyHashMap.它们都有同样的基本接口Map，但是行为特性各不相同，这表现在效率、键值对的保存及呈现次序、对象的保存周期
映射表如何在多线程程序中和判定“键”等价的策略等方面。<!--more-->  
###性能
性能是映射表中的一个重要问题，当在get中使用线性搜索时，执行速度会相当的慢，而这正是HashMap提高速度的地方。HashMap使用散列码，来取代对键的缓慢搜索。    
####散列码
散列码是“相对唯一”的、用以代表对象的int的值，它是通过将该对象的某些信息进行反转换而生成的。hasCode()是根类Object的方法，因此所有Java对象都能产生散列码。HashMap就是使用对象的hashCode()进行快速查询的，此方法能够显著提高性能。    
对Map中使用的键的要求与对Set中的元素的要求一样。任何键都必须具有一个equals()方法；如果键被用于散列Map，那么它必须还具有恰当的hashCode()方法；如果键被用于TreeMap，那么它必须实现Comparable。   
###散列与散列码
如果要创建用作HashMap的键（即key）的类，必须要实现自己的equals()和hashCode()方法。hashCode()应基于key的内容生成，且速度要够快。如String的hashCode()方法。