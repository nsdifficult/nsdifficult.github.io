---
layout: post
title: "iOS开发中全屏与非全屏之间的切换"
date: 2013-11-21 17:06
comments: true
categories: 
---



##iOS6及之前的全屏与非全屏之间的切换

首先要设置status bar的隐藏与显示，然后设置相关view的frame。<!--more-->

```
    BOOL isFullScreen = [UIApplication sharedApplication].statusBarHidden;
    if (isFullScreen) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
        [self.view setFrame:[UIScreen mainScreen].bounds];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
        [self.view setFrame:[UIScreen mainScreen].bounds];
    }
```

##iOS7的全屏与非全屏之间的切换

苹果在在iOS7之后给UIViewController新增了一个方法prefersStatusBarHidden来设置状态栏的隐藏与显示，调用setStatusBarHidden方法不再有效。如果需要调用这个方法，只需调用

```
[self setNeedsStatusBarAppearanceUpdate]
```

即可

```
 - (BOOL)prefersStatusBarHidden
{
    BOOL isFullScreen = [UIApplication sharedApplication].statusBarHidden;
    return !isFullScreen;
}
```

##当某个UIViewController需要全屏，需要调用UIViewController的setWantsFullScreenLayout方法

```
        [self setWantsFullScreenLayout:YES];

```

如果涉及到设备的方向之间切换、前后台切换等，不写这一句时会发生视图偏移。

##在全屏且横屏时，发生设备方向改变，再切换回非全屏时，可能需要判断状态栏的方向，来确定view的偏移

设备方向改变会导致状态栏方向改变，所以需要设置view的偏移是20px还是-20px。
判断状态栏的方向的方法：

```
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
```

实际运用中的一个例子：

```
	AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIViewController *rootViewController = (UIViewController *)delegate.window.rootViewController;
    
    [rootViewController.view addSubview:self.playerViewController.view];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    float offsetX = -20;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        offsetX = 20;
    }
    [rootViewController.view setFrame:CGRectMake(offsetX, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    

```