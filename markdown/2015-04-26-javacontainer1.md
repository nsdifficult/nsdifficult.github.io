---
layout: post
title: "《Java编程思想》读书笔记之容器(一)"
date: 2015-04-26 17:06
comments: true
categories: 

---
# 《Java编程思想》读书笔记之容器(一)

# 先上容器的类图<!--more-->
![](/images/container/container.png)

点线框表示接口；实线框表示普通类（具体类）；虚线框表示抽象类；带有空心箭头的点线表示一个特定的类实现了一个接口；实心箭头表示某个类可以生成箭头所指向类的对象。例如任意的Collection可以生成Iterator，而List可以生成ListIterator（也能生成普通的Iterator，因为List继承自Collection）。   
#### 1) Collection
一个独立元素的序列，其中List按照元素的插入顺序保存元素，而set不能有重复元素，Queue按照先进先出（FIFO）的方式来管理数据，Stack按照后进先出（LIFO）的顺序管理数据。    
#### 2) Map
一组键值对（key-value）对象的序列，可以使用key来查找value，其中key是不可以重复的，value可以重复。我们可以称其为字典或者关联数组。其中HashMap是无序的，TreeMap是有序的，WeakHashMap是弱类型的，Hashtable是线程安全的。
## 在容器中使用范型可以使容器类型安全。
通过使用范型，可以在编译期防止将错误类型的对象放置到容器中。
## 添加一组元素
工具类#Arrays#,#Collections#中有很多实用方法。   
Arrays工具类提供的#Arrays.asList#：   

```java
public static <T> List<T> asList(T... a) {
        return new ArrayList<>(a);
    }
```

Collections工具类提供的#Collections.addAll#：   

```java
public static <T> boolean addAll(Collection<? super T> c, T... elements) {
        boolean result = false;
        for (T element : elements)
            result |= c.add(element);
        return result;
    }
```

各个具体容器提供的#Collection.addAll#：   

```java
    boolean addAll(Collection<? extends E> c);
```

## 容器的打印
打印数组必须使用#Arrays.toString()#来产生数组的可打印表示。但是容器的打印无需任何帮助。
## List
#### ArrayList
擅长随机访问元素，但是在List中间插入喝移除元素较慢。
#### LinkedList
它通过代价较低的在List中间进行的插入和删除操作，提供了优化的顺序访问。LinkedList在随机访问方面相对较慢。但是它的特性集较ArrayList更大。   
## 迭代器Iterator
不需知道容器类型，就能使用容器。这正是迭代器（一个具体类，也是一种设计模式）的作用。
#### Iterator：只能单向移动

```java
		List<String> list1 = new ArrayList<String>();
		list1.addAll(Arrays.asList("a","b"));
		Iterator<String> it = list1.iterator();
		while (it.hasNext()) {
			System.out.println(it);
		}
```
#### ListIterator：能双向移动，能替换元素，且在创建时可以指定元素index

```java
		List<String> list1 = new ArrayList<String>();
		list1.addAll(Arrays.asList("a","b","c"));
		ListIterator<String> lit = list1.listIterator(2);
		while (lit.hasPrevious()) {
			System.out.println(lit);
		}
```

## LinkedList
和ArrayList一样实现了基本的List接口，但是它执行某些操作（如插入删除）比ArrayList更加高效，但随机访问稍微逊色。
## Statck
是先进后出（FILO）的容器。LinkedList具有能够实现栈的所有功能的方法，因此可以直接将LinkedList作为Stack使用。
## Queue
是先进先出（FIFO）的容器。LinkedList具有能够实现栈的所有功能的方法，因此可以直接将LinkedList作为Queue使用。
## Set
不能有重复元素。有两种实现：#HashSet#访问速度快，#TreeSet#是有序的。
## Map
有两种实现：#HashMap#;#TreeMap#
## Collection接口与Iterator
Collection是所有序列容器的共性接口，它可能被认为是一个“附属接口”，即因为要表示其他若干个接口的共性而出现的接口。另外，java.util.AbstractCollection提供了Collection的默认实现。它可以使得你创建AbstractCollection的子类，从而避免了不必要的代码重复（相比直接实现Collection）。    
但另外一点，C++中容器共性并不是由基类来保持，而是迭代器。当要实现一个不是Collection的外部类时，让它去实现Collection时非常麻烦和困难，因此使用Iterator就是一个好的选择。且有时Iterator的代码更少。

```java
/**
 * Created: yirongyi@2015年4月26日 下午6:09:01
 */
package com.edgar.chapter11;

import java.util.Iterator;


class Sequence {
	protected String[] strs = {"a","b","c"};
}

public class NonCollectionSequence extends Sequence{
	
	public Iterator<String> iterator() {
		return new Iterator<String>(){
			private int index = 0;
			@Override
			public boolean hasNext() {
				return index < strs.length;
			}

			@Override
			public String next() {
				return strs[index++];
			}
			
			public void remove() {
				throw new UnsupportedOperationException();
			}
			
		};
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		NonCollectionSequence ncs = new NonCollectionSequence();
		Iterator<String> it = ncs.iterator();
		while(it.hasNext()) {
			System.out.println(it.next());
		}
	}

}
```

## foreach与迭代器（Iterator）
foreach可以使用在数组中，同时也能使用在任何的Collection对象中（Map不行）。因为Collection的实现类都实现了Iterator接口，该接口拥有一个产生Iterator的iterator()方法，且Ieterator接口被foreach用来在序列中移动。因此任何实现了Itreator接口的类都可以使用foreach。









