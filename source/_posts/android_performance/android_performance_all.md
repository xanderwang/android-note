---
seo_title: Android 性能优化总结
title: Android 性能优化总结
date: 2021-04-01 20:01:01
tags: 
- Android
- Performance
categories: 
- Android
---

性能的优化是一个老生常谈的点，也是一个比较重要的点。现在对工作中的优化点做一个总结。

# 优化的方向，即那些点是需要优化的

在平时的优化过程中我们需要从哪几个点来优化呢？其实我们平时自己一定也用过软件，在使用软件的过程中有没有什么想吐槽的呢？

“这个 app 怎么还没下载完！”、“太卡了吧！”、"图片怎么还没加载出来！"、"怎么刚进去就卡了！"、“这么点了一下就退出了！”等等，是不是有这样的想法，这些想法其实包含了我们今天要说的内容，就是从哪些方面来优化我们的 APP ，我总结了以下几点。

- {% post_link android_performance/android_performance_app_size APK 瘦身优化 %}
- {% post_link android_performance/android_performance_app_start 启动速度优化 %}
- {% post_link android_performance/android_performance_app_crash 稳定性优化 %}
- {% post_link android_performance/android_performance_app_memory 内存的优化 %}
- {% post_link android_performance/android_performance_app_caton 操作流畅度优化 %}

当然，需要优化的不仅仅是这几个方面，我们暂时先就这几个方面来谈谈优化吧

# APK 瘦身

APK 包如果小的话，下载和安装的时间都会变快，而且较少的投入可以看到较明显的效果，APK 瘦身很值得优化，具体的优化方法可以参考下面的连接。

{% post_link android_performance/android_performance_app_size APK 瘦身优化 %}

# 启动速度

启动速度是每个应用都会碰到和需要优化的，这里总结了一下本人工作中的启动优化，详细的内存请参考下面的链接。

{% post_link android_performance/android_performance_app_start 启动速度优化 %}

# 稳定性优化

稳定性优化，是个重中之重的优化了，毕竟没有谁喜欢在使用 APP 的过程中“闪退”。我是如何做稳定性优化的？可以参考下面的链接。

{% post_link android_performance/android_performance_app_crash 稳定性优化 %}

# 内存的优化

内存的优化，是一个持久的优化，因为我发现，经常是这次修好了，下次另外一个地方又有问题了，我对内存的优化可以参考下面的链接。

{% post_link android_performance/android_performance_app_memory 内存的优化 %}

# 操作流畅度优化

流程度的优化说起来，也是很重要的。毕竟动不动就卡顿的体验属实不好，按照惯例，操作流畅度优化可以参考下面的链接。

{% post_link android_performance/android_performance_app_caton 操作流畅度优化 %}

