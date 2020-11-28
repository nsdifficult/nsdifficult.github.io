---
layout: post
title: "iOS中音频播放之Audio Queue Services"
date: 2014-1-28 17:06
comments: true
categories: 

---

## Audio Queue Services介绍
Audio Queue Services是[Audio Toolbox](https://developer.apple.com/library/ios/documentation/MusicAudio/Reference/CAAudioTooboxRef/_index.html)库中的一部分。<!--more-->Audio toolbox包括：  

[Audio Converter Services](https://developer.apple.com/library/ios/documentation/MusicAudio/Reference/AudioConverterServicesReference/Reference/reference.html#//apple_ref/doc/uid/TP40007943)  
[Audio File Services](https://developer.apple.com/library/ios/documentation/MusicAudio/Reference/AudioFileConvertRef/Reference/reference.html#//apple_ref/doc/uid/TP40006072)  
[Audio File Stream Services](https://developer.apple.com/library/ios/documentation/MusicAudio/Reference/AudioStreamReference/Reference/reference.html#//apple_ref/doc/uid/TP40006162)  
[Audio Format Services](https://developer.apple.com/library/ios/documentation/AudioToolbox/Reference/AudioFormatServicesReference/Reference/reference.html#//apple_ref/doc/uid/TP40007286)  
[Audio Queue Services](https://developer.apple.com/library/ios/documentation/MusicAudio/Reference/AudioQueueReference/Reference/reference.html#//apple_ref/doc/uid/TP40005117)  
[Audio Session Services](https://developer.apple.com/library/ios/documentation/AudioToolbox/Reference/AudioSessionServicesReference/Reference/reference.html#//apple_ref/doc/uid/TP40007915)  
[Audio Unit Processing Graph Services](https://developer.apple.com/library/ios/documentation/AudioToolbox/Reference/AUGraphServicesReference/Reference/reference.html#//apple_ref/doc/uid/TP40007289)  
[Extended Audio File Services](https://developer.apple.com/library/ios/documentation/MusicAudio/Reference/ExtendedAudioFileServicesReference/Reference/reference.html#//apple_ref/doc/uid/TP40007912)  
[System Sound Services](https://developer.apple.com/library/ios/documentation/AudioToolbox/Reference/SystemSoundServicesReference/Reference/reference.html#//apple_ref/doc/uid/TP40007916)  


### Audio Queue Services是什么？
Audio Queue Services提供一个在iOS和Mac OS X上直接、低开销的方式去记录和播放音频。它被推荐作为播放和记录音频的技术。Audio Queue Services允许你使用下面的格式来记录和播放音频：  

* Linear PCM（线性PCM：主要特点为未经过任何编码和压缩处理）
* 任何你开发的平台原生支持的压缩格式
* 任何用户自己安装codec（编码解码器）对应的格式  


Audio Queue Services是高层的技术。它允许你使用硬件（如麦克风和扬声器）记录和播放音频而不需要相关硬件知识。它也允许你使用复杂的codec（编码解码器）而不需要了解codecs如何工作。   

同时Audio Queue Services支持一些高级特性。它提供细微的时间控制来支持预定播放和同步。你可以使用它来同步多个音频队列（Audio Queues）和同步音频和视频的播放。  


## Audio Queue Services结构

Audio Queue Services包括：  

* 一系列音频队列缓存（audio queue buffers），每个缓存都临时保存着音频数据
* 一个音频缓存队列（A buffer queue）
* 一个由你写的音频队列回调函数  



## 使用Audio Queue Services播放本地音频

1. 定义一个管理队列状态、音频格式、文件路径等信息的结构。
2. 编写音频队列的回调函数来执行实际的播放。
3. 决定队列缓存的适当大小（通常设置下限来避免频繁访问磁盘）。
4. 打开音频文件，设置音频数据格式。
5. 创建音频队列，并配置。
6. 给音频队列分配内存，并入队。告诉音频队列开始播放。当播放完成后，回调函数回告诉音频队列停止。
7. 销毁音频队列。释放资源。



## 一些链接
[Audio Queue Services Programming Guide 官方指南](https://developer.apple.com/library/ios/documentation/MusicAudio/Conceptual/AudioQueueProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40005343-CH1-SW1)  
[Audio Queue Services Programming Guide 中文翻译](http://blog.csdn.net/jiangyiaxiu/article/details/9190059)  
[Audio Queue Services Programming Guide 官方例子：SpeakHere](https://developer.apple.com/library/ios/samplecode/SpeakHere/Introduction/Intro.html)

 
