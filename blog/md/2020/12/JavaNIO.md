# Java NIO Tutorial
## 一、内容概要
Java NIO（New IO）Java中一个非传统的IO API，这意味着它是标准Java IO和Java Networking API之外的一个新的选择（实际上Java IO已经使用NIO思想重新实现了，见[这篇文章](https://blog.csdn.net/infant09/article/details/80044868)）。Java NIO相对于传统IO API提供一个不同的IO 编程模型。注意：有时NIO也是Non-blocking IO的含义。无论如何，NIO都不是传统的IO，而且，有一部分NIO API实际上也是阻塞的：比如文件API-所以说NIO是“Non-blocking”可能会有点儿轻微的误导性。
### Java NIO:Non-blocking IO
Java NIO可以让你的IO操作变的non-blocking。举个例子，一个线程可以让一个channel把数据读到buffer。当channel往buffer里读数据时，这个线程可以去做其他事情。一旦数据读完，这个线程就可以回过头来继续处理这些数据了。将buffer里的数据写到channel同理。
### Java NIO:Channels and Buffers
在标准的IO API中使用的是Byte streams和character streams。在NIO中使用的则是channels和buffers。数据总是从一个channel读到一个buffer中，或者从一个buffer中写到channel中。
### Java NIO:Selectors
Java NIO 中有一个叫“selectors”的概念。一个selector是一个可以监控多个channel事件的对象（比如：打开连接，数据到达等等）。得益于selector，一个线程就可以监控多个channel的数据。
### Java NIO Concepts
相对于老的Java IO模型，Java NIO有如下新的概念：
* Channels
* Buffers
* Scatter - Gather
* Channel to Channel Transfers
* Selectors
* FileChannel
* SocketChannel
* ServerSocketChannel
* Non-blocking Server Design
* DatagramChannel
* Pipe
* NIO vs. IO
* Path
* Files
* AsynchronousFileChannel

## 二、Java NIO 总览
Java NIO包含如下三个核心部分：
* Channels
* Buffers
* Selectors

Java NIO中的类和组件远不于此，但是我认为是这三个组件组成了Java NIO的核心API。其他类似Pipe和FileLock的组件仅仅是这三个核心组件的连接工具类。因此，这节总览中将专注于介绍这三个组件。

### Channels和Buffers
典型的，所有的NIO中的IO都从一个Channel开始。Channel类似于一个流。通过Channel数据可以读到Buffer。数据也可以从一个Buffer写到Channel里。这里有一个示意图：

![image-20201213215123354](image-20201213215123354.png)

Java NIO中Channel的核心实现有：

* FileChannel
* DatagramChannel（UDP）
* SocketChannel
* ServerSocketChannel

正如你看到的，这些Channels包括了UDP+TCP 网络IO，和文件IO。

Java NIO中Buffer的核心实现有：

* ByteBuffer
* CharBuffer
* DoubleBuffer
* FloatBuffer
* IntBuffer
* LongBuffer
* ShortBuffer

这些Buffer覆盖了我们可以发送的一些基础数据类型：byte，short，int，long，float，double和character。

Java NIO包含一个特殊的用来连接内存映射文件（memory mapped files）的buffer：MappedByteBuffer。

### selector

一个Selector允许一个线程去处理多个channel。这对于那些有很多打开的连接Connections（channels），但在每个连接仅有少量流量的应用特别有用。比如，在一个提供聊天功能的服务器里。这里有一个一个线程使用一个selector处理3个channel的示例图：

![image-20201213221736723](image-20201213221736723.png)



仅需将channel注册到selector，然后使用selector的select方法就可以使用selector了。selector方法将阻塞线程直到注册在selector上的众多channel发生了一个事件：例如新的连接被打开，接收到数据等。

## 三、Java NIO Channel

Java NIO Channels和流相似但也有些许差别：

* 你可以从Channel读数据也可以往Channel写数据，而Streams只能单向读或者写。
* Channel可以异步读写。
* Channel总是将数据读到Buffer，或从Buffer往Channel里写数据。

正如刚才所说，Channel总是将数据读到Buffer，或从Buffer往Channel里写数据。再次出示相关示意图：

![image-20201213215123354](image-20201213215123354.png)

### Channel实现

Java NIO中最重要的几个Channel实现是：

* FileChannel
* DatagramChannel
* SocketChannel
* ServerSocketChannel

FileChannel从文件里读或者往文件里写数据。

DatagramChannel通过UDP读或者写数据。

SocketChannel通过TCP读或者数据。

ServerSocketChannel允许你像一个web server那样监听TCP连接。对于每个连接就创建一个SocketChannel。

### 一个关于Channel的基础例子

这里有一个简单的例子：使用Filechannel将文件里的数据读到buffer。



```java
RandomAccessFile aFile = new RandomAccessFile("data/nio-data.txt", "rw");
    FileChannel inChannel = aFile.getChannel();

    ByteBuffer buf = ByteBuffer.allocate(48);

    int bytesRead = inChannel.read(buf);
    while (bytesRead != -1) {

      System.out.println("Read " + bytesRead);
      buf.flip();

      while(buf.hasRemaining()){
          System.out.print((char) buf.get());
      }

      buf.clear();
      bytesRead = inChannel.read(buf);
    }
    aFile.close();
```

注意buf.flip()被调用了。首先将数据读到Buffer，然后翻转（flip），再将数据读出，再接下来的章节中将会详细介绍关于Buffer的细节。

## 三、Java NIO Buffer

Java NIO Buffers总是和NIO Channels一起使用，正如之前介绍，数据是从channel读到buffer，从buffer写入channel。

一个buffer是必须的一个内存块，这个内存块你可以往里写数据，也可以往外读数据。这个内存块在Java NIO里定义的Buffer对象，它提供了一些可以方便操作这个代码块的方法。

### Buffer的基本使用

使用Buffe去读或者写数据，有四个典型的步骤：

1. 将数据写入Buffer
2. 调用buffer.flip()
3. 从Buffer读取数据
4. 调用buffer.clear()或者buffer.compact()

当你往buffer写数据时，buffer会跟踪你写了多少数据。一旦你需要读数据时，你需要使用flip()将buffer从写模式切换到读模式。在读模式中buffer允许你将读取所有数据然后写入buffer。

一旦你读取了所有数据，你需要清除buffer以将备接下来的写操作。有两种方式可以清除buffer：调用clear()或者调用compact()。clear（）方法将清空整个buffer。compact()方法仅仅清理你刚刚读取的数据。任何未读的数据都被挪到了buffer开始的地方，然后执行写操作后数据时将会写在这些未读的数据之后。

这里有一个Buffe的简单例子，使用write，flip，read和clear操作：

```java
RandomAccessFile aFile = new RandomAccessFile("data/nio-data.txt", "rw");
FileChannel inChannel = aFile.getChannel();

//create buffer with capacity of 48 bytes
ByteBuffer buf = ByteBuffer.allocate(48);

int bytesRead = inChannel.read(buf); //read into buffer.
while (bytesRead != -1) {

  buf.flip();  //make buffer ready for read

  while(buf.hasRemaining()){
      System.out.print((char) buf.get()); // read 1 byte at a time
  }

  buf.clear(); //make buffer ready for writing
  bytesRead = inChannel.read(buf);
}
aFile.close();
```

### Buffer容量，位置和极限（Buffer Capacity, Position and Limit）

一个buffer是必须的一个内存块，这个内存块你可以往里写数据，也可以往外读数据。这个内存块在Java NIO里定义的Buffer对象，它提供了一些可以方便操作这个代码块的方法。

为了理解Buffer如何工作，一个Buffer有三个属性必须熟悉：

* capacity
* position
* limit

position和limit的含义依赖于Buffer是在读模式还是写模式。而Capacity的含义则与Buffer处于何种模式无关。

![image-20201213233211394](image-20201213233211394.png)



#### Capacity

作为一个内存块，一个Buffer有一个确认的固定大小：capacity。你可以写对应capacity的诸如bytes，longs，chars到Buffer中，一旦Buffer装满后，想继续写入更多数据就只能clear或者read了（empty it ：read the data, or clear it）。

#### Position

写模式下，写数据需要指定从何处开始写入，即需指定position。positon在初始化状态为0，当写入一个诸如byte，long后，position会前进到写入数据的那个格子的下一个格子。position最大值为capacity-1。

读模式下，读数据需指定从何处开始，即需指定position。当将buffer从写模式切换到读模式时，需翻转（flip）一个Buffer，positon在flip后会重置到0。正如写数据，当读取一个诸如byte，long后，position也会前进到读取数据的那个格子的下一个格子。

#### Limit

写模式下，Buffer的limit是你可以写入多少数据：即Buffer的容量（capacity）。

当翻转（flip）缓存到读模式后，limit是可以从Buffer中读取数据的limit。因此，翻转（flip）缓存到读模式，limit被设置为写模式下的position的值。换言之，你可以读取刚刚写入的所有数据，写入的数据的数量由position标记。

### Buffer类型

Java NIO有以下几个Buffer类型：

* ByteBuffer
* MappedByteBuffer
* CharBuffer
* DoubleBuffer
* FloatBuffer
* IntBuffer
* LongBuffer
* ShortBuffer

正如所见，这些buffer的类型代表了不同的数据类型。换言之，他们让你方便使用这些buffer像使用诸如char，short，int，long，float或者double等基本类型一样。

MappedByteBuffer是一个有点特殊的类型，它是被它自己的内容覆盖的类型（翻译不好：The `MappedByteBuffer` is a bit special, and will be covered in its own text.）。

### 给Buffer分配内存

每个Buffer实现类都有一个allocate()方法用于给Buffer分配内存。如下例子展示了如何分配一个48byte容量大小的ByteBuffer。

```java
ByteBuffer buf = ByteBuffer.allocate(48);
```

分配一个1024个字符的空间的CharBuffer

```java
CharBuffer buf = CharBuffer.allocate(1024);
```

### 将数据写到buffer

将数据写到Buffer有两个办法：

1. 将数据从Channel写入Buffer
2. 通过put方法直接将数据写入Buffer

下面的代码展示了如何将数据从Channel写入Buffer

```java
int bytesRead = inChannel.read(buf); //read into buffer.
```

下面的代码展示了如何通过put方法直接将数据写入Buffer（写入127）

```java
buf.put(127);    
```

有很多其他版本的put()方法允许你实现一些特殊的写入。例如，在指定position写入，或者写入一个byte数组。通过查看JavaDoc可查看更多实现。

### flip()

flip()方法可将Buffer从写模式切换到读模式：将position设置为0，limit设置为position刚刚的位置。

换言之，position标记了正在读的位置，limit标记了有多少诸如bytes，chars被写入了buffer-而这正表示了有多少诸如bytes，chars可以读取。

### 从Buffer读取数据

有两种方式可以从Buffer读取数据

1. 将Buffer中数据读入channel
2. 使用get()方法从Buffer中直接读取数据

下面的代码展示了如何将Buffer中数据读入channel

```java
//read from buffer into channel.
int bytesWritten = inChannel.write(buf);
```

下面的代码展示了如何使用get()方法从Buffer中直接读取数据

```java
byte aByte = buf.get();    
```

Buffer有很多其他版本的get()方法允许你实现一些特殊的从buffer中读取数据。例如从指定position位置读取，或者从buffer中读取一个bytes数组。通过查看JavaDoc可查看更多实现。

### rewind()

Buffer.rewind()方法将position设置为0，这样就可以重新从开始的位置读取所有数据了。limit保持不变，依然标记了可以从Buffer中读取多少元素（诸如bytes，chars等）。

### clear()和compact()

一旦你完成了从buffer读取数据的操作，就可以调用clear()方法或者compact()方法来将Buffer为接下来的写操作做好准备。

clear()方法被调用后position被设置为0，limit被设置为capacity。换言之，Buffer被清理了，但数据并未被清理，仅仅标记了你可以从哪个位置写入数据。

如果clear()方法被调用后，Buffer仍有任何未读取的数据，这些数据会被“遗忘”，意味着你没有任何标记告诉你什么数据被读取，什么数据未被读取。

如果你还有未读取的数据，但你想在读取这些数据之前先写入数据，可以调用compact()方法而不是clear()。

compact()方法将所有未读取数据拷贝到Buffer的开始，然后将position指向最后一个未读数据的下一个cell。limit则不变，仍然指向capacity，这点和clear一样。这样Buffer就为写做好了准备，因为你不会覆盖这些未读数据。

> > TODO 这里有部分没翻译

## Java NIO Selector

Java NIO Selector是用来检测多个Java NIO Channel实例的组件，并确定哪个channel为读或者写等操作做好了准备。这样我们就可以仅使用一个线程去管理多个channels，多个网络连接。

### 为什么使用Selector？

可以使用一个线程处理多个channels意味着你可以使用更少的线程处理大量channels。实际上，你可以仅使用一个线程来处理所有的channels。线程切换对于操作系统来说代价是很昂贵的，并且每个线程都会占用一定的内存。因此使用的线程越少越好。

但是同样得记住，现代的操作系统和CPU在处理多任务方便已经变得越来越好，处理多任务的耗费也越来越小。实际上，一个CPU有多个核心，如果你不适用多任务，就有可能浪费了CPU的多核运算能力。但说回来，这已经是另一个话题了。这里我们继续讨论怎么使用一个线程，一个selector去处理多个channels。

下面这张示意图表示操作3个Channel的Selector

![image-20201213221736723](image-20201213221736723.png)

### 创建一个Selector

通过Selector.open()方法创建一个Selector：

```java
Selector selector = Selector.open();
```

### 将Channels注册到Selector

使用SelectableChannel.register()方法可将channel注册到Selector：

```java
channel.configureBlocking(false);

SelectionKey key = channel.register(selector, SelectionKey.OP_READ);
```

注册到Selector的Channel必须被设置成非阻塞模式。这意味着FileChannel不能使用Selector，因为FileChannel不能切换到非阻塞模式。但Socket Channels可以工作在非阻塞模式下。

register()的第二个参数是是一个Selector感兴趣的集合：即通过Selector想监听的那些事件。有4个事件可供监听：

1. Connect
2. Accept
3. Read
4. Write

Channel与Server连接成功为：connect Ready。一个Server socket chanel接收到一个连接为：accept Ready。一个Channel有数据做好了被读取的准备为：read Ready。一个channel做好了被写入数据的准备则为：write Ready。

有四个SectionKey常量代表了这四个事件：

1. SelectionKey.OP_CONNECT
2. SelectionKey.OP_ACCEPT
3. SelectionKey.OP_READ
4. SelectionKey.OP_WRITE

待续.......