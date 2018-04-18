---
layout: post
title: 计算机网络Report Two
categories: [network]
description: 网络课设第二次实验报告,关于拥塞控制的应用
tags: network
date: 2015-10-26
---
## 必做部分

### 环境准备
- 题目要求
![](http://7xk5ic.com1.z0.glb.clouddn.com/problem.png)
- 实验环境
在windows下安装vmware，新建ubuntu 12.04虚拟机，可以通过拷贝虚拟机文件的形式安装两个虚拟机，分别命名为ubuntu client、ubuntu server，分别作为iperf的客户端和服务端
- iperf的安装
`sudo apt-get install iperf`，iperf的使用可以参考链接[iperf的使用实战](http://blog.163.com/hlz_2599/blog/static/142378474201341341339314/)
- 按照老师给出的建议，使用命令`sysctl net.ipv4.tcp_available_congestion_control`查看系统支持的拥塞控制模块，在client、server两台虚拟机上均运行上述命令，输出结果如下图所示：![](http://7xk5ic.com1.z0.glb.clouddn.com/kongzhi_modules.png)可用的拥塞控制算法有两个，分别为cubic、reno。

### cubic测试实现过程
1. 设置拥塞控制算法为cubic，在客户端与服务端均运行如下命令：`sudo sysctl -w net.ipv4.tcp_congestion_control=cubic`
2. 编写发送数据包的脚(run.sh)，如下所示:
```bash
#!/bin/bash
i=0
while [ $i -le $1 ]
do
echo "ping:$i"
ping -c 10 -s 20000 192.168.140.129 &
i=$(($i+1))
done
```
3. 测试**无拥塞**情况的吞吐率与RTT
	- 查看服务端局域网地址:`ifconfig`;得到其ip为192.168.140.129
	- 服务端开启iperf监听:`iperf -s`
	- 客户端发送请求:命令行终端中输入`iperf -c 192.168.140.129`、`ping -c 10 192.168.140.129`测试带宽与RTT
	- 结果如图所示：![Alt text](https://raw.githubusercontent.com/sixiong/sixiong.github.io/master/images/network/result1.png)
4. 测试**有拥塞**情况的吞吐率与RTT
	- 要实现链路拥塞,就需要模拟在短时间内发送大量数据包的情况,将脚本参数设置为500，代表500个用户同同时发送请求
	- 运行run.sh脚本，`./run.sh 500`,同时在另一个命令行终端中输入`iperf -c 192.168.140.129`测试带宽与RTT,输出结果如下所示![](https://raw.githubusercontent.com/sixiong/sixiong.github.io/master/images/network/result13.png)![](https://raw.githubusercontent.com/sixiong/sixiong.github.io/master/images/network/result14.png)
5. 结果分析
	- 与无拥塞相比，在有拥塞的情况下，带宽明显下降，从原来的2.45Gbits/sec降到1.56Gbits/sec
	- 与无拥塞相比，在有拥塞的情况下，RTT值明显变大，具体比较其平均值，从0.457上升到1.693

## reno测试实现过程
1. 设置拥塞控制算法为reno，在客户端与服务端均运行如下命令： `sudo sysctl -w net.ipv4.tcp_congestion_control=reno`
2. 测试**无拥塞**情况的吞吐率与RTT
	- 查看服务端局域网地址:`ifconfig`;得到其ip为192.168.140.129
	- 服务端开启iperf监听:`iperf -s`
	- 客户端发送请求:命令行终端中输入`iperf -c 192.168.140.129`、`ping -c 10 192.168.140.129`测试带宽与RTT
	- 结果如图所示：![Alt text](https://raw.githubusercontent.com/sixiong/sixiong.github.io/master/images/network/result15.png)
3. 测试**有拥塞**情况的吞吐率与RTT
	- 要实现链路拥塞,就需要模拟在短时间内发送大量数据包的情况,将脚本参数设置为500，代表500个用户同同时发送请求
	- 运行run.sh脚本，`./run.sh 500`,同时在另一个命令行终端中输入`iperf -c 192.168.140.129`测试带宽与RTT,输出结果如下所示</br>![](https://raw.githubusercontent.com/sixiong/sixiong.github.io/master/images/network/result16.png)![](https://raw.githubusercontent.com/sixiong/sixiong.github.io/master/images/network/result17.png)
4. 结果分析
	- 与无拥塞相比，在有拥塞的情况下，带宽明显下降，从原来的2.52Gbits/sec降到1.48Gbits/sec
	- 与无拥塞相比，在有拥塞的情况下，RTT值明显变大，具体比较其平均值，从0.399上升到1.622

## 结论
在拥塞时,会有数据包丢失；cubi相对于reno效果要好一些。

### 附件
- [run.sh](https://raw.githubusercontent.com/sixiong/sixiong.github.io/master/images/network/run.sh "run.sh")
- [iperf的使用实战](http://blog.163.com/hlz_2599/blog/static/142378474201341341339314/)
