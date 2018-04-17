---
layout: post
title: python添加自定义库
categories: [python]
description: 面试题
tags: 面试
date: 2016-03-13
---
### 前言
- Python库目录
	- site-packages
		- 默认的python库目录文件夹，如果你自己手动编译Python安装或安装Windows预制Python,使用的是这个目录
	- dist-packages
		- 这个目录其实是使用Debian Linux或ubuntu Linux安装预制Python 会被指定的库目录  
- python程序会自动加载系统默认的python库目录，即上述的两个目录
- 在某些时候，我们需要在我们的程序中添加额外的自定义或第三方的库，这个时候我们有四种可以选择的方法，下面对这四种方式进行一一阐述

### 添加sys.path
python程序只会加载sys.path中的指定的库，我们可以在我们的程序开头对这个列表进行添加，即可达到添加自定义库的目的。举例如下：

```python
	#run.py#
	#!/usr/bin/python
	import sys
	sys.path.append('/home/sxiong/test')
	import test
	
	print_test('update sys.path')

	#/home/sxiong/test.py#
	#!/usr/bin/python
	def print_test(s):
		print s
```
这种方法优点在于灵活，可以随意添加我们需要的库，但其缺点也很明显，在于临时性，每次写代码都需要修改sys.path
### 设置PYTHONPATH环境变量
- 临时修改PYTHONPATH
	- export PYTHONPATH=$PYTHONPATH:/home/sxiong/test
	- 关闭此终端后改变量失效
- 永久修改PYTHONPATH
	- 修改/etc/profile
		- vim /etc/profile 
		- export PYTHONPATH=$PYTHONPATH:/home/sxiong/test
		- source /etc/profile或者重启生效
	- 修改/home/sxiong/.bash_profile
		- vim ~/.bash_profile
		- export PYTHONPATH=$PYTHONPATH:/home/sxiong/test
		- source ~/.bash_profile或者重启登陆sxiong用户生效

### 拷贝到已知库目录下
我们将test.py文件拷贝到/usr/lib/python2.7/site-packages/下即可，不建议这么做，会带来污染
### 添加.pth文件
python程序在搜索库文件时，如果遇到一个.pth的文件，那么会把该文件下的所有目录路径都添加进来
如我们在/usr/lib/python2.7/site-packages/下新建一个mypath.pth文件，编辑该文件，输入/home/sxiong/test即可，这个时候我们的程序就可以找到test这个模块了

### 总结
对于一些常用的第三方模块，我们可以使用方法二、四即可，对于偶尔使用的一些特定第三方模块，建议使用方法一
