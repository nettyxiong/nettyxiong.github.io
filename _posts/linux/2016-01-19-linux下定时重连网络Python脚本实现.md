---
layout: post
title: linux下定时重连网络Python脚本实现
categories: [linux,python]
description: linux下定时重连网络Python脚本实现
tags: linux python 
date: 2016-01-19
---

### 需求背景
- 实验室的服务器联网方式采用的是使用锐捷客户端连接学校的校园网，使用的账号是何老师的`教师账号`，因为`教师账号`可以在3个客户端同时登陆，在大部分情况下是不存在冲突的。但在我们使用一段时间后，经常发现有被抢登的情况（猜测是存在超过3个端同时登陆的情况，如何老师pc、平板、手机都登陆了，加上实验室的服务器，总共就4个了），断网导致我们在寝室不能远程通过ssh连接查看实验室服务器caffe任务的运行情况,因此设置一个定期检查网络并并重新建立网络连接的机制相当必要。

### 设计思路
- 设置一个轮询机制，即定期查询网络状态
- 当检测到网络状态断开，即被抢登了，系统发起重连网络
- 继续轮询

### 检查网络状态

- ping -c 3 wwww.baidu.com | grep "3 received" | wc -l
- 即向一个稳定的服务器发送ping请求，如果返回结果确认收到3个ping包返回信息，则证明网络正常
- 上述命令，在网络正常时，返回'1'；网络断开时，返回'0'

### python脚本编写

- check-network-periodically.py

		#! /usr/bin/python
		import os,sys
		import schedule
		import time
		import commands
		
		#检查网络状态，'1':connceted,'0':not connected
		def check_network_status():
			line=commands.getstatusoutput('ping -c 3 wwww.baidu.com | grep "3 received" | wc -l')
			print line[0]#the command status
			print line[1]#the command output
			net_connected = line[1]
			return net_connected
		
		#重连网络
		def job():
			if check_network_status() == '0':
				print("start network...")
				line=os.popen('sudo sh /home/lei/start-network.sh','r')
				print line.read()
		
		#轮询,每5分钟轮询一次
		schedule.every(5).minutes.do(job)
		
		while True:
			schedule.run_pending()
			time.sleep(1)
			print 'is checking...'
	
### 重启网络脚本
- start-network.sh

		#主要是对锐捷启动脚本进行了参数封装，且通过setsid设置为后台运行
		setsid sh /home/lei/rj/rjsupplicant.sh -d 1 -n em1 -u 用户名 -p 密码 -S 1

### 调用
- 本来应该将check-network-periodically.py设置为开机自启动，但考虑到服务器长期处于运行状态，并没有关机，设置自启动必要性不大，直接在现阶段基础上运行该脚本即可
- setsid python check-network-periodically.py

### ssh连接设置
- 在自己的个人电脑ubuntu上连接实验室服务器时，经常性的输入ip、用户名信息，这样太麻烦，于是采用一种便于维护的方式，即将这些连接信息保存在`~/.ssh/config`文件中，设置规则如下

		#服务器别名
		Host dell
		#账号用户名
		User lei
		#服务器ip地址
		Hostname 192.168.0.112


- 改进：原来需要使用`ssh lei@192.168.0.112`,现在只需要`ssh dell`即可

### 附件
- [华科校园网锐捷客户端Linux版下载](http://ncc.hust.edu.cn/attachment.jspx?cid=792&i=0&t=1453192815941&k=63a7946665c732716e36c3a1768038c4)
- [python schedule模块主页](https://github.com/dbader/schedule)
- [python调用shell的方法](http://www.jb51.net/article/43502.htm)

