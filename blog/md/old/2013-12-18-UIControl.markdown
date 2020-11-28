---
layout: post
title: "使用UIControl类自定义视图"
date: 2013-12-18 17:06
comments: true
categories: 
---


### 介绍
UIControl是一些诸如buttons和sliders的控件的基类，它向应用传递用户意图。你不能直接使用UIControl。它替代它的子类来定义普通接口和行为结构。<!--more-->  
UIControl的主要角色是定义interface和为准备事件消息和当目标事件发生时初始化并传递它们到它们的目标。  
要了解target-action机制，可以查看Cocoa Fundamentals中的GuideTarget-Action in UIKit部分。Multi-Touch模式则可以查看[ Event Handling Guide for iOS](https://developer.apple.com/library/ios/documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/Introduction/Introduction.html#//apple_ref/doc/uid/TP40009541)  
UIControl类也包括存取control state的方法。如决定一个control是否开启。   
### 使用
你可能会处于两个原因来定义UIControl子类：  
1.去观察或者修改特定事件的action messages的传递。To do this, override sendAction:to:forEvent:, evaluate the passed-in selector, target object, or UIControlEvents bit mask, and proceed as required.－－－－翻译不好:(   
2.提供自定义的跟踪行为（如改变外观的高亮）。要做到这点，需要覆盖所有这三个方法：

```
beginTrackingWithTouch:withEvent:
continueTrackingWithTouch:withEvent:
endTrackingWithTouch:withEvent:
```
 
### 继承自UIControl的自定义控件经常会发送一些UIControl中定义的特有的事件

```
typedef NS_OPTIONS(NSUInteger, UIControlEvents) {
    UIControlEventTouchDown           = 1 <<  0,      // on all touch downs
    UIControlEventTouchDownRepeat     = 1 <<  1,      // on multiple touchdowns (tap count > 1)
    UIControlEventTouchDragInside     = 1 <<  2,
    UIControlEventTouchDragOutside    = 1 <<  3,
    UIControlEventTouchDragEnter      = 1 <<  4,
    UIControlEventTouchDragExit       = 1 <<  5,
    UIControlEventTouchUpInside       = 1 <<  6,
    UIControlEventTouchUpOutside      = 1 <<  7,
    UIControlEventTouchCancel         = 1 <<  8,
    UIControlEventValueChanged        = 1 << 12,     // sliders, etc.
    UIControlEventEditingDidBegin     = 1 << 16,     // UITextField
    UIControlEventEditingChanged      = 1 << 17,
    UIControlEventEditingDidEnd       = 1 << 18,
    UIControlEventEditingDidEndOnExit = 1 << 19,     // 'return key' ending editing
    UIControlEventAllTouchEvents      = 0x00000FFF,  // for touch events
    UIControlEventAllEditingEvents    = 0x000F0000,  // for UITextField
    UIControlEventApplicationReserved = 0x0F000000,  // range available for application use
    UIControlEventSystemReserved      = 0xF0000000,  // range reserved for internal framework use
    UIControlEventAllEvents           = 0xFFFFFFFF
};
```

UIControl继承自UIView，UIView则继承自UIResponder。UIControl对事件进行了又一次的封装。使事件更易处理与理解。如UIControlEventValueChanged。  

```
        [self sendActionsForControlEvents:UIControlEventValueChanged];

```

当UIControl子类发送了诸如UIControlEventValueChanged的事件，在UIViewController等中就可以使用addTarget方法类响应该事件了。

```
    [switchView addTarget:self action:@selector(switchViewChanged:) forControlEvents:UIControlEventValueChanged];
```
