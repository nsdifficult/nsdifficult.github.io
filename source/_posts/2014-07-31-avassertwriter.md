---
layout: post
title: "使用AVAssertWriter录制音视频到文件"
date: 2014-07-31 15:06
comments: true
categories: 
---



今天写直播功能中的录制视频到文件时使用AVAssertWriter遇到一个坑。<!--more-->  

```
 if ([assetWriter canAddInput:assetWriterAudioIn]) {
     	[assetWriter addInput:assetWriterAudioIn];
        NSLog(@"add asset writer audio input.");
  } else {
        NSLog(@"Couldn't add asset writer audio input.");
        return NO;
  }
```

这句话总是报`Couldn't add asset writer audio input.` 

后来不判断直接调用`[assetWriter addInput:assetWriterAudioIn];`发现报错：  

```
[AVAssetWriter addInput:] Cannot call method when status is 1
```

发现AVAssetWriter的status为1时，是为AVAssetWriterStatusWriting。即AVAssetWriter正在写。

```
enum {
   AVAssetWriterStatusUnknown = 0,
   AVAssetWriterStatusWriting,
   AVAssetWriterStatusCompleted,
   AVAssetWriterStatusFailed,
   AVAssetWriterStatusCancelled
};
typedef NSInteger AVAssetWriterStatus;
```
就是说AVAssetWriter已经在写文件了，不能在它写文件的时候加入assetWriterAudioIn。这个问题可真够隐蔽的，而且官方文档没有任何这方面的提醒，鄙视下==   

解决这个问题的一个关键步骤是直接调用`[assetWriter addInput:assetWriterAudioIn];`


最后贴上代码：

