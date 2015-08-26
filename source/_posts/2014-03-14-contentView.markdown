---
layout: post
title: "UITableViewCell的contentView里自定义view中的子view不响应gesture"
date: 2014-03-14 15:06
comments: true
categories: 
---

##背景

通过往cell的contentView里加入自定义view的方式定制Cell时，发现自定义的view中的图片，按钮等不响应gesture。<!--more-->代码如下：

```
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    NSInteger row = [indexPath row];
    NSInteger tag = row + 1000;
    CellView *cellView = (CellView *)[cell.contentView viewWithTag:tag];
    if (!cellView) {
        cellView = [[CellView alloc] initWithFrame:cell.bounds];
        cellView.tag = row + 1000;
        [cell.contentView addSubview:cellView];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0f;
}
``` 

##分析

1. 调试了半天，发现`- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath`方法在显示前调用，用于返回要显示的cell。但在这个方法里的cell的frame的height在初始化时为44，而不是指定的height。在要显示时才会算出正确的height。所以不能在这个方法里使用cell的frame/bounds来设置cell中子view的frame等！！！！！  所以上例中的`cellView = [[CellView alloc] initWithFrame:cell.bounds];`会导致自定义的CellView的frame不正确，当然会导致gesture无效。 

2. 而cell真正的大小可在`- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath`方法中获取，这个方法在cell初始化后，将要显示时调用。在这里会返回（算出）正确的frame和bounds等。   


3. 当然同时需要在给诸如UIImageView控件添加gesture时设置`userInteractionEnabled`为YES了。因为UIImageView的这个属性默认为NO。