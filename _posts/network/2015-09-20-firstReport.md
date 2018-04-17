---
layout: post
title: SDN网络Report One
categories: [network]
description: 网络课设第一次实验报告,关于mininet-pox的应用
tags: network
date: 2015-09-20
---
## mininet-pox的安装
- 实验环境：Ubuntu 12.04
- mininet的安装

![](http://7xk5ic.com1.z0.glb.clouddn.com/mininet-install.jpg)
- pox的安装

`git clone https://github.com/noxrepo/pox.git`，之后便可以在pox目录下调用pox.py脚本运行启动pox（PS:在按照上述方式安装好mininet后，pox也自动安装好了，pox与mininet处于同一目录级别下）

## 小题1实现
1. 因为控制器需要使用POX，故先启动POX，启动方式如下：
    `hadoop@sxiong-System-Product-Name:~/pox/pox$ ../pox.py openflow.of_01 -address=127.0.0.1 forwarding.l2_learning`
2. 接着启动mininet，需要实现自定义的一个top结构，结构如下图1所示![](http://7xk5ic.com1.z0.glb.clouddn.com/topo.jpg)
此topo结构一共有2中实现方式，分别为自带的线性结构与自定义拓扑文件两种实现方式，其调用代码如下：

----------   
- 线性方式： `sudo mn --topo linear --switch ovsk --controller remote`
- 自定义拓扑：`sudo mn --custom topo-2sw-2host.py --topo mytopo --controller remote`，其中‘topo-2sw-2host.py’路径为`mininet/custom/topo-2sw-2host.py`，是mininet自带的自定义拓扑文件的一个举例。

## 小题2实现
1. 分析题目意思，即需要我们借助pox控制器利用python代码去修改流表，以达到h1-h2之间无法相互ping通.
2. 在pox中自定义一个组件，其方式可以借助下图所示方法来实现![](http://7xk5ic.com1.z0.glb.clouddn.com/you_own_Com.jpg)
按照上述所述方法，我们把在小题1中使用的l2_learning文件拷贝到ext文件目录下，并将其更改名称为myself.py
3. 对myself.py进行修改，即如下插入代码片段，插入的位置为第144行，即dorp函数定义结束处，pox启动代码为`../pox.py openflow.of_01 -address=127.0.0.1 myself`

		#drop packet host1 to host2 and host2 to host1
		msg = of.ofp_flow_mod() #声明一个修改流表的消息
		msg.match.dl_type = 0x0800 #定义匹配的ip类型为IPV4
		msg.match.nw_dst = IPAddr("10.0.0.1") #定义匹配的目的地址为10.0.0.1,即h1
		self.connection.send(msg)#pox将此消息发送到各个交换机，即s1、s2，其中流表的action没有定义，即为丢弃操作

&nbsp;&nbsp;4. 实现结果如图所示![](http://7xk5ic.com1.z0.glb.clouddn.com/result_2.jpg)

## 小题3的实现
1. wireshark的安装:`sudo apt-get install wireshark`
2. wireshark的启动:`sudo wireshark &`
3. 更改myself.py，添加清空流表操作（代码位置为`LearningSwitch`类的末尾），代码片段如下：

		#create ofp_flow_mod message to delete all flows
		msg = of.ofp_flow_mod(command=of.OFPFC_DELETE) #声明一个清空流表的消息
	  	self.connection.send(msg)#pox发送给各个交换机，即s1、s2
	  	log.debug("Clearing all flows from %s." % (dpid_to_str(connection.dpid),))#打印相关信息

&nbsp;&nbsp;4. 借助wireshark工具观察其发数据包的行为，首先打开wireshark后得到interfaces list选择界面，如图所示
![](http://7xk5ic.com1.z0.glb.clouddn.com/wireshark_1.jpg)，我们在这里选择s1-eth1来观察其发包行为，下图为流表清空后在mininet Cli中执行`h1 ping -c 4 h2`指令的发包结果
![](http://7xk5ic.com1.z0.glb.clouddn.com/wireshark_2.jpg)

### 结论
- 从上图分析可知，当流表清空后，h1向h2发送请求时，会首先向网络中所有节点发送一个广播，通过ARP协议来获取h2的mac地址，即“who has 10.0.0.2”；接着，因为流表已经被清空，交换机s1向控制器pox询问路由信息，告诉ip为10.0.0.2的链路mac地址为06.f6.12.74.de.db（s2）,从而实现h1到h2之间的链路通路；最后h1开始向h2发送ping请求，相应的h2回应h1的过程也如上述所示。
- 而非SDN交换机当流表清空后，不再具备获取路由信息的能力。即非SDN交换机自己管理自己的路由表信息，一旦被清空，则成了“瞎子”。
- 通过上述对比分析，可以很明显看出SDN交换机的优点所在，这也是控制和数据分离设计所带来的优点体现。

### 附件
- [myself.py](http://7xk5ic.com1.z0.glb.clouddn.com/myself.py "myself.py")
- [mininet参考文献](http://sdnhub.cn/index.php/mininet-walkthrough-chinese/ "mininet")
- [pox参考文献](https://openflow.stanford.edu/display/ONL/POX+Wiki "pox")
