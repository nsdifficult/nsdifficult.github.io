---
layout: post
title: "算法之快速排序"
date: 2014-09-08 18:06
comments: true
categories: 
---  
###介绍
通过一趟排序将要排序的数据分割成独立的两部分，其中一部分的所有数据都比另外一部分的所有数据都要小，然后再按此方法对这两部分数据分别进行快速排序，整个排序过程可以递归进行，以此达到整个数据变成有序序列。<!--more-->   

快速排序的图解：  

{% img  /images/quicksort/1.png %}   

###步骤  
快速排序使用分治法（Divide and conquer）策略来把一个串行（list）分为两个子串行（sub-lists）。   

1. 从数列中挑出一个元素，称为 "基准"（pivot）。   
2. 重新排序数列，所有元素比基准值小的摆放在基准前面，所有元素比基准值大的摆在基准的后面（相同的数可以到任一边）。在这个分区退出之后，该基准就处于数列的中间位置。这个称为分区（partition）操作。   
3. 递归地（recursive）把小于基准值元素的子数列和大于基准值元素的子数列排序。  

解释：每次分区操作后，即左指针和右指针相等时指向的元素在最终的位置上。   

另外[白话经典算法系列之六 快速排序 快速搞定 ](http://blog.csdn.net/morewindows/article/details/6684558)中对快速排序进行了浅显易懂的说明：  

1. 挖坑填数
2. 分治法

对挖坑填数进行总结   

1. i =L; j = R; 将基准数挖出形成第一个坑a[i]。   
2. j--由后向前找比它小的数，找到后挖出此数填前一个坑a[i]中。      
3. i++由前向后找比它大的数，找到后也挖出此数填到前一个坑a[j]中。   
4. 再重复执行2，3二步，直到i==j，将基准数填入a[i]中。  

代码解释：   

```objc
int AdjustArray(int s[], int l, int r) //返回调整后基准数的位置
{
	int i = l, j = r;
	int x = s[l]; //s[l]即s[i]就是第一个坑
	while (i < j)
	{
		// 从右向左找小于x的数来填s[i]
		while(i < j && s[j] >= x) 
			j--;  
		if(i < j) 
		{
			s[i] = s[j]; //将s[j]填到s[i]中，s[j]就形成了一个新的坑
			i++;
		}

		// 从左向右找大于或等于x的数来填s[j]
		while(i < j && s[i] < x)
			i++;  
		if(i < j) 
		{
			s[j] = s[i]; //将s[i]填到s[j]中，s[i]就形成了一个新的坑
			j--;
		}
	}
	//退出时，i等于j。将x填到这个坑中。
	s[i] = x;

	return i;
}
```  

分治法：   

```objc
void quick_sort1(int s[], int l, int r)
{
	if (l < r)
    {
		int i = AdjustArray(s, l, r);//先成挖坑填数法调整s[]
		quick_sort1(s, l, i - 1); // 递归调用 
		quick_sort1(s, i + 1, r);
	}
}
```  

将两者合并即为完整的实现：   

```objc
//快速排序
void quick_sort(int s[], int l, int r)
{
    if (l < r)
    {
		//Swap(s[l], s[(l + r) / 2]); //将中间的这个数和第一个数交换 参见注1
        int i = l, j = r, x = s[l];
        while (i < j)
        {
            while(i < j && s[j] >= x) // 从右向左找第一个小于x的数
				j--;  
            if(i < j) 
				s[i++] = s[j];
			
            while(i < j && s[i] < x) // 从左向右找第一个大于等于x的数
				i++;  
            if(i < j) 
				s[j--] = s[i];
        }
        s[i] = x;
        quick_sort(s, l, i - 1); // 递归调用 
        quick_sort(s, i + 1, r);
    }
}
```
###实现
###C实现

```objc
//
//  QuickSort.c
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


void quick_sort(int a[], int left,int right) {
    
    if (left < right) {
        int i = left,j = right,x = a[i];
        
        while (i < j) {
            
            while (i < j && a[j] >= x) {// 从右向左找第一个小于x的数
                j--;
            }
            if (i < j) {
                a[i++] = a[j];
            }
            
            while (i < j && a[i] <= x) {// 从左向右找第一个大于等于x的数
                i++;
            }
            if (i < j) {
                a[j--] = a[i];
            }
        }
        
        a[i] = x;
        quick_sort(a, left, i - 1);
        quick_sort(a, i + 1, right);
    }
    
    
}

int main()
{
    
    int a[13] = {99,234,567,7687,8,545,2,674,232,87,12,56,890};
    print_array(a,13);
    quick_sort(a,0,(13-1));
    print_array(a,13);
    return 0;
}
```
###算法分析    

* 时间复杂度：平均Ο(nlogn)    
* 空间复杂度：Ω(n)（依据版本）   
* 稳定性：原地分区版本的快速排序算法是不稳定的。  

###参考文章   
维基百科：http://en.wikipedia.org/wiki/Quicksort     
白话经典算法系列之六 快速排序 快速搞定：http://blog.csdn.net/morewindows/article/details/6684558