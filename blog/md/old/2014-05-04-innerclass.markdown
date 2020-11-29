---
layout: post
title: "《Java核心技术》读书笔记之内部类"
date: 2014-05-04 09:06
comments: true
categories: 
---
# 《Java核心技术》读书笔记之内部类
## 定义
内部类是定义在另一个类中的类。<!--more-->
##前言：为什么要使用内部类
主要原因有三个：   

1. 内部类方法可以访问该类定义所在的作用域中的数据，包括私有的数据。
2. 内部类可以对同一个包中的其他类隐藏起来。
3. 当想定义一个回调函数且不想编写大量代码时，使用匿名内部类比较便捷。  


#### 1. 内部类方法可以访问该类定义所在的作用域中的数据，包括私有的数据。

```java
import java.awt.*;
import java.awt.event.*;
import java.util.*;
import javax.swing.*;
import javax.swing.Timer;
public class InnerClassTest
{  
   public static void main(String[] args)
   {  
      TalkingClock clock = new TalkingClock(1000, true);
      clock.start();
      JOptionPane.showMessageDialog(null, "Quit program?");
      System.exit(0);
   }
}
class TalkingClock
{  
   public TalkingClock(int interval, boolean beep)
   {  
      this.interval = interval;
      this.beep = beep;
   }
   public void start()
   {
      ActionListener listener = new TimePrinter();
      Timer t = new Timer(interval, listener);
      t.start();
   }
   private int interval;
   private boolean beep;
   private class TimePrinter implements ActionListener
   {  
      public void actionPerformed(ActionEvent event)
      {  
         Date now = new Date();
         System.out.println("At the tone, the time is " + now);
         if (beep) Toolkit.getDefaultToolkit().beep();
      }
   }
}
```

* 只有内部类可以时私有类，而常规类只可以具有包可见性，或公有可见性。
* 内部类的对象总有一个隐式引用，它指向了创建它的外部类对象。`if (beep) Toolkit.getDefaultToolkit().beep();`中可以改为`outer.beep`

编译器会为内部类生成默认的构造器。

```java
pubic TimerPrinter(TalkingClock clock) {
	outer = clock;
}
```
当在start方法中创建了TimerPrinter对象后，编译器会将this引用传递给内部类的构造器，然后内部类就可以通过构造器初始化outer了：

```java
ActionListener listener = new TimePrinter(this);
```
#### 2. 内部类的特殊语法规则

上文讲述了内部类有一个外围类的引用outer。事实上，使用外围类引用的正规语法还要复杂一些。表达式  

```java
OuterClass.this
```

表示外围类的引用。如actionPerformed方法：

```java
public void actionPerformed(ActionEvent event) {
	...
	if(TalkingClock.this.beep)ToolKit.getDefaultToolKit().beep();
}
```

反过来，可以采用下列语法格式更加明确的编写内部类对象的构造器：

```java
outerObject.new InnerClass(construction parameters)
```

例如，

```java
ActionListener listener = this.new TimePrinter();
```

通常this限定词是多余的。不过，可以通过显式地命名将外围类引用设置为其他的对象。例如，如果，TimePrinter是一个公有内部类，对于任意的语音时钟都可以构造一个TimePrinter:

```java
TalkingClock jabberer = new TalkingClock(1000,true);
TalkingClock.TimePrinter listener = jabberer.new TimePrinter();
```

需要注意，在外围类的作用域之外，可以这样引用内部类：

```java
OuterClass.InnerClass
```
#### 3. 内部类是否有用、必要和安全

内部类是一种编译器现象，与虚拟机无关。编译器会将内部类翻译成用$（美元符号）分隔外部类名与内部类名的常规类文件，而虚拟机则对此一无所知。  

例如，TalkingClock类内部的TimePrinter类将被翻译成类文件TalkingClock$TimePrinter.class。

如果不是用内部类呢？

TalkingClock类文件

```java
class TalkingClock
{  
   public TalkingClock(int interval, boolean beep)
   {  
      this.interval = interval;
      this.beep = beep;
   }
   public void start()
   {
      ActionListener listener = new TimePrinter();
      Timer t = new Timer(interval, listener);
      t.start();
   }
   private int interval;
   private boolean beep;
}
```

TimePrinter类文件

