---
layout: post
title: "设计模式之模板方法模式"
date: 2014-07-29 19:06
comments: true
categories: 
---

##定义
模板方法模式定义了一个算法的步骤，并允许次类别为一个或多个步骤提供其实践方式。让次类别在不改变算法架构的情况下，重新定义算法中的某些步骤。在软件工程中，它是一种软件设计模式，和C++模板没有关连。<!--more-->  
模板方法模式需要开发抽象类和具体子类的设计师之间的协作。一个设计师负责给出一个算法的轮廓和骨架，另一些设计师则负责给出这个算法的各个逻辑步骤。代表这些具体逻辑步骤的方法称做基本方法(primitive method)；而将这些基本方法汇总起来的方法叫做模板方法(template method)，这个设计模式的名字就是从此而来。  

模板方法包括两个角色：

1. 抽象模板：包括具体方法（具体算法步骤）和基本方法（包括：抽象方法、具体方法、钩子方法）
2. 具体模板：实现父类即抽象模板的一个或者多个抽象方法。每个具体模板角色都可以给出这些抽象方法（也就是算法的组成步骤）的不同实现，从而使得顶级逻辑的实现各不相同。 

##模板方法和基本方法

###模板方法

一个模板方法是定义在抽象类中的，把基本操作方法组合在一起形成一个总算法或一个总行为的方法。  
一个抽象类可以有任意多个模板方法，而不限于一个。每一个模板方法都可以调用任意多个具体方法。  

###基本方法

基本方法又可以分为三种：抽象方法(Abstract Method)、具体方法(Concrete Method)和钩子方法(Hook Method)。  

* 抽象方法：一个抽象方法由抽象类声明，由具体子类实现。在Java语言里抽象方法以abstract关键字标示。
* 具体方法：一个具体方法由抽象类声明并实现，而子类并不实现或置换。
* 钩子方法：一个钩子方法由抽象类声明并实现，而子类会加以扩展。通常抽象类给出的实现是一个空实现，作为方法的默认实现。

###默认钩子方法
一个钩子方法常常由抽象类给出一个空实现作为此方法的默认实现。这种空的钩子方法叫做“Do Nothing Hook”。显然，这种默认钩子方法在缺省适配模式里面已经见过了，一个缺省适配模式讲的是一个类为一个接口提供一个默认的空实现，从而使得缺省适配类的子类不必像实现接口那样必须给出所有方法的实现，因为通常一个具体类并不需要所有的方法。  

##命名规则
钩子方法的名字应当以do开始，这是熟悉设计模式的Java开发人员的标准做法。在上面的例子中，钩子方法hookMethod()应当以do开头；在HttpServlet类中，也遵从这一命名规则，如doGet()、doPost()等方法。

##一个简单的例子

抽象模板

	public abstract class BeverageMake {
	// final可以防止子类更改覆盖该算法，这样可以保证算法步骤不被破坏
	public final void prepareRecipe() {
		boilWater();
		brew();
		pourInCup();
		if (hookCondiments())
			addCondiments();
	}

	abstract void brew();

	abstract void addCondiments();

	// 烧水
	public void boilWater() {
		System.out.println("Now start to boiling water");
	}

	// 饮料导入杯子汇总
	public void pourInCup() {
		System.out.println("pour the beverage into the cup");
	}

	// 加入了钩子，来让子类决定是否执行该步骤
	/**
	 * 模板方法中挂钩：
	 * 当在模板方法中某一些步骤是可选的时候，也就是该步骤不一定要执行，
	 * 可以由子类来决定是否要执行，则此时就需要用上钩子。
	 * 钩子是一种被声明在抽象类中的方法，但一般来说它只是空的或者具有默认值，
	 * 子类可以实现覆盖该钩子，来设置算法步骤的某一步骤是否要执行。
	 * 钩子可以让子类实现算法中可选的部分，
	 * 让子类能够有机会对模板方法中某些一即将发生的步骤做出反应。
	 * 重写上面的代码：
	 * 这次茶叶泡好后，加不加东西由子类去决定。
	 * @return
	 */
	public boolean hookCondiments() {
		return true;
	}
	}

具体模板

	public class Tea extends BeverageMake {

	@Override
	void brew() {
		// TODO Auto-generated method stub
		System.out.println("boil the tea in the water");
	}

	@Override
	void addCondiments() {
		// TODO Auto-generated method stub
		System.out.println("put some condiments into the tea");
	}

	// 设置不需要加饮料，这样就可以控制算法的某一个步骤不执行
	@Override
	public boolean hookCondiments() {
		return false;
	}
	}

##模板方法模式在Servlet中的应用
service方法为模板方法。doGet()和doPost()等以do开头的方法为基本方法类别中的钩子方法。  

	protected void service(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException {

        String method = req.getMethod();

        if (method.equals(METHOD_GET)) {
            long lastModified = getLastModified(req);
            if (lastModified == -1) {
                // servlet doesn't support if-modified-since, no reason
                // to go through further expensive logic
                doGet(req, resp);
            } else {
                long ifModifiedSince = req.getDateHeader(HEADER_IFMODSINCE);
                if (ifModifiedSince < (lastModified / 1000 * 1000)) {
                    // If the servlet mod time is later, call doGet()
                    // Round down to the nearest second for a proper compare
                    // A ifModifiedSince of -1 will always be less
                    maybeSetLastModified(resp, lastModified);
                    doGet(req, resp);
                } else {
                    resp.setStatus(HttpServletResponse.SC_NOT_MODIFIED);
                }
            }

        } else if (method.equals(METHOD_HEAD)) {
            long lastModified = getLastModified(req);
            maybeSetLastModified(resp, lastModified);
            doHead(req, resp);

        } else if (method.equals(METHOD_POST)) {
            doPost(req, resp);
            
        } else if (method.equals(METHOD_PUT)) {
            doPut(req, resp);        
            
        } else if (method.equals(METHOD_DELETE)) {
            doDelete(req, resp);
            
        } else if (method.equals(METHOD_OPTIONS)) {
            doOptions(req,resp);
            
        } else if (method.equals(METHOD_TRACE)) {
            doTrace(req,resp);
            
        } else {
            //
            // Note that this means NO servlet supports whatever
            // method was requested, anywhere on this server.
            //

            String errMsg = lStrings.getString("http.method_not_implemented");
            Object[] errArgs = new Object[1];
            errArgs[0] = method;
            errMsg = MessageFormat.format(errMsg, errArgs);
            
            resp.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED, errMsg);
        }
    }

