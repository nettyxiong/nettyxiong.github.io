---
layout: post
title: python之多进程与多线程
categories: [python,linux]
description: 多进程、多线程、python、内存共享
tags: python
date: 2016-04-10
---
### 多进程
在python中实现多进程程序，最常用的做法是借助multiprocessing模来实现，具体实现可以参考其文档，我们可以利用pool一次性提前创建好大量进程，为后续工作做好准备。举例如下:

```python
from multiprocessing import Pool
import os, time, random

def long_time_task(name):
    print 'Run task %s (%s)...' % (name, os.getpid())
    start = time.time()
    time.sleep(random.random() * 3)
    end = time.time()
    print 'Task %s runs %0.2f seconds.' % (name, (end - start))

if __name__=='__main__':
    p = Pool(multiprocessing.cpu_count())
    for i in range(5):
        p.apply_async(long_time_task, args=(i,))
    print 'Waiting for all subprocesses done...'
    p.close()
    p.join()
    print 'All subprocesses done.'
```

### 多线程
在python中实现多线程程序，我们常用的模块是threading，此外，我们也可以利用multiprocessing.dumpy库，具体可以参考其文档，举例如下：

```python
import time, threading

# 新线程执行的代码:
def loop():
    print 'thread %s is running...' % threading.current_thread().name
    n = 0
    while n < 5:
        n = n + 1
        print 'thread %s >>> %s' % (threading.current_thread().name, n)
        time.sleep(1)
    print 'thread %s ended.' % threading.current_thread().name

print 'thread %s is running...' % threading.current_thread().name
t = threading.Thread(target=loop, name='LoopThread')
t.start()
t.join()
print 'thread %s ended.' % threading.current_thread().name
```

### 多进程还是多线程？
- 在python程序中，我们需要注意到的是，多线程程序并没有办法充分利用多核CPU的优势，其原因是在CPython中存在GIL（解释器全局锁）,意味着在python解释器中自始至终同一时刻只有一个CPU在执行，任何代码的执行都需要先获取到GIL使用锁才能得到解释执行。因此，在python中，如果要充分利用多核并发的优势，利用多线程并发并不是明智之举，比较好的做法是使用多进程实现程序的并发，麻烦点也可以使用C拓展模块来实现。
	- 计算密集型的任务
		- 对CPU资源要求较高，因为多线程程序实质是CPU的串行执行，多个线程的频繁切换会导致大量的额外开销，使得程序效率低下。对于这种类型的任务，我们可以使用多进程来实现程序的并发，充分利用CPU资源，以高效完成任务。
	- IO密集型的任务
		- 对IO资源要求较高，程序的大部分时间都消耗在IO资源的获取上，在等待IO资源的时间片段里，有充足的时间给多线程来切换使用CPU，在线程数设置合理的情形下，可以达到充分利用单核CPU的效果，这种情形下推荐优先使用多线程，因为多进程的资源开销（内存）、数据交互开销要比多线程大得多

### 多进程内存共享实现
多进程虽然可以充分利用多核CPU实现高并发，但它对计算资源的消耗也是巨大的。

```python
from multiprocessing import Pool
def worker(i):
	print read_only_var[i]
if __name__ == '__main__':
p = Pool(8)
read_only_var = [0]*1000000
data = [i for i in xrange(1000000)]
p.map_async(worker,data)
p.close()
p.join()
```

- 在上述程序中，一切都看起来很完美，启动了8个进程来遍历打印read_only_var这个变量，实现了高并发。但当我们查看程序运行时内存的消耗情况，我们发现整个程序消耗了8个read_only_var的内存大小。这是因为，在父进程中，有全局变量read_only_var，在进程池中启动8个多进程时，每个子进程都会把父进程的资源进行拷贝，从而导致了大量额外的内存开销，当这个全局变量拓展到更大时，这些额外的内存开销将会显得更加庞大，从而导致程序灾难。
- 或许有些linux底层知识的同学会反驳，在Linux中，多进程变量的使用遵守copy-on-write规则，这个read_only_var变量只会当子进程对此变量进行修改时才会进行拷贝操作，上面这段程序在linux下运行所占用的内存应当只有一个read_only_var大小。其实 ，我也是这么认为的，因为这样才显得合理，明明可以避免不必要的内存开销，为什么不呢？！然而，经过测试，确实是8个read_only_var大小。经过google得知，发现是python的多进程模块multiprocessing是对C语言fork的封装，在此基础上，它默认会拷贝所有父进程中的资源，供子进程进行使用
- 或许我们会有些困惑，那我们该怎么办？用C实现多进程以达到并发吗？太麻烦了吧？！我也这么认为的！其实，我们不需要这么麻烦，这些问题大神们肯定是考虑到了的，比较常见的解决内存共享的方式如下所示：
	- python的multiprocessing模块提供两种共享内存，sharedctypes与Manager
	- 使用REDIS等数据库做缓存实现内存共享
	- 使用C语言编写相应的多进程模块
- multiprocessing模块提供的两种内存共享模式，首先推荐sharedctypes，因为效率较高，但它不支持远程内存共享，也就是只支持本地；Manager虽然效率低一些，但可以支持远程内存访问，二者的选择可以根据具体的情况而定
- multiprocessing模块提供的两种内存共享模式，虽然使用简单方便，但也有一定的缺陷，那就是对共享变量的类型进行了限制，对于一些结构复杂的自定义数据，没办法成功序列化进行内存共享（亲测，痛苦啊！）
- REDIS缓存方式，这种方法可以很好地解决内存共享问题，因为我们把多进程交互共享问题交给了REDIS来操作，但这种方式增加了程序的依赖性，即每次运行程序需要启动REDIS，此外，需要额外的序列化操作，因为REDIS中所有内容都是字符串，所有的变量都需要自己手动地序列化为字符串后才能存进REDIS，而从REDIS中读取 变量时也需要先获取字符串，再反序列化为我们需要的变量类型进行使用
- 至于C语言编写python拓展模块来实现多进程内存共享，这一方法正是利用了Unix系统内存的copy-on-write特性，从而达到我们期望的变量全局仅存一份的效果，但也是相对麻烦了些。。

### 参考链接
- [multiprocessing模块官方文档](https://docs.python.org/release/2.7.1/library/multiprocessing.html)
- [廖雪峰的python2.7教程之多进程vs多线程](http://www.liaoxuefeng.com/wiki/001374738125095c955c1e6d8bb493182103fac9270762a000/001397567993007df355a3394da48f0bf14960f0c78753f000)
- [python-multiprocessing-sharing-a-large-read-only-object-between-processes](http://stackoverflow.com/questions/659865/python-multiprocessing-sharing-a-large-read-only-object-between-processes)


		
