---
layout: post
title: "《Java核心技术》读书笔记之注解"
date: 2014-08-20 19:06
comments: true
categories: 
---
## 定义
注解（也被称为元数据）为我们在代码中添加信息提供了一种形式化的方法，使我们可以在稍后某个时刻非常方便地使用这些数据。<!--more-->  
### 解释
注解在一定程度上是在把元数据与源代码文件结合在一起，而不是保存在外部文档中这一大的趋势之下催生的。同时，注解也是对来自像C#之类的其他语言对Java造成的语言特性压力所作出的一种回应。  
### 作用
1. 注解用来完整描述程序所需，且无法用Java来表达的信息。
2. 注解使得我们能够以将由编译器来测试和验证的格式，存储有关程序的额外信息。
3. 注解可以用来生成描述符文件，甚至或是新的类定义，并且有助于减轻编写“样板”代码的负担。
4. 通过使用注解，我们可以将这些元数据保存在更加干净易读的代码以及编译期类型检查等。
###J ava内置的三种标准注解和四种元注解
定义在java.lang中。  
标准注解  

1. @Override  
2. @Deprecated
3. @SuppressWarnings

元注解  

1. @Target
2. @Retention
3. @Documented：Include this annotation in the Javadocs.
4. @Inherited：Allow subclasses to inherit parent annotations. 


## 基本语法

	//: net/mindview/atunit/Test.java 
	// The @Test tag. 
	package net.mindview.atunit; 
	import java.lang.annotation.*; 
	@Target(ElementType.METHOD) 
	@Retention(RetentionPolicy.RUNTIME) 
	public @interface Test {} ///:~ 

定义注解时，会需要一些元注解（meta-annotation）   

1. `@Target`用来定义你的注解将应用于什么地方。   
2. `@Rectection`用来定义该注解在哪一个级别可用。在源代码（SOURCE）、类文件（CLASS）、或者运行时（RUNTIME）。  

没有元素的注解称为标记注解，例如上例中的@Test。 

下面是一个简单的注解，我们可以用它来跟踪一个项目中的用例。如果一个方法或者一组方法实现了某个用例的需求，那么程序员可以为此方法加上该注解。于是，项目经理通过计算已经实现的用例，就可以很好的掌控项目的进展。而如果要更新或者修改系统的业务逻辑，则维护该项目的开发人员也可以很容易地在代码中找到对应的用例。

    import java.lang.annotation.*; 
     
    @Target(ElementType.METHOD) 
    @Retention(RetentionPolicy.RUNTIME) 
    public @interface UseCase { 
      public int id(); 
      public String description() default "no description"; 
    }


注意，id和description类似方法的定义。由于编译器会对id进行类型检查，因此将用例文档的追踪数据库与源代码相关联是可靠地。description有一个default的值。  

在下面的类中，有三个方法被注解为用例：  
    import java.util.*; 
     
    public class PasswordUtils { 
      @UseCase(id = 47, description = 
      "Passwords must contain at least one numeric") 
      public boolean validatePassword(String password) { 
    return (password.matches("\\w*\\d\\w*")); 
      } 
      @UseCase(id = 48) 
      public String encryptPassword(String password) { 
       return new StringBuilder(password).reverse().toString(); 
      } 
      @UseCase(id = 49, description = 
      "New passwords can’t equal previously used ones") 
      public boolean checkForNewPassword( 
    List<String> prevPasswords, String password) { 
    return !prevPasswords.contains(password); 
      } 
    }

## 编写注解处理器
我们将用它来读取PasswordUtils类，并使用反射机制查找@UseCase标记。

    import java.lang.reflect.*; 
    import java.util.*; 
     
    public class UseCaseTracker { 
      public static void 
      trackUseCases(List<Integer> useCases, Class<?> cl) { 
    for(Method m : cl.getDeclaredMethods()) { 
      UseCase uc = m.getAnnotation(UseCase.class); 
      if(uc != null) { 
    System.out.println("Found Use Case:" + uc.id() + 
      " " + uc.description()); 
    useCases.remove(new Integer(uc.id())); 
      } 
    } 
    for(int i : useCases) { 
      System.out.println("Warning: Missing use case-" + i); 
    } 
      } 
      public static void main(String[] args) { 
    List<Integer> useCases = new ArrayList<Integer>(); 
    Collections.addAll(useCases, 47, 48, 49, 50); 
    trackUseCases(useCases, PasswordUtils.class); 
      } 
    }

### 注解元素

标签@UseCase由UserCase.java定义，其中包含int元素id，以及一个String元素description。注解元素可用的类型如下所示：

* 所有基本类型
* String
* Class
* enum
* Annotation
* 以上类型的数组

### 元素的默认值限制
1. 不能有不确定的值。
2. 对于非基本类型的元素，无论在源代码中声明时，或者在注解接口中定义默认值时，都不能以null作为其值。

### 利用注解生成外部文件
类似hibernate的注解bean，生成一个数据库表。
### 注解不支持继承
## 使用注解处理工具apt处理注解（待完成）
## 基于注解的单元注释