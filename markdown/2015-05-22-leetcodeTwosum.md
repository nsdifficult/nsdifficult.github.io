---
layout: post
title: "leetcode之two sum"
date: 2015-05-22 16:06
comments: true
categories: 
---

# leetcode之two sum
##问题描述
[two sum原题链接](https://leetcode.com/problems/two-sum/)
>Given an array of integers, find two numbers such that they add up to a specific target number.<!--more-->

>The function twoSum should return indices of the two numbers such that they add up to the target, where index1 must be less than index2. Please note that your returned answers (both index1 and index2) are not zero-based.

>You may assume that each input would have exactly one solution.

>Input: numbers={2, 7, 11, 15}, target=9
Output: index1=1, index2=2 

##简要说明
给定一个int型数组和一个目标数字，从数组中找到两个数字之和为目标数字，返回这两个数字的索引，要求索引从1开始，且第一个小于第二个。如输入：numbers={2, 7, 11, 15}, target=9。只能返回1，2。返回0，1或者2，1都是错的。   

##思路
###1、两个循环

```objc
int* twoSum(int* nums, int numsSize, int target) {
    
    int *tmp = (int*)malloc(sizeof(int)*2);
    for (int i = 0; i < numsSize; i++) {
        int a = nums[i];
        for (int j = 0; j < i; j++) {
            if (a+nums[j] == target) {
                tmp[0] = j+1;
                tmp[1] = i+1;
            }
        }
    }
    return tmp;
    
}
```
时间复杂度是n^2，提交之后告诉我超时。。。不通过。
###2、先快速排序，再二分查找

```objc
struct intWithIndex{
    int val;
    int index;
};

struct intWithIndex* create(int *nums,int numsSize){
    int i;
    struct intWithIndex* data = (struct intWithIndex*)malloc(sizeof(struct intWithIndex)*numsSize);
    for(i = 0;i < numsSize;i++){
        data[i].index = i;
        data[i].val = nums[i];
    }
    return data;
}

void swap(int *x,int *y)//使用指针传递地址
{
    int temp;
    temp=*x;
    *x=*y;
    *y=temp;
}

void quick_sort(struct intWithIndex* a, int left,int right) {
    
    if (left < right) {
        int i = left,j = right;
        struct intWithIndex x = a[i];
        
        while (i < j) {
            
            while (i < j && a[j].val >= x.val) {// 从右向左找第一个小于x的数
                j--;
            }
            if (i < j) {
                a[i++] = a[j];
            }
            
            while (i < j && a[i].val <= x.val) {// 从左向右找第一个大于等于x的数
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

int binary_search(struct intWithIndex *a,int left,int right,int target) {

    if (left <= right) {
        int mid = (left+right)/2;
        if (target == a[mid].val) {
            return mid;
        } else if (target < a[mid].val) {
            return binary_search(a, left, mid - 1, target);
        } else if (target > a[mid].val) {
            return binary_search(a, mid + 1, right, target);
        }
    }
    return -1;
}

int* twoSum(int* nums, int numsSize, int target) {
    
    int *tmp = (int*)malloc(sizeof(int)*2);
    
    struct intWithIndex *data = create(nums,numsSize);
    quick_sort(data, 0, numsSize-1);

    for (int i = 0; i < numsSize; i++) {
        struct intWithIndex a = data[i];
        int bIndex = binary_search(data, i+1, numsSize - 1, target - a.val);
        if (bIndex != -1) {
            tmp[0] = a.index+1;
            tmp[1] = data[bIndex].index+1;
            if (tmp[0] > tmp[1]) {
                swap(&tmp[0], &tmp[1]);
            }
        }
    }
    return tmp;
}
```
时间复杂度为nlogn，提交通过。
###3、先快速排序，再使用两个数字之和的特性来查找

```objc
struct intWithIndex{
    int val;
    int index;
};

struct intWithIndex* create(int *nums,int numsSize){
    int i;
    struct intWithIndex* data = (struct intWithIndex*)malloc(sizeof(struct intWithIndex)*numsSize);
    for(i = 0;i < numsSize;i++){
        data[i].index = i;
        data[i].val = nums[i];
    }
    return data;
}

void swap(int *x,int *y)//使用指针传递地址
{
    int temp;
    temp=*x;
    *x=*y;
    *y=temp;
}

void quick_sort(struct intWithIndex* a, int left,int right) {
    
    if (left < right) {
        int i = left,j = right;
        struct intWithIndex x = a[i];
        
        while (i < j) {
            
            while (i < j && a[j].val >= x.val) {// 从右向左找第一个小于x的数
                j--;
            }
            if (i < j) {
                a[i++] = a[j];
            }
            
            while (i < j && a[i].val <= x.val) {// 从左向右找第一个大于等于x的数
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

int *twoSum(int *nums,int numsSize,int target) {
    
    int *tmp = (int*)malloc(sizeof(int)*2);
    struct intWithIndex *data = create(nums,numsSize);
    quick_sort(data, 0, numsSize-1);

    int left = 0,right = numsSize - 1;
    while (left < right) {
        if (data[left].val + data[right].val == target) {
            tmp[0] = data[left].index + 1;
            tmp[1] = data[right].index + 1;
            if (tmp[0] > tmp[1]) {
                swap(&tmp[0], &tmp[1]);
            }
            return tmp;
        } else {
            data[left].val + data[right].val > target ? right-- : left++;
        }
    }
    return tmp;
}
```
时间复杂度也为nlogn，提交通过。

###4、使用map强制搜索

```java
public class Solution {
    public int[] twoSum(int[] nums, int target) {
        int[] tmp = new int[2];
		Map<Integer,Integer> map = new HashMap<Integer, Integer>();

		for (int i = 0; i < nums.length; i++) {
			if (map.containsKey(target - nums[i])) {
				tmp[0] = i + 1;
				tmp[1] = map.get(target - nums[i]) + 1;
				if (tmp[0] > tmp[1]) {
					int tmp0 = tmp[0];
					tmp[0] = tmp[1];
					tmp[1] = tmp0;
				}
				break;
			} else {
				map.put(nums[i], i);
			}
		}
		
		return tmp;
    }
}
```
时间复杂度为n，提交通过。

