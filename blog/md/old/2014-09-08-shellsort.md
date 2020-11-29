---
layout: post
title: "算法之希尔排序"
date: 2014-09-08 18:06
comments: true
categories: 
---   
### 介绍

希尔排序，也称递减增量排序算法，是插入排序的一种更高效的改进版本。希尔排序是非稳定排序算法。  

希尔排序是基于插入排序的以下两点性质而提出改进方法的：<!--more-->   

* 插入排序在对几乎已经排好序的数据操作时， 效率高， 即可以达到线性排序的效率
* 但插入排序一般来说是低效的， 因为插入排序每次只能将数据移动一位   

### 步骤

1. 确定步数（一般初始步数为size／2）。  
2. 对步数确定的子序列进行直接插入排序。   
3. 重复1、2步骤，直到步数为1，进行最后一次直接插入排序。  

注释：步长的选择是希尔排序的重要部分。   
已知的最好步长序列是由Sedgewick提出的 (1, 5, 19, 41, 109,...)，该序列的项来自 9 * 4^i - 9 * 2^i + 1 和 4^i - 3 * 2^i + 1 这两个算式[1].这项研究也表明“比较在希尔排序中是最主要的操作，而不是交换。”用这样步长序列的希尔排序比插入排序和堆排序都要快，甚至在小数组中比快速排序还快，但是在涉及大量数据时希尔排序还是比快速排序慢。   

## 实现  
### C语言实现    

```objc
//
//  ShellSort.c
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

void shell_sort1(int a[], int n)
{
	int i, j, gap;
    
	for (gap = n / 2; gap > 0; gap /= 2) //步长
		for (i = 0; i < gap; i++)        //直接插入排序
		{
			for (j = i + gap; j < n; j += gap)
				if (a[j] < a[j - gap])
				{
					int temp = a[j];
					int k = j - gap;
					while (k >= 0 && a[k] > temp)
					{
						a[k + gap] = a[k];
						k -= gap;
					}
					a[k + gap] = temp;
				}
		}
}

void shell_sort2(int a[], int n)
{
	int j, gap;
	
	for (gap = n / 2; gap > 0; gap /= 2)
		for (j = gap; j < n; j++)//从数组第gap个元素开始
			if (a[j] < a[j - gap])//每个元素与自己组内的数据进行直接插入排序
			{
				int temp = a[j];
				int k = j - gap;
				while (k >= 0 && a[k] > temp)
				{
					a[k + gap] = a[k];
					k -= gap;
				}
				a[k + gap] = temp;
			}
}
void shell_sort3(int a[], int n)
{
	int i, j, gap;
    
	for (gap = n / 2; gap > 0; gap /= 2)
		for (i = gap; i < n; i++)//直接插入排序
			for (j = i - gap; j >= 0 && a[j] > a[j + gap]; j -= gap)
				swap(&a[j], &a[j + gap]);
}

int main()
{
    
    int a[13] = {99,234,567,7687,8,545,2,674,232,87,12,56,890};
    print_array(a,13);
    shell_sort3(a,13);
    print_array(a,13);
    return 0;
}
```    

## 算法分析   

* 希尔排序的分析是一个复杂的问题，因为它的时间是所取“增量”序列的函数。这里不详细描述了。   
* 稳定性：稳定  

## 参考  

* 维基百科：http://zh.wikipedia.org/zh/%E5%B8%8C%E5%B0%94%E6%8E%92%E5%BA%8F    
* 白话经典算法系列之三 希尔排序的实现 ：http://blog.csdn.net/morewindows/article/details/6668714
