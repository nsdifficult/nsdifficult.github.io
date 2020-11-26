---
layout: post
title: "算法之冒泡排序"
date: 2014-09-08 18:06
comments: true
categories: 
---   
###介绍   

冒泡排序的原理可以顾名思义：把每个数据看成一个气泡，按初始顺序自底向上依次对两两气泡进行比较，对上重下轻的气泡交换顺序（这里用气泡轻、重表示数据大、小），保证轻的气泡总能浮在重的气泡上面，直到最轻的气泡浮到最上面；保持最后浮出的气泡不变，对余下气泡循环上述步骤，直到所有气泡从轻到重排列完毕。<!--more-->   

冒泡排序的图解：  

![](/images/bubblesort/1.gif) 

###步骤  

1. 比较相邻的元素。如果第一个比第二个大，就交换他们两个。      
2. 对每一对相邻元素作同样的工作，从开始第一对到结尾的最后一对。这步做完后，最后的元素会是最大的数。   
3. 针对所有的元素重复以上的步骤，除了最后一个。   
4. 持续每次对越来越少的元素重复上面的步骤，直到没有任何一对数字需要比较。   

###算法分析

* 时间复杂度：最好：O(n)，最坏O(n<sup>2</sup>)。平均O(n<sup>2</sup>)    
* 空间复杂度：O(1)   
* 稳定性：稳定。

###实现
####C语言实现  

```objc
//
//  BubbleSort.c
//  MergeSort
//
//  Created by Edgar on 14-9-15.
//  Copyright (c) 2014年 Edgar. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>

void print_array(const int *list, const int len)
{
    int i;
    for (i = 0; i < len; ++i)
    {
        printf("%d\t", *(list+i));
    }
    printf("\n");
}

void swap(int *x,int *y)//使用指针传递地址
{
    int temp;
    temp=*x;
    *x=*y;
    *y=temp;
}
//这个不易读
/*
void bubble_sort(int a[], int size)
{
	int i,j;
    for (i = size; i > 1; i--) {
        for (j = 0; j < i-1; j++) {
            if (a[j] > a[j+1])
                swap(&a[j], &a[j+1]);
        }
        
    }
    
}*/

void bubble_sort(int a[], int size)
{
    int i, j;
    for (i = 0; i < size; i++)
        for (j = 1; j < size - i; j++)
            if (a[j - 1] > a[j])
                swap(&a[j - 1], &a[j]);
}

int main()
{
    
    int a[13] = {99,234,567,7687,8,545,2,674,232,87,12,56,890};
    print_array(a,13);
    bubble_sort(a,13);
    print_array(a,13);
    return 0;
}
```
###参考  

维基百科： http://zh.wikipedia.org/wiki/%E5%86%92%E6%B3%A1%E6%8E%92%E5%BA%8F  