```java
class TimePrinter implements ActionListener {  
	pubic TimerPrinter(TalkingClock clock) {
		outer = clock;
	}
	private TalkingClock outer;
    public void actionPerformed(ActionEvent event) {  
         Date now = new Date();
         System.out.println("At the tone, the time is " + now);
         if (beep) {//错误，TimePrinter不是内部类，不能访问TalkingClock的私有变量beep
         	Toolkit.getDefaultToolkit().beep();
         }
      }
}
```

内部类可以访问外围类的私有数据，常规类不可以。   
可见，***由于内部类拥有访问特权，所以与常规类比较起来功能更加强大。***  

#### 4. 局部内部类

TimePrinter这个类名字只在start方法中创建这个类型的对象时使用了一次。  
当遇到这类情况时，可以在一个方法中定义局部类。  

```java
public void start()
   {
   	  class TimePrinter implements ActionListener {  
			private TalkingClock outer;
    		public void actionPerformed(ActionEvent event) {  
         		Date now = new Date();
         		System.out.println("At the tone, the time is " + now);
         		if (beep) {
         			Toolkit.getDefaultToolkit().beep();
         		}
      		}
		}
      ActionListener listener = new TimePrinter();
      Timer t = new Timer(interval, listener);
      t.start();
   }
```
***局部类不能用public和private访问说明符进行声明。它的作用域被限定在声明这个局部类的块中。***   

局部类有一个优势，即对除块以外的外部世界可以完全的隐藏起来。  


##### 5. 由外部方法访问final声明的局部变量  

局部类可以访问局部变量，但局部变量必须声明为final。因为局部类会为局部变量备份，声明final可以保持与建立备份时一致。  

有时候如果局部变量必须被改变，则可以用数组封装，然后将数组声明为final（这样数组不可以引用另外一个数组，但其中的数据可以自由更改）。  

#### 6. 匿名内部类  

假如只创建这个类的一个对象，就不必命名了。这种类被称为匿名内部类。  

```java
import java.awt.*;
import java.awt.event.*;
import java.util.*;
import javax.swing.*;
import javax.swing.Timer;
public class AnonymousInnerClassTest
{    
   public static void main(String[] args)
   {  
      TalkingClock clock = new TalkingClock();
      clock.start(1000, true);
      JOptionPane.showMessageDialog(null, "Quit program?");
      System.exit(0);
   }
}
   public void start(int interval, final boolean beep)
   {
      ActionListener listener = new 
         ActionListener()
         {
            public void actionPerformed(ActionEvent event)
            {  
               Date now = new Date();
               System.out.println("At the tone, the time is " + now);
               if (beep) Toolkit.getDefaultToolkit().beep();
            }
         };
      Timer t = new Timer(interval, listener);
      t.start();
   }
}
```
声明匿名内部类的语法格式为：

```java
new SuperType(construction parameters) {
	inner class methods and data
}
```  

其中SuperType可以时接口，或者类。匿名内部类由于没有类名，所以不能由构造器，取而代之的时将参数传递个超类构造器，但如果是实现接口，则不能有任何构造参数。  

#### 7. 静态内部类   

如果只需要将内部类隐藏在另外一个类的内部，而不需要内部类引用外围类对象，则可以将内部类声明为static，以便取消产生的引用。  

```java
public class StaticInnerClassTest
{  
   public static void main(String[] args)
   {  
      double[] d = new double[20];
      for (int i = 0; i < d.length; i++)
         d[i] = 100 * Math.random();
      ArrayAlg.Pair p = ArrayAlg.minmax(d);
      System.out.println("min = " + p.getFirst());
      System.out.println("max = " + p.getSecond());
   }
}
class ArrayAlg
{  
   public static class Pair  //声明静态内部类
   { 
      public Pair(double f, double s)
      {  
         first = f;
         second = s;
      }
      public double getFirst()
      {  
         return first;
      }
      public double getSecond()
      {  
         return second;
      }
      private double first;
      private double second;
   }
   public static Pair minmax(double[] values)
   {  
      double min = Double.MAX_VALUE;
      double max = Double.MIN_VALUE;
      for (double v : values)
      {  
         if (min > v) min = v;
         if (max < v) max = v;
      }
      return new Pair(min, max);
   }
}
```  

这个例子使用static修饰内部类还有一个原因是，minmax方法为静态方法。  ***且只有内部类才能使用static修饰。***
