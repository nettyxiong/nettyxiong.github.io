---
layout: post
title: CentOS 7.3 使用kubeadm搭建kubernetes集群
categories: [bigdata]
description: 实现kubernets集群的搭建
tags: kubernetes
dates: 2017-08-03
---

## 集群说明

``` bash
host68 = 192.168.0.68
host93 = 192.168.0.93
host94 = 192.168.0.94
host95 = 192.168.0.95
#其中，host68为主节点，host93-95为从节点
```

## 准备工作（on all nodes)

- 添加google源

	```bash
	cat <<EOF > /etc/yum.repos.d/kubernetes.repo
	[kubernetes]
	name=Kubernetes
	baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
	enabled=1
	gpgcheck=1
	repo_gpgcheck=1
	gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
			https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
	EOF
	```

- 由于被墙，需要更新/etc/hosts

	添加以下内容，可能会失效，可以在[这里](https://github.com/racaljk/hosts)找到google的实时host文件替换，或者自己翻墙，设置htpp_proxy、https_proxy

	```bash
	216.58.195.238 gcr.io
	216.58.195.238 www.gcr.io
	216.58.195.238 packages.cloud.google.com
	```
- 屏蔽selinux

	```bash
	setenforce 0
	sudo sed -i.bak 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config
	```
- 启动docker、kublet

	``` bash
	sudo yum install -y docker kubelet kubeadm
	sudo systemctl enable docker && sudo systemctl start docker
	sudo systemctl enable kubelet && sudo systemctl start kubelet

	//kubelet启动失败时运行这条指令
	kubeadm reset && systemctl start kubelet
	```

## 主节点

``` bash
sudo kubeadm  reset && sudo systemctl start kubelet
sudo kubeadm init --apiserver-advertise-address=192.168.0.68 --pod-network-cidr=10.244.0.0/16
#  --apiserver-advertise-address=192.168.0.68 指定节点间通信的网卡，单网卡情况可以省略。
# --pod-network-cidr=10.244.0.0/16 打算使用flannel网络

# 创建pod网络，选择flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel-rbac.yml
# 根据官方参考问答检验是否创建成功，具体命令是`kubectl get pods --all-namespaces`
```

## 从节点

```bash
# 这三部主要是为了让从节点下拉google的k8s镜像
sudo kubeadm reset
sudo kubeadm init
sudo kubeadm reset

#再次保证kublet启动成功，也可以不运行，视情况而定
sudo kubeadm reset && sudo systemctl start kubelet

# --skip-preflight-checks选项主要是为了排除ip地址检查，这个好像是个bug，排除这个检查也可以成功添加从节点，故加上
sudo kubeadm join --token=81ff87.5216e73436b2308c 192.168.0.68:6443 --skip-preflight-checks
```

## 检查

```bash
[hadoop@host68 ~]$ kubectl get nodes
NAME      STATUS    AGE       VERSION
host68    Ready     5h        v1.7.2
host93    Ready     50m       v1.7.2
host94    Ready     4h        v1.7.2
host95    Ready     39m       v1.7.2
```

## 参考链接

[官方安装文档](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)
