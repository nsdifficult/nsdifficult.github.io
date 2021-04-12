## 算法之Bloom Filter介绍

[维基百科介绍](https://en.wikipedia.org/wiki/Bloom_filter)：
> A Bloom filter is a space-efficient probabilistic data structure,
> conceived by Burton Howard Bloom in 1970,
> that is used to test whether an element is a member of a set.
> False positive matches are possible,
> but false negatives are not – in other words,
> a query returns either "possibly in set" or "definitely not in set".
> Elements can be added to the set,
> but not removed (though this can be addressed with the counting Bloom filter variant);
> the more items added, the larger the probability of false positives.

布隆过滤器是一个可以高效利用空间的，可以用来做概率判断的数据结构。（这是我的翻译==）。利用bloom filter可以实现
在大数据集合中，一定不存在或可能存在某个值的判断。

相比于传统的 List、Set、Map 等数据结构，它更高效、占用空间更少，但是缺点是其返回的结果是概率性的，而不是确切的。

## 实现原理

### 前提知识

### Hash函数
Hash函数可以将任意长度的输入通过散列算法编程固定长度的输出。最典型的Hash函数是直接取余法。
更高效的Hash函数为：MurmurHash（guava 的BloomFilter使用）等。

### 如何从一个集合中查找一个值？如何从巨量数据中查找一个值呢？比如一亿条字符串。
这个时候就不能再简单的使用Map等了

###原理
BloomFilter的数据结构为一个bit数组。
https://zhuanlan.zhihu.com/p/43263751
https://www.baeldung.com/guava-bloom-filter


```java

public static void main(String args[]) {
        BloomFilter<Integer> filter = BloomFilter.create(
                Funnels.integerFunnel(),
                500,
                0.01);


        filter.put(1);
        filter.put(2);
        filter.put(3);

        Assert.assertTrue(filter.mightContain(1));
        Assert.assertTrue(filter.mightContain(2));
        Assert.assertTrue(filter.mightContain(3));

//        Assert.assertTrue(filter.mightContain(100));


        // Create a Bloom Filter instance
        BloomFilter<String> blackListedIps = BloomFilter.create(
                Funnels.stringFunnel(Charset.forName("UTF-8")), 10000);

        // Add the data sets
        blackListedIps.put("192.170.0.1");
        blackListedIps.put("75.245.10.1");
        blackListedIps.put("10.125.22.20");

        // Test the bloom filter
        System.out.println(
                blackListedIps
                        .mightContain(
                                "75.245.10.1"));
        System.out.println(
                blackListedIps
                        .mightContain(
                                "101.125.20.22"));

    }
```

