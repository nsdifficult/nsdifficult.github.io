---
layout: post
title: "ThreadLocal"
date: 2014-06-03 19:06
comments: true
categories: 
---

##解释
Thread-local storage 是为每一个线程提供独立的变量存储的存储。  
[维基百科解释](https://en.wikipedia.org/wiki/Thread-local_storage#Java)
> Thread-local storage (TLS) is a computer programming method that uses static or global memory local to a thread.<!--more--> 

Thread-local storage有各个语言版本的实现。见[Thread-local storage](https://en.wikipedia.org/wiki/Thread-local_storage#Java)  

##Java实现：ThreadLocal

JDK 1.2的版本中就提供java.lang.ThreadLocal，ThreadLocal为解决多线程程序的并发问题提供了一种新的思路。使用这个工具类可以很简洁地编写出优美的多线程程序，ThreadLocal并不是一个Thread，而是Thread的局部变量。  

`java.lang.ThreadLocal<GeneratorSession>`  

###源代码 (只显示set和get方法)

	 public void set(T value) {  
        Thread t = Thread.currentThread();  
        ThreadLocalMap map = getMap(t);  
        if (map != null)  
            map.set(this, value);  
        else  
            createMap(t, value);  
    }  
    public T get() {  
        Thread t = Thread.currentThread();  
        ThreadLocalMap map = getMap(t);  
        if (map != null)  
            return (T)map.get(this);  
  
        // Maps are constructed lazily.  if the map for this thread  
        // doesn't exist, create it, with this ThreadLocal and its  
        // initial value as its only entry.  
        T value = initialValue();  
        createMap(t, value);  
        return value;  
    }  
  
  
###应用
 
####hibernate中的一个典型应用
 
	private static final ThreadLocal threadSession = new ThreadLocal();
    public static Session getSession() throws InfrastructureException {
        Session s = (Session) threadSession.get();
        try {
            if (s == null) {
                s = getSessionFactory().openSession();
                threadSession.set(s);
            }
        } catch (HibernateException ex) {
            throw new InfrastructureException(ex);
        }
        return s;
    }

可以看到在getSession()方法中，首先判断当前线程中有没有放进去session，如果还没有，那么通过sessionFactory().openSession()来创建一个session，再将session set到线程中，实际是放到当前线程的ThreadLocalMap这个map中，这时，对于这个session的唯一引用就是当前线程中的那个ThreadLocalMap（下面会讲到），而threadSession作为这个值的key，要取得这个session可以通过threadSession.get()来得到，里面执行的操作实际是先取得当前线程中的ThreadLocalMap，然后将threadSession作为key将对应的值取出。这个session相当于线程的私有变量，而不是public的。
显然，其他线程中是取不到这个session的，他们也只能取到自己的ThreadLocalMap中的东西。要是session是多个线程共享使用的，那还不乱套了。
试想如果不用ThreadLocal怎么来实现呢？可能就要在action中创建session，然后把session一个个传到service和dao中，这可够麻烦的。或者可以自己定义一个静态的map，将当前thread作为key，创建的session作为值，put到map中，应该也行，这也是一般人的想法，但事实上，ThreadLocal的实现刚好相反，它是在每个线程中有一个map，而将ThreadLocal实例作为key，这样每个map中的项数很少，而且当线程销毁时相应的东西也一起销毁了，不知道除了这些还有什么其他的好处。 

此段文字来自：http://www.iteye.com/topic/103804  

####实际项目的一个用处
需要对每个请求线程分配一个GeneratorSession，且要求GeneratorSession能支持高并发。使用到了ThreadLocal。

	public class GeneratorSessionFactoryImpl implements GeneratorSessionFactory {

	private ThreadLocal<GeneratorSession> generatorSessions = new ThreadLocal<GeneratorSession>();

	private Settings settings;

	public GeneratorSessionFactoryImpl(Settings settings) {
		this.settings = settings;
	}

	/**
	 * 线程安全创建GeneratorSession
	 * 
	 * @see com.trs.dev4.jdk16.cms.GeneratorSessionFactory#getCurrentSession()
	 * @since yangyu @ Apr 11, 2013
	 */
	public GeneratorSession getCurrentSession() {

		GeneratorSession generatorSession = generatorSessions.get();
		if (generatorSession == null) {
			generatorSession = new GeneratorSessionImpl(settings);
			generatorSessions.set(generatorSession);
		}
		return generatorSession;
	}

	public Settings getSettings() {
		return settings;
	}

	}
	
##Objective-C实现
在Cocoa中，每个NSThread对象都有一个独立的dictionary。

	NSMutableDictionary *dict = [[NSThread currentThread] threadDictionary];
	dict[@"A key"] = @"Some data";

参考文章：  
https://en.wikipedia.org/wiki/Thread-local_storage#C.2B.2B  
http://www.iteye.com/topic/103804