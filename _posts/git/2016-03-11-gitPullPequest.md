---
layout: post
title: 如何在github上创建提交pull request
categories: [git]
description: 解决github上创建pull request的问题
tags: git
date: 2016-03-11
---

### pull requset
所谓pull request,也就是请求对第三方公共库进行修改，我们把我们自己的修改提交到该项目的管理员，让管理员来判断是否对该项目进行修改，以合并该修改请求

### new pull request
在github上，Pullrequests=>New Pull Request，可以看到我们只能比对两个分支。在此分为两种情况，第一种情况为：我们自己是该项目的开发成员，并且在分支中提出了自己的修改，我们可以在此提出pull request;然而大多比较常见的是第二种情况：我们不是该项目的开发者，在这种情况下，我们首先需要做的是fork该项目，在自己fork的项目中进行修改后，再点击compare across forks链接，进行提交

### 情况二举例
- 我们随便选择一个别人(kzx1025)的项目，如kzx1025/LeetCode:git@github.com:kzx1025/LeetCode.git
- 我们(sixiong)在github中fork该项目
- 在本地clone我们fork后的项目，即git clone git@github.com:sixiong/LeetCode.git
- cd LeeCode
- git remote add upstream git@github.com:kzx1025/LeetCode.git
- git fetch upstream
- 修改一些文件
- git add --all
- git commit -m "a new pull request"
- git push origin master
- 在github上打开kzx1025/LeetCode项目主页，选择Pull Requests,点击compare across forks链接，即可把我们刚刚提交的修改提交到别人的项目中，并可对该Pull Request进一步说明

### 参考链接
[实验楼Git实战](https://www.shiyanlou.com/courses/4)

[stackoverflow:how-to-do-a-github-pull-request](http://stackoverflow.com/questions/14680711/how-to-do-a-github-pull-request)
