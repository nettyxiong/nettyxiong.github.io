---
layout: post
title: ubuntu14.04下搭建mesos集群
categories: [bigdata]
description: 实现mesos集群的搭建
tags: mesos ubuntu
date: 2016-09-05
---

### 环境
- ubuntu 14.04 64位
- mesos-0.28.2.tar.gz
- java 7

### 安装单机Mesos
1. 参考[mesos get-started](http://mesos.apache.org/gettingstarted/)
2. 下载源码

		$ wget http://www.apache.org/dist/mesos/0.28.2/mesos-0.28.2.tar.gz
		$ tar -zxf mesos-0.28.2.tar.gz
		
3. 环境依赖

		# Update the packages.
		$ sudo apt-get update
		
		# Install a few utility tools.
		$ sudo apt-get install -y tar wget git
		
		# Install the latest OpenJDK.
		$ sudo apt-get install -y openjdk-7-jdk
		
		# Install other Mesos dependencies.
		$ sudo apt-get -y install build-essential python-dev libcurl4-nss-dev libsasl2-dev libsasl2-modules maven libapr1-dev libsvn-dev

4. 编译Mesos

		# Change working directory.
		$ cd mesos
		
		# Configure and build.
		$ mkdir build
		$ cd build
		$ ../configure
		$ make -j 8
		
		# Run test suite.
		$ make check
		
		# Install (Optional).
		$ make install
		
5. Examples

		# Change into build directory.
		$ cd build
		
		# Start mesos master (Ensure work directory exists and has proper permissions).
		$ ./bin/mesos-master.sh --ip=127.0.0.1 --work_dir=/var/lib/mesos
		
		# Start mesos agent (Ensure work directory exists and has proper permissions).
		$ ./bin/mesos-agent.sh --master=127.0.0.1:5050 --work_dir=/var/lib/mesos
		
		# Visit the mesos web page.
		$ http://127.0.0.1:5050
		
		# Run C++ framework (Exits after successfully running some tasks.).
		$ ./src/test-framework --master=127.0.0.1:5050
		
		# Run Java framework (Exits after successfully running some tasks.).
		$ ./src/examples/java/test-framework 127.0.0.1:5050
		
		# Run Python framework (Exits after successfully running some tasks.).
		$ ./src/examples/python/test-framework 127.0.0.1:5050

### 集群搭建Mesos
1. 参考[ Mesos单点Master集群部署](http://blog.csdn.net/u014729236/article/details/46426185)
2. 各节点安装Mesos
- 集群是虚拟机组成:可以先在一个机器上编译安装Mesos，然后通过虚拟机的克隆得到多个节点，则所有节点中都安装好了Mesos
- 集群是实体机器组成:需要在多台机器上按照上述的单机安装Mesos步骤来安装Mesos
3. 修改配置文件


### 参考链接
[mesos get-started](http://mesos.apache.org/gettingstarted/)

[Hadoop安装教程_单机/伪分布式配置_Hadoop2.6.0/Ubuntu14.04](http://www.powerxing.com/install-hadoop/)

