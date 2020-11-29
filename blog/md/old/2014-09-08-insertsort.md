---
layout: post
title: "算法之插入排序"
date: 2014-09-08 18:06
comments: true
categories: 
---
# 算法之插入排序
### 前言
插入排序（Insertion Sort）的算法描述是一种简单直观的排序算法。它的工作原理是通过构建有序序列，对于未排序数据，在已排序序列中从后向前扫描，找到相应位置并插入。插入排序在实现上，通常采用in-place排序（即只需用到O(1)的额外空间的排序，详情见[原地算法](http://zh.wikipedia.org/zh/%E5%8E%9F%E5%9C%B0%E7%AE%97%E6%B3%95)），因而在从后向前扫描过程中，需要反复把已排序元素逐步向后挪位，为最新元素提供插入空间。<!--more-->　 

### 步骤   

一般来说，插入排序都采用in-place在数组上实现。具体算法描述如下： 

1. 从第一个元素开始，该元素可以认为已经被排序   
2. 取出下一个元素，在已经排序的元素序列中从后向前扫描    
3. 如果该元素（已排序）大于新元素，将该元素移到下一位置      
4. 重复步骤3，直到找到已排序的元素小于或者等于新元素的位置     
5. 将新元素插入到该位置后   
6. 重复步骤2~5   

或者第三个步骤换成交换两个元素。具体算法描述如下： 

1. 从第一个元素开始，该元素可以认为已经被排序   
2. 取出下一个元素，在已经排序的元素序列中从后向前扫描    
3. 如果该元素（已排序）大于新元素，则交换这两个元素      
4. 重复步骤3，直到找到已排序的元素小于或者等于新元素的位置     
5. 将新元素插入到该位置后   
6. 重复步骤2~5  

如果比较操作的代价比交换操作大的话，可以采用二分查找法来减少比较操作的数目。该算法可以认为是插入排序的一个变种，称为二分查找排序。    

### C实现  

```objc
//
//  InsertSort.c
//  MergeSort
//
//  Created by Edgar on 14-9-11.
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

void insert_sort(int a[],const int size) {
    
    int j = 0;
    int tmp = 0;
    for (int i = 1; i < size; i++) {
        tmp = a[i];
        j = i - 1;
        while (j >= 0&&a[j] > tmp) {
            a[j+1] = a[j];
            j--;
        }
        a[j+1] = tmp;
    }
}

//交换显示代码更简洁
void insert_sort3(int a[], int n)
{
    int i, j;
    for (i = 1; i < n; i++)
        for (j = i - 1; j >= 0 && a[j] > a[j + 1]; j--)
            swap(&a[j], &a[j + 1]);
}


int main(int argc, const char * argv[])
{
    
    int a[13] = {99,234,567,7687,8,545,2,674,232,87,12,56,890};
    print_array(a,13);
    insert_sort3(a, 13);
    print_array(a,13);
    return 0;
}
```

### 算法分析

* 时间复杂度：最好：O(n)，最坏O(n<sup>2</sup>)。平均O(n<sup>2</sup>)    
* 空间复杂度：O(1)     
* 稳定性：稳定。
 

如果目标是把n个元素的序列升序排列，那么采用插入排序存在最好情况和最坏情况。最好情况就是，序列已经是升序排列了，在这种情况下，需要进行的比较操作需(n-1)次即可。最坏情况就是，序列是降序排列，那么此时需要进行的比较共有n(n-1)/2次。插入排序的赋值操作是比较操作的次数减去(n-1)次。平均来说插入排序算法复杂度为O(n<sup>2</sup>)。因而，插入排序不适合对于数据量比较大的排序应用。但是，如果需要排序的数据量很小，例如，量级小于千，那么插入排序还是一个不错的选择。 插入排序在工业级库中也有着广泛的应用，在STL的sort算法和stdlib的qsort算法中，都将插入排序作为快速排序的补充，用于少量元素的排序（通常为8个或以下）。