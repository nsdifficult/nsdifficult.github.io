# Objective-C的类别，类扩展与私有方法
## 类扩展

始终不明白类扩展是什么东西,今天查了下文档

>A class extension bears some similarity to a category, <!--more-->but it can only be added to a class for which you have the source code at compile time (the class is compiled at the same time as the class extension). The methods declared by a class extension are implemented in the @implementation block for the original class so you can’t, for example, declare a class extension on a framework class, such as a Cocoa or Cocoa Touch class like NSString.<br>


>Because no name is given in the parentheses, class extensions are often referred to as anonymous categories.

>Unlike regular categories, a class extension can add its own properties and instance variables to a class.

>Because no name is given in the parentheses, class extensions are often referred to as anonymous categories.

>Unlike regular categories, a class extension can add its own properties and instance variables to a class.

>the compiler will automatically synthesize the relevant accessor methods, as well as an instance variable, inside the primary class implementation.

>If you add any methods in a class extension, these must be implemented in the primary implementation for the class.

>It’s also possible to use a class extension to add custom instance variables.

按理说，类扩展中的的方法应该属于私有方法了，但是它真不是私有方法。。。

>(Btw, it's not really a private method, it's just hidden from the interface. Any outside object that knows the message signature can still call it. "Real" private methods don't exist in Objective-C.)

就是说根本就没有私有方法！根本上就是一个在interface没有声明的隐藏起来的的消息（方法）。如果其他对象知道这个消息名称（方法名称），它就可以发送这个消息（调用这个方法），不管你隐藏的多深！！！

如下面这段代码:

```
#import <Foundation/Foundation.h>
#import "Asia.h"

@interface Language : NSObject
@end

#import "Language.h"
@interface Language ()
@property(nonatomic,copy) NSString *name1;
//- (NSString *)speakHello;

@end
@implementation Language

- (NSString *)speakHello{
return @"hello!!!";
}
- (void )speakHi{
    NSLog(@"Hi!!!");
}
@end
```



```   

#import <Foundation/Foundation.h>
import "Language.h"


@interface English : Language
- (void)printName;
@end

#import "English.h"
@interface English ()
- (NSString *)speakHello;
@end
@implementation English
- (void)printName{
NSLog(@"%@",[self speakHello]);

if ([self respondsToSelector:@selector(speakHi)]) {
  [self performSelector:@selector(speakHi)];
}
;

}

@end
```   


运行printName方法，输出：

``` 
hello!!!
Hi!!!
```  

看，它首先给自己也就是English对象发送speakHello消息，结果它没有，好吧，转发给父类对象，虽然有speakHello消息，但是是在interface没有声明的，但它的确有，它响应了这个消息！

##类别

又查了下类别


>You use categories to define additional methods of an existing class—even one whose source code is unavailable to you—without subclassing. You typically use a category to add methods to an existing class, such as one defined in the Cocoa frameworks. The added methods are inherited by subclasses and are indistinguishable at runtime from the original methods of the class. You can also use categories of your own classes to:

>Distribute the implementation of your own classes into separate source files—for example, you could group the methods of a large class into several categories and put each category in a different file.  


>Declare private methods.

>You add methods to a class by declaring them in an interface file under a category name and defining them in an implementation file under the same name. The category name indicates that the methods are an extension to a class declared elsewhere, not a new class
