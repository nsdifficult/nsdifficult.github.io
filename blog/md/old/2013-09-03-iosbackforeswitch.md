# iOS开发笔记-怎样在UIViewController中判断程序前后台切换

##概述   

如果程序支持后台运行，当程序从在前后台切换时会需要保存一些数据或者更新视图。这时候就需要UIViewController知道程序的前后台切换时得事件。<!--more-->
##需求   
  
程序支持后台下载，当用户停止在下载管理界面时，然后用户点击home键使程序进入后台运行，等用户返回到程序时，下载管理界面需要显示最新的下载进度。  
##实现  
使用通知。

```   
	//增加监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasGoneInForeground:)
                                         	name:UIApplicationWillEnterForegroundNotification
                                               object:nil];  
    //别忘了删除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];   
```
   
```
UIApplicationDidEnterBackgroundNotification  //进入后台
UIApplicationWillEnterForegroundNotification //回到程序
```