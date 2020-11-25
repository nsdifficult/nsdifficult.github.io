---
layout: post
title: "音视频边播放边下载技术调研及问题"
date: 2013-08-17 21:06
comments: true
categories: 
---
<h1 id="id-(2013-06-27)音视频边播放边下载技术调研及问题-介绍">介绍</h1><!--more-->
<h2 id="id-(2013-06-27)音视频边播放边下载技术调研及问题-需求">需求</h2>
实现在音视频播放的时候即进行缓冲，即边播放边下载。
<h2 id="id-(2013-06-27)音视频边播放边下载技术调研及问题-技术介绍">技术介绍</h2>
思路来自<a href="http://www.cnblogs.com/zhouguixin/p/3139522.html" rel="nofollow">http://www.cnblogs.com/zhouguixin/p/3139522.html</a>。要点是在先开一个下载的线程下载视频文件，然后在本地建一个server，然后拼接一个url给播放器。
<h1 id="id-(2013-06-27)音视频边播放边下载技术调研及问题-代码实现中遇到的问题">代码实现中遇到的问题</h1>
<h2 id="id-(2013-06-27)音视频边播放边下载技术调研及问题-现象">现象</h2>
点击播放，MPMovicePlayerController报错，错误为：
<div>
<div><strong>错误日志</strong></div>
<div>
<div>
<div id="highlighter_886016">
<table border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td>
<div title="Hint: double-click to select code">
<div><code>2013</code><code>-</code><code>06</code><code>-</code><code>27</code> <code>18</code><code>:</code><code>49</code><code>:</code><code>28.727</code> <code>TibetVoice[</code><code>7748</code><code>:c07] {</code></div>
<div><code>    </code><code>MPMoviePlayerPlaybackDidFinishReasonUserInfoKey = </code><code>1</code><code>;</code></div>
<div><code>    </code><code>error = </code><code>"Error Domain=MediaPlayerErrorDomain Code=-11828 \"Cannot Open\" UserInfo=0x9246dc0 {NSLocalizedDescription=Cannot Open}"</code><code>;</code></div>
<div><code>}</code></div>
</div></td>
</tr>
</tbody>
</table>
</div>
</div>
</div>
</div>
<h2 id="id-(2013-06-27)音视频边播放边下载技术调研及问题-分析1">分析1</h2>
使用的断点续传的开源库是<a href="https://github.com/steipete/AFDownloadRequestOperation" rel="nofollow">AFDownloadRequestOperation</a>，它将缓冲文件保存的文件名没有后缀，后来想到缓冲文件需要和原始文件一致，更改缓冲文件命名方式为：
<div>
<div><strong>更改命名规则</strong></div>
<div>
<div>
<div id="highlighter_139116">
<table border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td>
<div title="Hint: double-click to select code">
<div><code>NSString *md5URLString = [[self.targetPath lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];</code></div>
<div><code>        </code><code>//NSString *md5URLString = [NSString stringWithFormat:@"%@",[[self class] md5StringForString:self.targetPath]];</code></div>
<div><code>        </code><code>tempPath = [[[self </code><code>class</code><code>] cacheFolder] stringByAppendingPathComponent:md5URLString]; </code></div>
</div></td>
</tr>
</tbody>
</table>
</div>
</div>
</div>
</div>
更改后发现视频还是不能报错，错误为：
<div>
<div><strong>错误日志</strong></div>
<div>
<div>
<div id="highlighter_134531">
<table border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td>
<div title="Hint: double-click to select code">
<div><code>2013</code><code>-</code><code>06</code><code>-</code><code>27</code> <code>18</code><code>:</code><code>57</code><code>:</code><code>08.870</code> <code>TibetVoice[</code><code>7808</code><code>:c07] {</code></div>
<div><code>    </code><code>MPMoviePlayerPlaybackDidFinishReasonUserInfoKey = </code><code>1</code><code>;</code></div>
<div><code>    </code><code>error = </code><code>"Error Domain=MediaPlayerErrorDomain Code=-11800 \"The operation could not be completed\" UserInfo=0x914be70 {NSLocalizedDescription=The operation could not be completed}"</code><code>;</code></div>
<div><code>}</code></div>
</div></td>
</tr>
</tbody>
</table>
</div>
</div>
</div>
</div>
<h2 id="id-(2013-06-27)音视频边播放边下载技术调研及问题-分析2">分析2</h2>
边播放边下载的实现方式来源于<a href="http://www.cnblogs.com/zhouguixin/p/3139522.html" rel="nofollow">http://www.cnblogs.com/zhouguixin/p/3139522.html</a>，文章中有一段：
<div>
<div><strong>解释</strong></div>
<div>
<div>
<div id="highlighter_34034">
<table border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td>
<div title="Hint: double-click to select code">
<div><code>是有一点需要自己实现：当httpserver接受到MPMoviePlayerController的请求时，server要先返回一个请求包含了整个</code></div>
<div><code>视频文件的大小。然后MPMoviePlayerController才会不断请求本地的服务器取数据。我的实现是这样的。当要比方某个视频文件的时候，</code></div>
<div><code>先开启一个request去下载，当收到文件总大小的时候，存到本地的一个dictionary中，request继续下载，然后打开</code></div>
<div><code>localserver，拼一个本地url给player，让他自动播放。当localserver收到请求时，根据要请求的文件去本地读文件的实际大</code></div>
<div><code>小，返回给player，然后player就可以播放了。</code></div>
</div></td>
</tr>
</tbody>
</table>
</div>
</div>
</div>
</div>
这段开始看的不明就里，后来在google上搜到<a href="https://groups.google.com/forum/#%21topic/cocoahttpserver/-da-UI44w0Y" rel="nofollow">这篇文章</a>，里面有一段话：
<div>
<div><strong>解释</strong></div>
<div>
<div>
<div id="highlighter_885035">
<table border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td>
<div title="Hint: double-click to select code">
<div><code>Hello Robbiehanson!</code></div>
<div></div>
<div><code>Thanks </code><code>for</code> <code>your works!</code></div>
<div></div>
<div><code>I'm implement your project to play video streaming. In method "-</code></div>
<div></div>
<div><code>(NSObject&lt;HTTPResponse&gt; *)httpResponseForMethod:(NSString *)method URI:</code></div>
<div></div>
<div><code>(NSString *)path" i'm using HTTPAsyncFileResponse and set fileLength</code></div>
<div></div>
<div><code>of file on server. But video is playing with no sound. So what was the</code></div>
<div></div>
<div><code>reason?</code></div>
<div></div>
<div><code>Thanks!.</code></div>
</div></td>
</tr>
</tbody>
</table>
</div>
</div>
</div>
</div>
明白了要把<a href="https://github.com/robbiehanson/CocoaHTTPServer" rel="nofollow">cocoahttpserver</a>中的设置读取文件大小的代码，让本地服务器以视频原始文件大小去读：
<div>
<div><strong>修改读取文件的大小</strong></div>
<div>
<div>
<div id="highlighter_39416">
<table border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td>
<div title="Hint: double-click to select code">
<div><code>//fileLength = (UInt64)[[fileAttributes objectForKey:NSFileSize] unsignedLongLongValue];</code></div>
<div><code>  </code><code>fileLength = [FileTools fileSizeWithUrl:filePath];</code></div>
</div></td>
</tr>
</tbody>
</table>
</div>
</div>
</div>
</div>
再运行，发现能播放了
<h1 id="id-(2013-06-27)音视频边播放边下载技术调研及问题-播放mp4流和hls流问题">播放mp4流和hls流问题</h1>
<h2 id="id-(2013-06-27)音视频边播放边下载技术调研及问题-mp4">mp4</h2>
播放mp4正常
<h2 id="id-(2013-06-27)音视频边播放边下载技术调研及问题-m3u8">m3u8</h2>
点击播放，MPMovicePlayerController报错，错误为：
<div>
<div><strong>错误日志</strong></div>
<div>
<div>
<div id="highlighter_46561">
<table border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td>
<div title="Hint: double-click to select code">
<div><code>2013</code><code>-</code><code>06</code><code>-</code><code>27</code> <code>19</code><code>:</code><code>15</code><code>:</code><code>18.372</code> <code>TibetVoice[</code><code>7885</code><code>:c07] Error: Error Domain=NSCocoaErrorDomain Code=</code><code>516</code> <code>"The operation couldn’t be completed.</code></div>
</div></td>
</tr>
</tbody>
</table>
</div>
</div>
</div>
</div>
<h3 id="id-(2013-06-27)音视频边播放边下载技术调研及问题-分析">分析</h3>
到虚拟机的应用目录下看到本地有一个m3u8文件，打开发现是：
<div>
<div><strong>m3u8</strong></div>
<div>
<div>
<div id="highlighter_810498">
<table border="0" cellspacing="0" cellpadding="0">
<tbody>
<tr>
<td>
<div title="Hint: double-click to select code">
<div><code>#EXTM3U</code></div>
<div><code>#EXT-X-TARGETDURATION:</code><code>10</code></div>
<div><code>#EXT-X-MEDIA-SEQUENCE:</code><code>0</code></div>
<div><code>#EXTINF:</code><code>10</code><code>, no desc</code></div>
<div><code>fileSequence0.ts</code></div>
<div><code>#EXTINF:</code><code>10</code><code>, no desc</code></div>
<div><code>fileSequence1.ts</code></div>
<div><code>#EXTINF:</code><code>10</code><code>, no desc</code></div>
<div><code>fileSequence2.ts</code></div>
<div><code>#EXTINF:</code><code>10</code><code>, no desc</code></div>
<div><code>fileSequence3.ts</code></div>
<div><code>#EXTINF:</code><code>10</code><code>, no desc</code></div>
<div><code>fileSequence4.ts</code></div>
<div><code>#EXTINF:</code><code>10</code><code>, no desc</code></div>
<div><code>fileSequence5.ts</code></div>
<div><code>#EXTINF:</code><code>10</code><code>, no desc</code></div>
<div><code>fileSequence6.ts</code></div>
<div><code>#EXTINF:</code><code>10</code><code>, no desc</code></div>
<div><code>fileSequence7.ts</code></div>
<div><code>#EXTINF:<code></code></code><code>10</code><code>, no desc</code></div>
<div><code>fileSequence8.ts</code></div>
</div></td>
</tr>
</tbody>
</table>
</div>
</div>
</div>
</div>
即m3u8只是指向很多ts文件的一个文件列表，当然不能播放。如果需要想要实现对HTTP LIVE STREAMING (hls)的边播放边下载，还需要解析这个索引文件，然后再分别下载，再组装成一个视频文件然后播放，当然，这就不是边播放边下载了。   

例子见：[DownloadWhilePlaying](https://github.com/nsdifficult/DownloadWhilePlaying)