---
layout: post
title: "算法之归并排序"
date: 2014-09-07 18:06
comments: true
categories: 
---
###前言
归并排序由[John von Neumann（约翰·冯·诺伊曼）](http://en.wikipedia.org/wiki/John_von_Neumann)发明于1945年。   
归并排序（Merge sort）是建立在归并操作上的一种有效的排序算法。该算法是采用分治法（Divide and Conquer）的一个非常典型的应用。是一种稳定排序方法。<!--more-->      
图解归并排序：   

![](/images/mergesort/1.gif) 


###开始之前
首先需要了解一个概念：[分治法](http://zh.wikipedia.org/wiki/%E5%88%86%E6%B2%BB%E6%B3%95)    
>在计算机科学中，分治法是建基于多项分支递归的一种很重要的算法范式。字面上的解释是“分而治之”，就是把一个复杂的问题分成两个或更多的相同或相似的子问题，直到最后子问题可以简单的直接求解，原问题的解即子问题的解的合并。   
>这个技巧是很多高效算法的基础，如排序算法（快速排序、归并排序）、傅立叶变换（快速傅立叶变换）。  

###步骤

归并排序算法步骤可以简单概括为：  

1. 分：将序列等分为二
2. 治：分别对两个序列递归的使用归并排序算法
3. 合：每次递归中，将分开的两个部分合并成一个有序序列（归并两个有序序列）

归并两个有序序列的步骤为：   

1. 申请空间，使其大小为两个已经排序序列之和，该空间用来存放合并后的序列    
2. 设定两个指针，最初位置分别为两个已经排序序列的起始位置    
3. 比较两个指针所指向的元素，选择相对小的元素放入到合并空间，并移动指针到下一位置    
4. 重复步骤3直到某一指针到达序列尾    
5. 将另一序列剩下的所有元素直接复制到合并序列尾   

###算法分析

* 时间复杂度：最好：O(nlogn)，最坏O(nlogn)。平均O(nlogn)    
* 空间复杂度：O(n)（需要一个大小为n的临时数组）   
* 稳定性：稳定。

###实现

####C实现

```objc
//
//  main.c
//  MergeSort
//
//  Created by Edgar on 14-9-6.
//  Copyright (c) 2014年 Edgar. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>


void mergeTwoArray(int a[],int sizeA,int b[],int sizeB) {
    
    int i, j, k;
    i = j = k = 0;
    int *c = malloc((sizeA + sizeB)*sizeof(int));
    
    while (i < sizeA&&j < sizeB) {
        c[k++] = a[i] < b[j]?a[i++]:b[j++];
    }
    while (i < sizeA) {
        c[k++] = a[i++];
    }
    while (j < sizeB) {
        c[k++] = b[j++];
    }
    
    for (int l = 0; l < (sizeA + sizeB); l++) {
        a[l] = c[l];
    }
    free(c);
}


void merge_sort(int a[],int size) {
    
    if (size > 1) {
        
        int size1 = size/2;
        int *a1 = a;
        int *a2 = a + size1;
        int size2 = size - size1;
        
        merge_sort(a1,size1);
        merge_sort(a2,size2);
        
        mergeTwoArray(a1, size1, a2, size2);
    }
}

int main(int argc, const char * argv[])
{
    
    int a[13] = {99,234,567,7687,8,545,2,674,232,87,12,56,890};
    
    merge_sort(a, 13);
    
    for (int i = 0; i < 10; i++) {
        printf("%3d\n",a[i]);
    }
    return 0;
}

/*
//测试合并两个有序数组
int main(int argc, const char * argv[])
{
    
    int a[4] = {1,2,7,9};
    int b[6] = {6,8,23,25,67,99};
    mergeTwoArray(a, 4, b, 6);
    for (int i = 0; i < 10; i++) {
        printf("%3d ",a[i]);
    }
    return 0;
}*/
```

参考文章：   

http://zh.wikipedia.org/zh/%E5%BD%92%E5%B9%B6%E6%8E%92%E5%BA%8F     
http://blog.csdn.net/morewindows/article/details/6678165