##模板方法模式的另一种实现方式：回调函数

通过回调在接口中定义的方法，调用到具体的实现类中的 方法，其本质是利用Java的动态绑定技术，在这种实现中，可以不把实现类写成单独的类，而使用内部类或匿名内部类来实现回调方法。   

###一个简单的例子
设想一个简单的应用场景：  

1. 一个程序要从xml、数据库、txt、网络接口等获取数据：readData()  
2. 然后处理数据：`System.out.println("处理数据"); `  
3. 最后导出处理后的数据到xml、数据库、txt、网络等：exportData()  

```java
public class Abc {

	public Abc(ReadData readData) {
		schedule(readData);
	}

	public static void main(String[] args) {

		// 内部类方式
		schedule(new XMLReadData());

		/*
		 * 使用类似java中的thread方式 new Thread(new Runnable() {
		 * 
		 * @Override public void run() {
		 * 
		 * 
		 * } });
		 */
		new Abc(new ReadData() {

			@Override
			public void readData() {
				// TODO Auto-generated method stub

			}

			@Override
			public void exportData() {
				// TODO Auto-generated method stub

			}

		});

		// 匿名内部类方式
		schedule(new ReadData() {

			@Override
			public void readData() {
				System.out.println("从网上读");

			}

			@Override
			public void exportData() {
				// TODO Auto-generated method stub

			}

		});

	}

	public static void schedule(ReadData readData) {
		readData.readData();
		System.out.println("处理数据");
		readData.exportData();
	}
}

interface ReadData {
	void readData();

	void exportData();

} // 内部类方式

class DBReadData implements ReadData {

	@Override
	public void readData() {
		System.out.println("从数据库中读");
	}

	@Override
	public void exportData() { // TODO Auto-generated method stub

	}

}

class XMLReadData implements ReadData {

	@Override
	public void readData() {
		System.out.println("从xml中读");
	}

	@Override
	public void exportData() { // TODO Auto-generated method stub

	}

}

class TextReadData implements ReadData {

	@Override
	public void readData() {
		System.out.println("从text中读");
	}

	@Override
	public void exportData() { // TODO Auto-generated method stub

	}

}
```


注意两点：  

1. 可以使用内部类与匿名内部类两种方式实现模板方法模式  
2. 注意代码中的模仿Thread的方式：  

		new Thread(new Runnable() {
			
			@Override
			public void run() {
				
				
			}
		});


###实际项目中的一个应用（仅贴上模板方法）

	/**
	 * 缓存查询的模板，如果缓存中有数据，从缓存中取得
	 * 
	 * 如果缓存中没有，将调用线程查询数据库逻辑，将结果缓存起来
	 * 
	 * 方便编写 缓存操作代码，避免重复逻辑
	 * 
	 * @param cachedOperationCallback
	 *            回调函数
	 * @return
	 * @since yangyu @ Apr 12, 2013
	 */
	public Object obtainCachedData(CacheProvider assignedCacheProvider, String key, int expr,
			final CachedOperationCallback cachedOperationCallback) {
		
		if (assignedCacheProvider == null) {
			assignedCacheProvider = cacheProvider;
		}
		
		CachedResult cachedObject = null;
		rwl.readLock().lock();
		cachedObject = assignedCacheProvider.get(key);
		if (cachedObject.notExist()) {
			rwl.readLock().unlock();
			rwl.writeLock().lock();
			try {
				if (cachedObject.notExist()) {
					Object dbObject = cachedOperationCallback.doTakeCachingData();
					assignedCacheProvider.set(key, dbObject, expr);
					cachedObject = new CachedResult(dbObject);
					if(LOG.isDebugEnabled()){
						LOG.debug("Cached data from database key:" + key);
					}
				}
			} finally {
				rwl.writeLock().unlock();
			}
		} else {
			rwl.readLock().unlock();
		}

		return cachedObject.getResultObject();
	}

##两种实现方式的比较

1. 模板方法模式借助于继承，对抽象方法在子类中进行扩展或实现，是在编译期间静态决定的，是类级关系。使用Java回调方法，利用动态绑定技术在运行期间动态决定的，是对象级的关系。

2. 使用回调机制会更灵活，因为Java是单继承的，如果使用继承的方式，对于子类而言，今后就不能继承其它对象了。而使用回调，是基于接口的，方便扩展。 另外，如果有多个子类都要使用模板方法，则所有的子类都要实现模板方法，无形中增多了子类的个数。

3. 使用模板方法模式使用继承方式会更简单点，因为父类提供了实现的方法，子类如果不想扩展，那就不用管。如果使用回调机制，回调的接口需要把所有可能被扩展的 方法都定义进去，这就导致实现的时候，不管你要不要扩展，你都要实现这个方法，哪怕你什么都不做，只是转调模板中已有的实现，都要写出来。 

##参考文章：   

1. http://kim-miao.iteye.com/blog/1669310  
2. http://www.cnblogs.com/java-my-life/archive/2012/05/14/2495235.html