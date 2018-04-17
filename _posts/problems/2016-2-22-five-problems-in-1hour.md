---
layout: post
title: 每个程序员1小时内必须解决的5个编程问题-python解决
categories: [python]
description: 面试题
tags: 面试
date: 2016-02-22
---

### 问题1

> 使用for循环、while循环和递归写出3个函数来计算给定数列的总和

```python
def cal_sum_with_for(n):
	sum = 0
	for i in range(1,n+1):
		sum += i
	return sum

def cal_sum_with_while(n):
	sum = 0
	i = 1
	while(i <= n):
		sum += i
		i++
	return sum

def recur(n):
	if n == 1:
		return 1
	else:
		return recur(n-1) + n
```


### 问题2

 >编写一个交错合并列表元素的函数。例如：给定的两个列表为[a，B，C]和[1，2，3]，函数返回[a，1，B，2，C，3]

```python
	def merge_list(a,b):
		c = []
		for i in range(0,len(a)):
			c.append(a[i])
			c.append(b[i])
		return c		
```

### 问题3
>编写一个计算前100位斐波那契数的函数。根据定义，斐波那契序列的前两位数字是0和1，随后的每个数字是前两个数字的和。例如，前10位斐波那契数为：0，1，1，2，3，5，8，13，21，34。

```python
def fibonacci_list(n):
	result = []
	result.append(0)
	result.append(1)
	for i in range(2,n):
		result.append(result[i-2] + result[i-1])
	return result

print fibonacci_list(100)
```

### 问题4
>编写一个能将给定非负整数列表中的数字排列成最大数字的函数。例如，给定[50，2，1,9]，最大数字为95021。

```python
def getFirstNum(num):
	while (num > 0):
		temp = num % 10
		num = num / 10
		if num == 0:
			return temp

def getMaxNum(data):
	adict = {}
	result = []
	for num in data:
		adict[num] = getFirstNum(num)
	sorted_adict=sorted(adict.items(),key=lambda e:e[1],reverse=True)

	for item in sorted_adict:
		result.append(item[0])
	astr = ""
	for num in result:
		astr += str(num)
	print int(astr)
	return result
data = [50,2,1,9]
print getMaxNum(data)
```

### 问题5



>编写一个在1，2，…，9（顺序不能变）数字之间插入+或-或什么都不插入，使得计算结果总是100的程序，并输出所有的可能性。例如：1 + 2 + 34 – 5 + 67 – 8 + 9 = 100。

```python
#求出所有的表达式组合
def getALLBiaoDashi():
	faze = [' + ',' - ',' * ',' / ','']
	yunsuanfu = []
	num = ['1','2','3','4','5','6','7','8','9']
	biaodashi = []
	i = 0
	while(i < 8):
		if i == 0:
			biaodashi_temp = []
			for j in range(0,5):
				temp = ""
				temp = temp + num[i] + faze[j] + num[i+1]
				# print temp
				biaodashi_temp.append(temp)
			biaodashi.append(biaodashi_temp)
		else :
			biaodashi_temp = []
			for j in range(0,5):
				for s in biaodashi[i-1]:
					temp = s
					temp = temp + faze[j] + num[i+1]
					# print temp
					biaodashi_temp.append(temp)	
			biaodashi.append(biaodashi_temp)
		i += 1
	return biaodashi[7]

#比较两个运算符之间优先关系
def compareYouXianJi(a,b):
	if a == '*' or a == '/':
		if b == '*' or b == '/':
			return 0
		else:
			return 1
	else:
		return 0

#将中缀表达式转换为后缀表达式
def converToHouZhui(biaodashi):
	elems = biaodashi.split()
	result = []
	stack_fuhao = []
	for elem in elems:
		if(elem != '+' and elem != '-' and elem != '*' and elem != '/'):
			result.append(elem)
		else:
			if len(stack_fuhao) == 0:
				stack_fuhao.append(elem)
			else:
				while len(stack_fuhao) !=0 and compareYouXianJi(elem,stack_fuhao[-1]) == 0:
					result.append(stack_fuhao.pop())
				if len(stack_fuhao) ==0 or compareYouXianJi(elem,stack_fuhao[-1]) == 1:
					stack_fuhao.append(elem)

	while (len(stack_fuhao)):
		result.append(stack_fuhao.pop())
	return result

#计算后缀表达式的值
def getValueByHouZhui(houzhui_biaodashi_elems):
	numbers = []
	temp = 0
	for elem in houzhui_biaodashi_elems:
		if(elem != '+' and elem != '-' and elem != '*' and elem != '/'):
			numbers.append(elem)
		else:
			elem1 = float(numbers.pop())
			elem2 = float(numbers.pop())
			if elem == '+':
				temp = elem2 + elem1
			elif elem == '-':
				temp = elem2 - elem1
			elif elem == '*':
				temp = elem2 * elem1
			elif elem == '/':
				temp = elem2 / elem1
			numbers.append(temp)
	return temp

#获取所有满足条件的组合
def getEquals100():
	result = []
	for s in getALLBiaoDashi():
		if getValueByHouZhui(converToHouZhui(s)) == 100.0:
			result.append(s)
	return result
	
print getEquals100()
```

### 总结
在微博上看到这个帖子[每个程序员1小时内必须解决的5个编程问题](http://www.codeceo.com/article/5-problems-programmer-1-hour.html),觉得很有意思，正好最近在使用python， 于是决定用python尝试着解决一下，花了整个下午的时间（说好的1小时呢），到晚上才整出整套代码。其中4、5题，都是采用比较常规的方法，虽然解决了问题，但其空间性能较低，应该有其它较好的方法，欢迎探讨！
