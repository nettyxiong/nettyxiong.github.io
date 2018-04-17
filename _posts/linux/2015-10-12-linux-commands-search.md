---
layout: post
title: linux下的查找命令汇总
categories: [linux]
description: linux下的查找命令使用总结，which\locate\whereis\find
tags: linux
date: 2015-10-12
---

## which
```
which [-a] command
```
其中-a选项表示在**PATH**目录中可以找到的指令都列出，而不单单是第一个被查找的指令名称，--all的简写。
例如，我们可以查找在系统中gcc命令所处的路径，当第一个搜索出来的路径是在我们自行安装的gcc版本，指定-a选项搜索多出来的一个路径是ubuntu系统自带的gcc版本。

```
>sxiong@sxiong-X450JF:~$ which gcc
/usr/local/bin/gcc
```

```
>sxiong@sxiong-X450JF:~$ which -a gcc
/usr/local/bin/gcc
/usr/bin/gcc
```

关于which指令，需要注意的地方是，它只会搜索PATH变量指明的路径，其它未在此路径下的命令不会被搜索到。


## whereis

```
whereis [-bmsu] 档案或目录名
```
* b:只找 binary 格式的档案,即限定查找二进制文件
* m:限定在说明文件man路径下进行查找
* s:查找命令的源代码所在位置
* u:搜寻不在上述三个项目当中的其他特殊档案

这个使用起来并不太方便，个人习惯使用locate的类似于“模糊查找”来满足日常的需求。


## locate
```
locate [-ir] keyword
```
* i:忽略大小写
* r:使用正规运算式做查找的条件

```
#查找以“/home/sxiong/rj/x64”开头的文件
> sxiong@sxiong-X450JF:~$ locate -ir ^/home/sxiong/rj/x64
/home/sxiong/rj/x64
/home/sxiong/rj/x64/.rgsusfexit
/home/sxiong/rj/x64/README
/home/sxiong/rj/x64/SuConfig.dat
/home/sxiong/rj/x64/fileReg.ini
/home/sxiong/rj/x64/lib
...
```

```
#查找以"selinux/makEfile"结尾并忽略大小写的文件
> sxiong@sxiong-X450JF:~$ locate -ir selinux/makEfile$ 
/usr/src/linux-headers-3.2.0-29/scripts/selinux/Makefile
/usr/src/linux-headers-3.2.0-29/security/selinux/Makefile
/usr/src/linux-headers-3.2.0-29-generic/scripts/selinux/Makefile
```

这个命令比whereis好用之处在于它支持正则匹配查询，可以查找所有与查询字段相关的所有文件，而非二进制文件、说明文件、源代码文件等。
## find
```
find [PATH] [option] [action]
```
* PATH： 所要搜索的目录及其所有子目录。默认为当前目录。
* option： 所要搜索的文件的特征。
* action： 对搜索结果进行特定的处理。
 
这个指令功能十分强大，在此仅说明一些常见的用法。
#### -name 按照文件名查找文件
```
#在当前文件夹下查找所有java后缀文件
> sxiong@sxiong-X450JF:~$ find . -name "*.java"
```
#### -type 按照文件类型查找文件
类型主要有:一般正规档案 (f),装置档案 (b, c), 目录 (d), 链接 (l), socket (s),及 FIFO (p) 等属性。

```
#查找rj目录下的目录文件
>sxiong@sxiong-X450JF:~$ find rj/ -type d
rj/
rj/x86
rj/x86/lib
rj/x64
rj/x64/lib
rj/x64/log
```

#### -size 按照文件大小查找文件
```
#查找rj目录下大于1MB的文件
>sxiong@sxiong-X450JF:~$ find rj/ -size +1M
rj/x86/rjsupplicant
rj/x86/lib/libcrypto.so.6
rj/x64/rjsupplicant
rj/x64/lib/libcrypto.so.6
```

关于find在查找到文件后进行命令操作，这个自己平时用到比较少，在此不做说明。
## 总结
* 查找软件命令推荐使用which、whereis
* 查找普通文件推荐使用locate、find
* locate查询的是一个缓存数据库，这里面的数据并不是实时最新的，我们可以执行updatedb操作来刷新这个数据库，从而保障查找的有效性。
* find指令是直接在磁盘上进行搜索的，这个指令在功能强大的同时，也有着性能较差的缺点
* 对于这些查找命令的使用会在以后日常使用中及时更新使用的心得

## 参考链接

[鸟叔的私房菜](http://vbird.dic.ksu.edu.tw/linux_basic/linux_basic.php "鸟叔的私房菜")
