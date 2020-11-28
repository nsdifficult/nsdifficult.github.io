# 音视频边播放边下载技术调研及问题

## 需求
实现在音视频播放的时候即进行缓冲，即边播放边下载。
## 技术介绍
思路来自http://www.cnblogs.com/zhouguixin/p/3139522.html。要点是在先开一个下载的线程下载视频文件，然后在本地建一个server，然后拼接一个url给播放器。
## 代码实现中遇到的问题
### 现象
点击播放，MPMovicePlayerController报错，错误为： 
``` objective-C
错误日志
2013-06-27 18:49:28.727 TibetVoice[7748:c07] {
    MPMoviePlayerPlaybackDidFinishReasonUserInfoKey = 1;
    error = "Error Domain=MediaPlayerErrorDomain Code=-11828 \"Cannot Open\" UserInfo=0x9246dc0 {NSLocalizedDescription=Cannot Open}";
}
```  
### 分析1
使用的断点续传的开源库是AFDownloadRequestOperation，它将缓冲文件保存的文件名没有后缀，后来想到缓冲文件需要和原始文件一致，更改缓冲文件命名方式为：
```
更改命名规则
NSString *md5URLString = [[self.targetPath lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //NSString *md5URLString = [NSString stringWithFormat:@"%@",[[self class] md5StringForString:self.targetPath]];
tempPath = [[[self class] cacheFolder] stringByAppendingPathComponent:md5URLString]; 

```
更改后发现视频还是不能报错，错误为：
```
错误日志
2013-06-27 18:57:08.870 TibetVoice[7808:c07] {
    MPMoviePlayerPlaybackDidFinishReasonUserInfoKey = 1;
    error = "Error Domain=MediaPlayerErrorDomain Code=-11800 \"The operation could not be completed\" UserInfo=0x914be70 {NSLocalizedDescription=The operation could not be completed}";
}

```
### 分析2
边播放边下载的实现方式来源于[这篇文章](http://www.cnblogs.com/zhouguixin/p/3139522.html)，文章中有一段：
#### 解释
是有一点需要自己实现：当httpserver接受到MPMoviePlayerController的请求时，server要先返回一个请求包含了整个
视频文件的大小。然后MPMoviePlayerController才会不断请求本地的服务器取数据。我的实现是这样的。当要比方某个视频文件的时候，
先开启一个request去下载，当收到文件总大小的时候，存到本地的一个dictionary中，request继续下载，然后打开
localserver，拼一个本地url给player，让他自动播放。当localserver收到请求时，根据要请求的文件去本地读文件的实际大
小，返回给player，然后player就可以播放了。
这段开始看的不明就里，后来在google上搜到[这篇文章](https://groups.google.com/forum/#%21topic/cocoahttpserver/-da-UI44w0Y)，里面有一段话：
>解释
Hello Robbiehanson!
Thanks for your works!
I'm implement your project to play video streaming. In method "-
(NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:
(NSString *)path" i'm using HTTPAsyncFileResponse and set fileLength
of file on server. But video is playing with no sound. So what was the
reason?
Thanks!.

明白了要把cocoahttpserver(https://github.com/robbiehanson/CocoaHTTPServer)中的设置读取文件大小的代码，让本地服务器以视频原始文件大小去读：

修改读取文件的大小
```
//fileLength = (UInt64)[[fileAttributes objectForKey:NSFileSize] unsignedLongLongValue];
  fileLength = [FileTools fileSizeWithUrl:filePath];

```
再运行，发现能播放了

## 播放mp4流和hls流问题
### mp4
播放mp4正常
### m3u8
点击播放，MPMovicePlayerController报错，错误为：
```
错误日志
2013-06-27 19:15:18.372 TibetVoice[7885:c07] Error: Error Domain=NSCocoaErrorDomain Code=516 "The operation couldn’t be completed.
```

### 分析
到虚拟机的应用目录下看到本地有一个m3u8文件，打开发现是：

```
m3u8
#EXTM3U
#EXT-X-TARGETDURATION:10
#EXT-X-MEDIA-SEQUENCE:0
#EXTINF:10, no desc
fileSequence0.ts
#EXTINF:10, no desc
fileSequence1.ts
#EXTINF:10, no desc
fileSequence2.ts
#EXTINF:10, no desc
fileSequence3.ts
#EXTINF:10, no desc
fileSequence4.ts
#EXTINF:10, no desc
fileSequence5.ts
#EXTINF:10, no desc
fileSequence6.ts
#EXTINF:10, no desc
fileSequence7.ts
#EXTINF:10, no desc
fileSequence8.ts
```

即m3u8只是指向很多ts文件的一个文件列表，当然不能播放。如果需要想要实现对HTTP LIVE STREAMING (hls)的边播放边下载，还需要解析这个索引文件，然后再分别下载，再组装成一个视频文件然后播放，当然，这就不是边播放边下载了。

例子见：[DownloadWhilePlaying](https://github.com/nsdifficult/DownloadWhilePlaying)