---
layout: post
title: ubuntu14.04下搭建hadoop集群
categories: [bigdata]
description: 实现hadoop集群的搭建
tags: hadoop
date: 2016-08-24
---

### 环境
- ubuntu 14.04 64位
- hadoop 2.7.2
- java 7

### 准备工作
- 修改/etc/hosts

	| hostname | ip |
	| ------| ------ |
	| master | 192.168.154.131 |
	| slave01 | 192.168.154.133 |
	| slave02 | 192.168.154.134 |
	| slave03 | 192.168.154.135 |

- 创建hadoop用户

```bash
sudo useradd -m hadoop -s /bin/bash
sudo passwd hadoop
sudo adduser hadoop sudo
```

- 安装ssh，配置无密码登陆
{% highlight bash %}
#在master上
hadoop@naster$ sudo apt-get install ssh
hadoop@naster$ cd ~/.ssh/
hadoop@naster$ sshkey-gen -t rsa
hadoop@naster$ cat id_rsa.pub >> authorized_keys
hadoop@naster$ scp id_rsa.pub hadoop@slave0${1-3}:~/
#在slave01-slave03上
hadoop@slave01$ cat id_rsa.pub >> ~/.ssh/authorized_keys
hadoop@slave01$ cat id_rsa.pub >> ~/.ssh/authorized_keys
hadoop@slave01$ cat id_rsa.pub >> ~/.ssh/authorized_keys
#测试
hadoop@master$ ssh master | ssh slave01 | ssh slave02 | ssh slave03
{% endhighlight %}
- 配置java环境
{% highlight bash %}
$ sudo apt-get install openjdk-7-jdk
$ dpkg -L openjdk-7-jdk | grep '/bin/javac'
/usr/lib/jvm/java-7-openjdk-amd64/bin/javac
$ vim ~/.bashrc
#add line 'export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64' in the last line
$ source ~/.bashrc
$ echo $JAVA_HOME
{% endhighlight %}	
### 安装Hadoop
1.下载[Hadoop2.7.2](http://www.apache.org/dyn/closer.cgi/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz)

2.解压hadoop
{% highlight bash %}
hadoop@master$ mkdir spark-all
cd spark-all
hadoop@master:~/spark-all$ tar zxvf ~/Downloads/hadoop-2.7.2.tar.gz
hadoop@master:~/spark-all$ mv hadoop-2.7.2 hadoop
hadoop@master:~/spark-all$ cd spark-all/hadoop/etc/hadoop
{% endhighlight %}

3.修改hadoop的配置文件（~/spark-all/hadoop/etc/hadoop/）

- masters
{% highlight bash %}
masterssss
{% endhighlight %}
- slaves
{% highlight bash %}
slave01
slave02
slave03
{% endhighlight %}
- core-site.xml
{% highlight xml %}
        <configuration>
            <property>
                    <name>fs.defaultFS</name>
                    <value>hdfs://master:9000</value>
            </property>
            <property>
                    <name>hadoop.tmp.dir</name>
                    <value>file:/usr/local/hadoop/tmp</value>
                    <description>Abase for other temporary directories.</description>
            </property>
        </configuration>
{% endhighlight %}
		
- hdfs-site.xml
{% highlight xml %}
    <configuration>
        <property>
                <name>dfs.namenode.secondary.http-address</name>
                <value>master:50090</value>
        </property>
        <property>
                <name>dfs.replication</name>
                <value>1</value>
        </property>
        <property>
                <name>dfs.namenode.name.dir</name>
                <value>file:/usr/local/hadoop/tmp/dfs/name</value>
        </property>
        <property>
                <name>dfs.datanode.data.dir</name>
                <value>file:/usr/local/hadoop/tmp/dfs/data</value>
        </property>
    </configuration>
{% endhighlight %}

- mapred-site.xml
{% highlight xml %}
    <configuration>
        <property>
                <name>mapreduce.framework.name</name>
                <value>yarn</value>
        </property>
        <property>
                <name>mapreduce.jobhistory.address</name>
                <value>master:10020</value>
        </property>
        <property>
                <name>mapreduce.jobhistory.webapp.address</name>
                <value>master:19888</value>
        </property>
    </configuration>
{% endhighlight %}
- yarn-site.xml
{% highlight xml %}
    <configuration>
        <property>
                <name>yarn.resourcemanager.hostname</name>
                <value>master</value>
        </property>
        <property>
                <name>yarn.nodemanager.aux-services</name>
                <value>mapreduce_shuffle</value>
        </property>
    </configuration>
{% endhighlight %}
- hadoop-env.sh

{% highlight bash %}
    export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
{% endhighlight %}
    
4.拷贝文件到slaves
{% highlight bash %}
    hadoop@master:$ scp -Cr spark-all hadoop@slave0${1-3}:~/
    hadoop@slave01$: sudo chown -R hadoop spark-all
    hadoop@slave02$: sudo chown -R hadoop spark-all
    hadoop@slave03$: sudo chown -R hadoop spark-all
{% endhighlight %}	
5.格式化hdfs
{% highlight bash %}
    hadoop@master:$ hdfs namenode -format
{% endhighlight %}
6.启动hadoop
{% highlight bash %}
    hadoop@master:$ start-dfs.sh
    hadoop@master:$ start-yarn.sh
    hadoop@master:$ mr-jobhistory-daemon.sh start historyserver
{% endhighlight %}
7.检查

- WEB UI [http://master:50070](http://master:50070)
- jps
{% highlight bash %}
    #master
    hadoop@master:$ jps
    NameNode
    ResourceManager
    SecondrryNameNode
    JobHistoryServer
    Jps
    #slave
    hadoop@slave01:$ jps
    DataNode
    NodeManager
    Jps  
{% endhighlight %}
8.执行分布式实例

- 创建用户
{% highlight bash %}
    hdfs dfs -mkdir -p /user/hadoop
{% endhighlight %}
- 设置输入
{% highlight bash %}
    hdfs dfs -mkdir input
    hdfs dfs -put /usr/local/hadoop/etc/hadoop/*.xml input
{% endhighlight %}
- 执行
{% highlight bash %}
    hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar grep input output 'dfs[a-z.]+'
{% endhighlight %}
- 检查 [http://master:8080/cluster](http://master:8080/cluster)

9.停止hadoop

{% highlight bash %}
    stop-yarn.sh
    stop-dfs.sh
    mr-jobhistory-daemon.sh stop historyserver
{% endhighlight %}

### 参考链接
[Hadoop集群安装配置教程_Hadoop2.6.0_Ubuntu/CentOS](http://www.powerxing.com/install-hadoop-cluster/)

[Hadoop安装教程_单机/伪分布式配置_Hadoop2.6.0/Ubuntu14.04](http://www.powerxing.com/install-hadoop/)
