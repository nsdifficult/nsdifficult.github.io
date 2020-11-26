---
layout: post
title: "iOS开发中的单元测试"
date: 2013-09-03 17:06
comments: true
categories: 
--- 


##OCUnit和GHUnit
[OCUnit](www.sente.ch/software/ocunit/‎)：由Sen:te开发的Objective-C单元测试框架，自Xcode的2.1版本后集成了OCUnit。OCUnit中的测试分为两类，一类称为Logic Tests，另一类称为Application Tests。Logic Tests更倾向于所谓的白盒测试，用于测试工程中较细节的逻辑；Application Tests更倾向于黑盒测试，或接口测试，用于测试直接与用户交互的接口。  <!--more-->
[GHUnit](https://github.com/gabriel/gh-unit)：是一款Objective-C的测试框架，支持iOS工程还支持OSX的工程。GHUnit不同于OCUnit，它提供了GUI界面来操作测试用例，而且也不区分Logic Tests和Application Tests。

###增加OCUnit
OCUnit包括两部分Logic Tests和Application Tests。
在项目中添加OCUnit分两种情况： 
  
1.   建立项目时添加   
	![](/images/iosunittestingimage/iosunittesting001.png)  
	这样在项目建立时XCode便自动帮我们添加了OCUnit。  
	![](/images/iosunittestingimage/iosunittesting002.png)  
	
2.   给已有的项目添加OCUnit  
   
      向已存在的工程中添加OCUnit Logic Tests只需要添加一个类型为：“Cocoa Touch Unit Testing Bundle”的Target即可。        
   ![](/images/iosunittestingimage/iosunittesting003.jpg)    
      向已有工程中添加一个测试Target时，XCode会自动生成一个Scheme，运行单元测试用例和Build原工程需要切换不同的Scheme。如果认为切换Scheme非常麻烦，也可以在添加Target之前，在“Manage Scheme”菜单中取消“Autocreate schemes”。取消后就不需要切换了，如果想测试，直接选择TEST。      
   ![](/images/iosunittestingimage/iosunittesting008.png)     
      向已有的工程添加Application Tests。  
      * 首先添加一个类型为：“Cocoa Touch Unit Testing Bundle”的Target（与Logic Tests一致）。   
      * 然后设置Build Settings中的`Bundle Loader`为 `$(BUILT_PRODUCTS_DIR)/<app_name>.app/<app_name>`   
      ![](/images/iosunittestingimage/iosunittesting005.jpg)
            
      * 设置`Test Host`为`$(BUNDLE_LOADER)`   
      ![](/images/iosunittestingimage/iosunittesting006.jpg)  

      * 在Build Phases-Target Dependencies中添加依赖，选择主程序Target。   
      官方文档：[Xcode Unit Testing Guide](https://developer.apple.com/library/ios/documentation/DeveloperTools/Conceptual/UnitTesting/00-About_Unit_Testing/about.html#//apple_ref/doc/uid/TP40002143-CH1-SW1)   

###增加GHUnit   

*   给工程添加一个EmptyApplication Target。   
*   下载GHUnit，将GHUnitIOS.framework添加至刚才新加的target。   
*   在Build Settings中搜索“linker flags”，设置Other Linker Flags - Debug - 添加一个支持全架构和全版本SDK的标示“-ObjC -all_load”。   
*   删除刚添加的Target中的AppDelegate。修改main函数，导入GHUnitIOSAppDelegate代替原来的AppDelegate，修改UIApplicationMain的参数。  
![](/images/iosunittestingimage/iosunittesting009.png)
##OCMock   
OCMock是针对Objective-C的一个用来模拟对象的框架  

*   下载[OCMock](http://ocmock.org/)
*   在原始工程目录下创建Libraries文件夹，将下载的libOCMock.a和OCMock文件夹添加至其中。   
![](/images/iosunittestingimage/iosunittesting010.png)   
*   在 GHUnitTest 工程中新建名为 Libraries 的 group，导入libOCMock.a 和目录 OCMock，注意 target 是 Tests。
*   设置 Tests 的 Build Setting。让 Libray Search Paths 包含 $(SRCROOT)/Libraries。   
![](/images/iosunittestingimage/iosunittesting012.jpg)
*   在 Header Search Paths 中增加 $(SRCROOT)/Libraries。   
![](/images/iosunittestingimage/iosunittesting013.jpg)
*   更多OCMock安装与介绍见[OCMock](http://ocmock.org/)   
 
##OCHamcrest   

Hamcrest是比较流行的匹配引擎，他提供了很多自带的匹配，同时也支持自定义匹配。   
同时它也支持Java，Python，Ruby，Objective-C， PHP， Erlang   
 
###添加OCHamcrest
*   从[qualitycoding](http://qualitycoding.org/resources/)下载或者从Github下载源代码编译获得OCHamcrestIOS.framework。   
*   将OCHamcrestIOS.framework添加至tests的target。   

##GHUnit+OCHamcrest+OCMock完整的代码例子
```
#import <Foundation/Foundation.h>
#import <GHUnitIOS/GHUnit.h>


@interface OCMockSampleTest : GHTestCase

@end
```

```
#import "OCMockSampleTest.h"
#import <OCMock/OCMock.h>
#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
@implementation OCMockSampleTest

- (void)testEquals
{
    NSString * str1 = [NSString stringWithFormat:@"dfdf"];
    NSString * str2 = [NSString stringWithFormat:@"dfdf"];
    assertThat(str1, equalTo(str2));
}
- (void)testStub {
    
    id mock = [OCMockObject mockForClass:[NSString class]];
    
    [[[mock stub] andReturn:@"testStub"] substringFromIndex:1];
    
    NSString *returnStr = [mock substringFromIndex:1];
    
    HC_assertThat(returnStr, equalTo(@"testStub"));
    
}
@end
```  





