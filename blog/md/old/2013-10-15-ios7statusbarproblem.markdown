---
layout: post
title: "iOS7中的status bar问题"
date: 2013-10-15 15:06
comments: true
categories: 
---


首先推荐这篇文章：[Redesign Your App for iOS 7 之 页面布局](http://www.vinqon.com/codeblog/?detail/11109)

在iOS7中状态栏默认透明，且视图默认全屏。在实际开发中发现当直接在一个UIVIewController中添加一个UITableview时会发生table中内容在status bar后面的问题。<!--more-->


![status bar cover view](https://developer.apple.com/library/ios/qa/qa1797/Art/qa1797_1.png)

苹果官网有个解决办法： [How do I prevent the status bar from covering my views in iOS 7?](https://developer.apple.com/library/ios/qa/qa1797/_index.html#top)

实际试验后发现对其他视图（如UIToolBar）都有效。但在storyboard环境下，在一个UIViewController上直接添加一个UITableView时，使用这种方法并不奏效，网上有讨论说这是一个bug。见：[iOS 7: UITableView shows under status bar](http://stackoverflow.com/questions/18900428/ios-7-uitableview-shows-under-status-bar)。

后来使用：

```
[self.tableViewMain setContentInset:UIEdgeInsetsMake(20, self.tableViewMain.contentInset.left, self.tableViewMain.contentInset.bottom, self.tableViewMain.contentInset.right)];
```
解决问题。

##解释

###topLayoutGuide

上面的[解决办法](https://developer.apple.com/library/ios/qa/qa1797/_index.html#top)中有提到UIVIewController的属性[topLayoutGuide](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIViewController_Class/Reference/Reference.html#//apple_ref/occ/instp/UIViewController/topLayoutGuide)。


topLayoutGuide是只有在auto Layout时使用，指出屏幕内容垂直方向最高的内容显示范围。

```
@property(nonatomic, readonly, retain) id<UILayoutSupport> topLayoutGuide
```

更详细见：[topLayoutGuide](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIViewController_Class/Reference/Reference.html#//apple_ref/occ/instp/UIViewController/topLayoutGuide)

###iOS7中的status bar

iOS7中状态栏只有两种style：

```
typedef NS_ENUM(NSInteger, UIStatusBarStyle) {
    UIStatusBarStyleDefault                                     = 0, // Dark content, for use on light backgrounds
    UIStatusBarStyleLightContent     NS_ENUM_AVAILABLE_IOS(7_0) = 1, // Light content, for use on dark backgrounds
    
    UIStatusBarStyleBlackTranslucent NS_ENUM_DEPRECATED_IOS(2_0, 7_0, "Use UIStatusBarStyleLightContent") = 1,
    UIStatusBarStyleBlackOpaque      NS_ENUM_DEPRECATED_IOS(2_0, 7_0, "Use UIStatusBarStyleLightContent") = 2,
};
```

可见只剩默认（深色背景时使用）UIStatusBarStyleDefault和浅色背景时使用的UIStatusBarStyleLightContent两种style。

iOS7中我们通过ViewController重载方法返回枚举值的方法来控制状态栏的隐藏和样式

```
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}
```

并需要在Info.plist配置文件中，增加键：UIViewControllerBasedStatusBarAppearance，并设置为YES

在需要刷新状态栏样式的时候，调用[self setNeedsStatusBarAppearanceUpdate]方法即可刷新

##iOS7中UIViewController如何展示views及一些属性解释

[iOS 7 UI Transition Guide](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/AppearanceCustomization.html#//apple_ref/doc/uid/TP40013174-CH15-SW1)


####edgesForExtendedLayout

> The edgesForExtendedLayout property uses the UIRectEdge type, which specifies each of a rectangle’s four edges, in addition to specifying none and all.

>Use edgesForExtendedLayout to specify which edges of a view should be extended, regardless of bar translucency. By default, the value of this property is UIRectEdgeAll. 

即edgesForExtendedLayout是一个类型为UIExtendedEdge的属性，指定边缘要延伸的方向。默认UIRectEdgeAll，即四周边缘都延伸。

####automaticallyAdjustsScrollViewInsets

>If you don’t want a scroll view’s content insets to be automatically adjusted, set automaticallyAdjustsScrollViewInsets to NO. (The default value of automaticallyAdjustsScrollViewInsets is YES.) 

当使用UIScrollView或其子类（如UITableView）时，当automaticallyAdjustsScrollViewInsets=YES时，它会自动设置相应的内边距。UIScrollView会占据整个视图，又不会让导航栏遮盖。

####extendedLayoutIncludesOpaqueBars

>If your design uses opaque bars, refine edgesForExtendedLayout by also setting the extendedLayoutIncludesOpaqueBars property to NO. (The default value of extendedLayoutIncludesOpaqueBars is YES.) 

当Bar使用了不透明图片时，视图是否延伸至Bar所在区域，默认值时NO。YES时视图则会延伸至导航栏。

####topLayoutGuide, bottomLayoutGuide 

>The topLayoutGuide and bottomLayoutGuide properties indicate the location of the top or bottom bar edges in a view controller’s view. If bars should overlap the top or bottom of a view, you can use Interface Builder to position the view relative to the bar by creating constraints to the bottom of topLayoutGuide or to the top of bottomLayoutGuide. (If no bars should overlap the view, the bottom of topLayoutGuide is the same as the top of the view and the top of bottomLayoutGuide is the same as the bottom of the view.) Both properties are lazily created when requested. 

topLayoutGuide, bottomLayoutGuide指定了顶部或者底部的bar的边缘在UIViewController中view里的位置。

##在运行时设置status bar的颜色

在实际项目中发现使用xib（storyboard）的viewcontroller的属性定义status bar的颜色为default或者light content时，有时候会不起作用。这时候可以选择在运行时设置：即在代码中设置   

```
[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
```

