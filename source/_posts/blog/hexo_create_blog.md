---
seo_title: 利用 GitHub 搭建自己的个人博客
title: 利用 GitHub 搭建自己的个人博客
date: 2021-02-25 22:00:00
tags:
- Github Action
- GitHub Page
- Gitee Page
- hexo
categories: 
- 其他
---

先看下预览图吧。

![预览图](https://img.imgdb.cn/item/6037cadc5f4313ce25858739.png)

先说下方案:

>  GitHub Page + GitHub Action + hexo & 配套主题 

# GitHub Page 

这个都不陌生吧，注册 GitHub 账号后，可以帮你托管你的 `repository` 下的静态网页，比如我有个 `repository` 叫  `android-note` ，我的 github 账号叫 `xanderwang` ，那么我的 android-note 托管后，访问地址就是：

> [https://xanderwang.github.io/android-note](https://xanderwang.github.io/android-note)

托管后，如果我每次写了新的文章后，我把最新的静态 blog 上传上来，那么就可以更新自己的博客。

如果每次都可以自动编译和上传 blog 静态网页，那就很省事了。事实上，这个是可以做到的，具体细节后面再说。我们先看看如何托管我们的 `repository` 到 GitHub Page 。

最开始接触到 GitHub Page 的时候，看文章都是说需要新建一个和自己用户名同名的 `repository` ，然后往这个 `repository` 根目录里面上传静态 blog 网页，然后托管。

后来我发现不是这样，至少目前不是这样，我发现任意的 `repository` 都可以托管，只需要做一些特别的设置，如何设置呢？

找到你的 `repository` ，然后

> settings -> GitHub Pages -> Source -> 选择分支和静态博客的目录(貌似只能选 `/` 或者 `/doc`)

到这里 GitHub 托管就设置好了。按照之前的规则你就可以访问你托管 blog 了。

# GitHub Action

刚刚说了，如果有个自动编译和上传 blog 的工具或者平台，每次我们写好 blog 后，自动帮我们编译上传好，那我们就可以省很多事。GitHub Action 正好可以做这个的，而且可以和 GitHub 无缝对接。那如何使用呢？

很简单，只需要在你的 `repository` 里面新建 `.github` 文件夹，然后在里面新建 `.workflows` 文件夹，然后在里面新建 `build.yml` 文件(build 可以换成任意你喜欢的)，然后 GitHub Action 功能就开通了。这个时候， `repository` 下的目录结构大概是
```
.
├── .github
│   └── workflows
│       └── build.yml
```

现在介绍下如何配置 build.yml 文件

```yml
name: Xander's Blog Task
# 在push **.md **.yml **.yaml **.sh 文件后执行任务
on: #配置任务执行时机
  # Trigger the workflow on push or pull request,
  # but only for the master branch
  push:
    # branches:    
    #   - master
    paths:
      - '**.md'
      - '**.yml'
      - '**.yaml'
      - '**.sh'
jobs: # 配置具体任务
  build:
    # runs-on: macOS-latest
    runs-on: ubuntu-latest
    steps:
    # 引用外部 Action, 拉取代码仓库到虚拟机工作目录
    - name: chekout code
      uses: actions/checkout@v1
    # 执行 .sh 脚本文件，很多的任务可以在这个脚本里面执行
    - name: build note
      run: sh ./blog_config/build.sh
# ... 忽略其他内容
```
上面列出了主要的步骤和解释了，具体可以参考[我的 repository](https://github.com/XanderWang/android-note) 

这里需要说明的是，如果你需要额外传一些参数，比如密码是的，你需要现在 repository 做一些设置，具体参考如下：

> settings -> secrets -> 新建一个 secret 

然后在你的 `build.yml` 里面使用
```yml
steps:
  - name: Hello world action
    with: # Set the secret as an input
      super_secret: ${{ secrets.SuperSecret }}
    env: # Or as an environment variable
      super_secret: ${{ secrets.SuperSecret }}
    run: |
      example-command "$super_secret"
```

到这里自动编译和发布的工作就说完了，现在我们还缺什么？


# hexo & 配套主题 

前面说了托管和自动编译和发布，现在我们就差一个个性化的静态 blog 模板了，这里我选择的是 hexo & 配套主题。

## hexo

这个是一个静态的博客构建软件，配合网络上的主题，可以比较方便构建出自己的博客，同时有大量的精美主题可以选择。

如何安装就不具体说了，不是很难，官网有很详细的教程。

[点我直达 hexo 官网](https://hexo.io/zh-cn/index.html)

## hexo 配套主题

主题的话，一般可以在 GitHub 上面找，我暂时用的 [volantis](https://volantis.js.org/)，可以去官网看下这个主题的具体介绍和相关配置。

这里说下可能遇到的坑的，

这里说下 _config.yml

```yml
...

# URL
## If your site is put in a subdirectory, set url as 'http://yoursite.com/child' and root as '/child/'
url: https://xanderwang.github.io/android-note
root: /android-note/
# 需要注意这里的配置，注意 url 和 root 的配置，如果不是用的 GitHub 同名 repository 托管的，都需要配置

# Directory
public_dir: docs      # 公共文件夹，这个文件夹用于存放生成的站点文件。
# public_dir 目录就是 hexo 编译后存放静态 html 的目录，在托管 GitHub Page 的时候注意选择这个目录。

...

```

其他的配置就是主题配置了，这个建议按照注意的 repository 或者主题的 demo 去配置，每个主题都是不一样的，只能靠自己的折腾了。 

