---
layout: post
title: "使用UIAppearance协议自定义视图"
date: 2013-12-17 17:06
comments: true
categories: 
---

###背景 
  
在iOS5之前，如果想更改原生控件的外观，且如果想一次性更改系统中所有的控件外观，就只能定义子类且所有使用的地方都替换成自定义的子类，且覆盖drawRect方法。而在iOS5之后，苹果通过两个协议（UIAppearance和UIAppearanceContainer）规范了对许多UIKit控件定制的支持。<!--more-->
###介绍

使用UIAppearance协议可以得到一个类的外观代理协议。你可以通过类的外观代理协议（UIAppearance）发送外观更改消息来定制类实例的外观。  
但请注意：  
>注意：iOS会在一个view进入窗口时更改外观，在已经在窗口的view不会更改。如果需要更改已经在窗口的view，需要从view层次中删除再放回。

###使用 
 
有两种使用方式取定制外观：对**所有**实例，对**特定**的包含再container中的类实例.但前提是实现了UIAppearance协议且存取器（accessor）标志为UI_APPEARANCE_SELECTOR的方法。   

```
@property(nonatomic,retain)   UIColor     *tintColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR; 
```

####对**所有**实例   
通过类（class）获得UIAppearance更改外观。如更改UINavigationBar的背景着色：

```
[[UINavigationBar appearance] setBarTintColor:myNavBarBackgroundColor];
```


####对**特定**的包含在container中的类实例   
对**特定**的包含在container中的类实例，或者在view层级（hierarchy）中的实例，使用appearanceWhenContainedIn去获得appearance代理协议。如更改在navigation bar 中的UIButtonItem的一些属性：  

```
[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackgroundImage:myNavBarButtonBackgroundImage forState:state barMetrics:metrics];

[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], [UIPopoverController class], nil] setBackgroundImage:myPopoverNavBarButtonBackgroundImage forState:state barMetrics:metrics];

[[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil] setBackgroundImage:myToolbarButtonBackgroundImage forState:state barMetrics:metrics];

[[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], [UIPopoverController class], nil] setBackgroundImage:myPopoverToolbarButtonBackgroundImage forState:state barMetrics:metrics];
```   

###让自定义的view支持UIAppearance协议
UIView已经实现了UIAppearance协议。所以任何继承自UIControl或者UIView的子类，且存取器标志为UI_APPEARANCE_SELECTOR的方法都支持像原生类（如UIButton）那样使用UIAppearance协议。   

###一些链接
[UIAppearanceContainer Protocol Reference官方文档](https://developer.apple.com/library/ios/recipes/UIAppearanceContainer_Protocol/Reference/Reference.html#//apple_ref/c/macro/UI_APPEARANCE_SELECTOR)    
[UIAppearance Protocol Reference官方文档](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIAppearance_Protocol/Reference/Reference.html)       
[图灵社区的UIAppearance介绍](http://www.ituring.com.cn/article/30658)    
[Peter Steinberger的一篇深入介绍UIAppearance的文章：UIAppearance for Custom Views](http://petersteinberger.com/blog/2013/uiappearance-for-custom-views/) 