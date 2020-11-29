---
layout: post
title: "iPhone开发图片尺寸"
date: 2014-09-02 18:06
comments: true
categories: 
---
# iPhone开发图片尺寸
## 说明
（iOS8不适用了）
###关于系统
建议支持iOS7以上，目前iOS7占比91%。关于占比，见[官方说明](https://developer.apple.com/support/appstore/)。<!--more-->

## 图标尺寸
### icon说明

| 名称      |  尺寸（ps） | 系统及iPhone  | 说明 |
| :-------- | --------:| :--: | :--: |
| Icon-60.png  | 60x60 |  iOS7及以上，非Retina  | 应用图标 |
| Icon-120@2x.png  | 120x120 |  iOS7及以上，Retina  | 应用图标 |
| Icon-40.png  | 40x40 |  iOS7及以上，非Retina  | 应用图标，搜索中用 |
| Icon-80@2x.png  | 80x80 |  iOS7及以上，Retina  | 应用图标，搜索中用 |
| Icon-29.png  | 29x29 |  iOS7及以上，非Retina | 应用图标，设置中用 |
| Icon-58@2x.png  | 58x58 |  iOS7及以上，Retina  | 应用图标，设置中用
 |

### 应用加载图片

| 名称      |  尺寸（ps） | 系统及iPhone  | 说明 |
| :-------- | --------:| :--: | :--: |
| Default.png  | 320x480 |  iOS7及以上，非Retina，iPhone4及之前iPhone | 启动图片 |
| Default@2x.png  | 640x960 |  iOS7及以上，Retina，iPhone4s  | 启动图片 |
| Default_1136@2x.png  | 640x1136 |  iOS7及以上，Retina，iPhone5、iPhone5s | 启动图片 |

###　定制说明

1. 如果需要定制navigaion bar，tab bar等iOS标准控件，其上的图片需要具体分析。
2. 所有图片需提供两套图片，一套给非Retina屏幕使用，为正常尺寸；一套给Retina屏幕使用，为正常尺寸的二倍，且需要命名为@2x。（如果只需要支持iPhone4s及之后的iPhone，只需要提供@2x图片，即正常尺寸的二倍的图片）

## 切图建议
1. 所有图片需要为png格式
2. 图片命名请和用途关联，最好一看就知道用在哪的（图片太多，这样容易分辨）。