首先初始化相机、AVCaptureVideoDataOutput、AVCaptureAudioDataOutput等：

	void  CameraSource::setupCamera(int fps, bool useFront, bool useInterfaceOrientation)
    	{
        m_fps = fps;
        m_useInterfaceOrientation = useInterfaceOrientation;
        
        
        @autoreleasepool {
            int position = useFront ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
            
            NSArray* devices = [AVCaptureDevice devices];
            for(AVCaptureDevice* d in devices) {
                if([d hasMediaType:AVMediaTypeVideo] && [d position] == position)
                {
                    m_captureDevice = d;
                    NSError* error;
                    [d lockForConfiguration:&error];
                    [d setActiveVideoMinFrameDuration:CMTimeMake(1, fps)];
                    [d setActiveVideoMaxFrameDuration:CMTimeMake(1, fps)];
                    [d unlockForConfiguration];
                }
            }
            
            AVCaptureSession* session = [[AVCaptureSession alloc] init];
            AVCaptureDeviceInput* input;
            AVCaptureVideoDataOutput* output;
            
            NSString* preset = AVCaptureSessionPresetHigh;
            if(m_usingDeprecatedMethods) {
                int mult = ceil(double(m_targetSize.h) / 270.0) * 270 ;
                switch(mult) {
                    case 270:
                        preset = AVCaptureSessionPresetLow;
                        break;
                    case 540:
                        preset = AVCaptureSessionPresetMedium;
                        break;
                    default:
                        preset = AVCaptureSessionPresetHigh;
                        break;
                }
                session.sessionPreset = preset;
            }
            m_captureSession = session;
            
            input = [AVCaptureDeviceInput deviceInputWithDevice:((AVCaptureDevice*)m_captureDevice) error:nil];
            
            output = [[AVCaptureVideoDataOutput alloc] init] ;
            
            output.videoSettings = @{(NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA) };
            if(!m_callbackSession) {
                m_callbackSession = [[sbCallback alloc] init];
            }
            
            /***音频 begin*/
            /*
             * Create audio connection
             */
            NSArray *audioDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
            AVCaptureDevice *audioDevice;
            if ([audioDevices count] > 0) {
                audioDevice = [audioDevices objectAtIndex:0];
                AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:nil];
                if ([session canAddInput:audioIn])
                    [session addInput:audioIn];
                [audioIn release];
                
                AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
                dispatch_queue_t audioCaptureQueue = dispatch_queue_create("PHONELIVE_AUDIO_QUEUE", DISPATCH_QUEUE_SERIAL);
                [audioOut setSampleBufferDelegate:((sbCallback *)m_callbackSession) queue:audioCaptureQueue];
                dispatch_release(audioCaptureQueue);
                if ([session canAddOutput:audioOut]) {
                    [session addOutput:audioOut];
                    audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
                }
                [audioOut release];
            }
            
            
            /***音频 end*/
            
            //当sampleBufferDelegate处理frame时，queue被blocked，新来的frame不处理。为YES时保存，不blocked时处理，这样占用的内存多。
            [output setAlwaysDiscardsLateVideoFrames:YES];
            videoDataOutputQueue = dispatch_queue_create("PHONELIVE_VIDEO_QUEUE", DISPATCH_QUEUE_SERIAL);
            //            [output setSampleBufferDelegate:((sbCallback*)m_callbackSession) queue:dispatch_get_global_queue(0, 0)];
            [output setSampleBufferDelegate:((sbCallback*)m_callbackSession) queue:videoDataOutputQueue];
            dispatch_release(videoDataOutputQueue);
            if([session canAddInput:input]) {
                [session addInput:input];
            }
            if([session canAddOutput:output]) {
                [session addOutput:output];
                videoConnection = [output connectionWithMediaType:AVMediaTypeVideo];
                
            }
            
            movieWritingQueue = dispatch_queue_create("PHONELIVE_WRITING_QUEUE", DISPATCH_QUEUE_SERIAL);
            
            reorientCamera();
            
            [session startRunning];
            
            if(m_useInterfaceOrientation) {
                [[NSNotificationCenter defaultCenter] addObserver:((id)m_callbackSession) selector:@selector(orientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
            } else {
                [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
                [[NSNotificationCenter defaultCenter] addObserver:((id)m_callbackSession) selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
            }
            [output release];
            
        }
    }
    
    
在didOutputSampleBuffer初始化AVAssertWriter和写文件

	- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
	{
    auto source = m_source.lock();
    
    if(source) {
        if (connection == source->videoConnection) {
            source->bufferCaptured(CMSampleBufferGetImageBuffer(sampleBuffer));
            if (source->m_isFisrtToUseCamera) {
                source->m_cameraHasBeingPreparedCallback();
                source->m_isFisrtToUseCamera = false;
            }
        }
        
        if (source->readyToRecordVideo&&source->readyToRecordAudio) {
            
            CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
            
            CFRetain(sampleBuffer);
            CFRetain(formatDescription);
            
            dispatch_async(source->movieWritingQueue, ^{
                if (connection == source->videoConnection) {
                    if (!source->m_isRecordingVideo) {
                        // Initialize the video input if this is not done yet
                        source->m_isRecordingVideo = source->setupAssetWriterVideoInput(formatDescription);
                    }
                    if (source->m_isRecordingVideo && source->m_isRecordingAudio) {
                        source->writeSampleBuffer(sampleBuffer,AVMediaTypeVideo);
                    }
                } else if (connection == source->audioConnection) {
                    if (!source->m_isRecordingAudio) {
                        // Initialize the video input if this is not done yet
                        source->m_isRecordingAudio = source->setupAssetWriterAudioInput(formatDescription);
                    }
                    if (source->m_isRecordingVideo && source->m_isRecordingAudio) {
                        source->writeSampleBuffer(sampleBuffer,AVMediaTypeAudio);
                    }
                }
                
                
                CFRelease(sampleBuffer);
                CFRelease(formatDescription);
                
            });
            
        }
    }
	}

注意，解决我遇到的坑是这句:`if (source->m_isRecordingVideo && source->m_isRecordingAudio)`，即设置两个变量标识AVAssertWriter是否加入AVCaptureVideoDataOutput和AVCaptureAudioDataOutput，在加入后才开始写文件。  

最后AVAssertWriter加入AVCaptureVideoDataOutput和AVCaptureAudioDataOutput、写文件的方法：  

	BOOL
    CameraSource::setupAssetWriterVideoInput(CMFormatDescriptionRef currentFormatDescription)
    {
        float bitsPerPixel;
        CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
        int numPixels = dimensions.width * dimensions.height;
        int bitsPerSecond;
        
        // Assume that lower-than-SD resolutions are intended for streaming, and use a lower bitrate
        if ( numPixels < (640 * 480) ) {
            bitsPerPixel = 4.05; // This bitrate matches the quality produced by AVCaptureSessionPresetMedium or Low.
        } else {
            bitsPerPixel = 11.4; // This bitrate matches the quality produced by AVCaptureSessionPresetHigh.
            
            bitsPerSecond = numPixels * bitsPerPixel;
            
            NSDictionary *videoCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      AVVideoCodecH264, AVVideoCodecKey,
                                                      [NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.height*[UIScreen mainScreen].scale], AVVideoWidthKey,
                                                      [NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.width*[UIScreen mainScreen].scale], AVVideoHeightKey,
                                                      [NSDictionary dictionaryWithObjectsAndKeys:
                                                       [NSNumber numberWithInteger:1000000], AVVideoAverageBitRateKey,
                                                       [NSNumber numberWithInteger:30], AVVideoMaxKeyFrameIntervalKey,
                                                       nil], AVVideoCompressionPropertiesKey,
                                                      nil];
            
            if ([assetWriter canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo]) {
                assetWriterVideoIn = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
                assetWriterVideoIn.expectsMediaDataInRealTime = YES;
                //                assetWriterVideoIn.transform = [self transformFromCurrentVideoOrientationToOrientation:self.referenceOrientation];
                [assetWriter addInput:assetWriterVideoIn];
                if ([assetWriter canAddInput:assetWriterVideoIn]) {
                    [assetWriter addInput:assetWriterVideoIn];
                    NSLog(@"add asset writer video input.");
                } else {
                    NSLog(@"Couldn't add asset writer video input.");
                    return NO;
                }
            } else {
                NSLog(@"Couldn't apply video output settings.");
                return NO;
            }
        }
        return YES;
    }
    
    BOOL
    CameraSource::setupAssetWriterAudioInput(CMFormatDescriptionRef currentFormatDescription)
    {
        const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
        
        size_t aclSize = 0;
        const AudioChannelLayout *currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription, &aclSize);
        NSData *currentChannelLayoutData = nil;
        
        // AVChannelLayoutKey must be specified, but if we don't know any better give an empty data and let AVAssetWriter decide.
        if ( currentChannelLayout && aclSize > 0 )
            currentChannelLayoutData = [NSData dataWithBytes:currentChannelLayout length:aclSize];
        else
            currentChannelLayoutData = [NSData data];
        
        NSDictionary *audioCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInteger:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                                  [NSNumber numberWithFloat:currentASBD->mSampleRate], AVSampleRateKey,
                                                  [NSNumber numberWithInt:64000], AVEncoderBitRatePerChannelKey,
                                                  [NSNumber numberWithInteger:currentASBD->mChannelsPerFrame], AVNumberOfChannelsKey,
                                                  currentChannelLayoutData, AVChannelLayoutKey,
                                                  nil];
        if ([assetWriter canApplyOutputSettings:audioCompressionSettings forMediaType:AVMediaTypeAudio]) {
            
            assetWriterAudioIn = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
            assetWriterAudioIn.expectsMediaDataInRealTime = YES;
            if ([assetWriter canAddInput:assetWriterAudioIn]) {
                [assetWriter addInput:assetWriterAudioIn];
                NSLog(@"add asset writer audio input.");
            } else {
                NSLog(@"Couldn't add asset writer audio input.");
                return NO;
            }
        }
        else {
            NSLog(@"Couldn't apply audio output settings.");
            return NO;
        }
        
        return YES;
    }
    void
    CameraSource::writeSampleBuffer(CMSampleBufferRef sampleBuffer,NSString *mediaType) {
        if ( assetWriter.status == AVAssetWriterStatusUnknown ) {
            
            if ([assetWriter startWriting]) {
                CMTime lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                [assetWriter startSessionAtSourceTime:lastSampleTime];
            }
            else {
                //                [self showError:[assetWriter error]];
                NSLog(@"%@",assetWriter.error);
                
            }
        }
        
        if ( assetWriter.status == AVAssetWriterStatusWriting ) {
            
            if (mediaType == AVMediaTypeVideo) {
                if (assetWriterVideoIn.readyForMoreMediaData) {
                    if (![assetWriterVideoIn appendSampleBuffer:sampleBuffer]) {
                        //                        [self showError:[assetWriter error]];
                        NSLog(@"%@",assetWriter.error);
                    }
                }
            }else if (mediaType == AVMediaTypeAudio) {
                if (assetWriterAudioIn.readyForMoreMediaData) {
                    if (![assetWriterAudioIn appendSampleBuffer:sampleBuffer]) {
                        //                        [self showError:[assetWriter error]];
                        NSLog(@"%@",assetWriter.error);
                        
                    }
                }
            }
        }
    }
    
    
参考：  
1. [AV Foundation Programming Guide](https://developer.apple.com/library/ios/documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/05_Export.html#//apple_ref/doc/uid/TP40010188-CH9-SW2)  
2. [官方demo：RosyWriter](https://developer.apple.com/library/ios/samplecode/RosyWriter/Introduction/Intro.html)