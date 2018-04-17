---
layout: post
title: 简单RPC框架升级版
categories: [java]
description: 简单RPC框架升级版
tags: java
date: 2017-08-04
---

## 一、准备

> 在[简单版本](http://sxiong.net/java/2017/07/26/simple-rpc.html)的基础上,进行一些优化工作,打造升级版的RPC框架,我们首先通过一个RPC的调用过程来了解RPC的原理
![RPC示意图](http://sixiong.github.io/images/java/rpcflow.png)


## 二、一次RPC框架请求的流程
1. 客户端调用了某个服务的方法,期望得到处理的结果
2. 把本次调用的上下文,如服务名\方法签名\参数等信息序列化,构造request
3. 根据被调用的服务名,方法签名等信息可以找到提供服务的server列表
4. 根据负载均衡,从server列表中随机选取一个server作为目标进行调用
5. 向选出的server发送该请求,客户端线程挂起
6. server接收到请求,反序列并解析得到对应的服务名,方法名,参数等信息
7. server根据调用信息找到真正的业务服务实例,调用业务服务的相应方法
8. 把方法的返回值序列化,构造成response返回给客户端
9. 把response传回给client
10. client把接收到的response反序列化,得到服务处理结果,返回1中客户端调用处,唤起对应客户端线程

## 三、优化改进
- 序列化方式
	- 对应上图流程中的步骤2\6\810等序列化反序列化操作
	- 从原来的仅支持原生java序列化,改进成支持多种序列化方式
	- (现在仅支持Hessian,按工厂模式设计,可拓展添加额外的序列化方式
- 通信方式
	- 对应上图流程中的步骤5\6\9等发送请求\接受请求\响应请求等操作
	- 从原来的Socket通信,改进成使用Netty通信
	- 通信更加稳定,方式更加灵活
- 服务动态管理
	- 对应上图流程中的步骤4,以及服务启动时的注册等操作
	- 从原来的服务静态不可控,改进成动态发现服务,并可实现服务的上线\下线等管理,更加灵活多变
	- 引入zookeper组件,响应客户端对服务的监听,以及服务端对服务的管理操作
- 负载均衡
	- 引入zookeeper,可响应多服务节点的加入,即形成服务和节点之间的1:n关系
	- 客户端在发起请求时,根据服务列表随机选出一个server node,实现负载均衡的效果

## 四、总结
- 对Netty的使用理解还不够,可能还有bug
- 可以引入spring框架.实现服务的动态注入
- 实现代码见参考里的地址,逐步完善中

## 参考
[Java实现简单的RPC框架(转)](http://sxiong.net/java/2017/07/26/simple-rpc.html)

[源码地址](https://github.com/sixiong/yarpc/tree/master)