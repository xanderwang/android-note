---
seo_title: Android 性能优化 - 操作流畅度优化
title: Android 性能优化 - 操作流畅度优化
date: 2021-04-10 18:15:00
tags: 
- Android
- Performance
- 操作流畅度优化
categories: 
- Android
---

## 系列文章

- {% post_link android_performance/android_performance_all Android 性能优化总结 %}
- {% post_link android_performance/android_performance_app_size APK 瘦身优化 %}
- {% post_link android_performance/android_performance_app_start 启动速度优化 %}
- {% post_link android_performance/android_performance_app_crash 稳定性优化 %}
- {% post_link android_performance/android_performance_app_memory 内存的优化 %}
- {% post_link android_performance/android_performance_app_caton 操作流畅度优化 %}

## 为什么会卡顿

为什么卡顿之前，我们先需要简单了解一点硬件相关的知识。就是在界面绘制的过程中， CPU 主要的任务是计算出屏幕上所有 View 对应的图形和向量等信息。 GPU 的主要任务就是把 CPU 计算出的图形栅格化并转化为位图，可以简单理解为屏幕像素点对应的值。

如果操作过程中卡顿了，一般就是 CPU 和 GPU 其中的一个或者多个无法短时间完成对应的任务。

一般而言，CPU 除了需要计算 View 对应的图形和向量等信息，还要做逻辑运算和文件读写等任务，所以 CPU 造成卡顿更常见。一般也是通过减少 CPU 的计算来优化卡顿。

影响 CPU 的使用率一般有以下几个方面：

- 读写文件。
- 解析大量图片。
- 频繁请求网络。
- 复杂的布局。
- 大量创建线程。
- 频繁的 IPC 通讯。

## 如何检测卡顿

虽然我们知道了大概哪些原因会导致卡顿，但是我们无法准确定位出问题的代码点在哪里，针对上面的部分问题，本人写了一个开源库来自动检测，这个开源库的地址是

> [https://github.com/XanderWang/performance](https://github.com/XanderWang/performance)

详细的原理，可以参考上面的连接，这里简单总结下监控 UI 卡段的原理。

我们知道，Android 里面，界面的刷新需要再主线程或者说 UI 线程执行。而界面的绘制起始点又利用了 Looper 消息循环机制。查阅 Looper 消息循环机制发现一个有意思的特点，就是 Looper 在 dispatch Message 的时候，会在 dispatch 前和 dispatch 后利用 printer 打印特定 tag 的字符串，通过接管 printer 后，我们就可以获取 dispatch message 前后的时机。

然后我们可以在 dispatch message 之前，在异步线程启动一个抓取系统信息的延时任务。在 dispatch message 之后，我们可以移除异步线程的这个延时任务。如果某个消息的执行没有超过阈值，那就表示在异步线程的延时任务被取消，表明没有卡顿。如果某个消息的 dispatch 超过了阈值，那在异步线程的延时任务就会执行，表明有卡顿，通过异步线程的延时任务可以获取此时的系统状态，从而辅助我们分析卡顿问题。


## 如何优化卡顿

1. 读写文件。



1. 解析大量图片。



1. 频繁请求网络。

1. 复杂的布局。

1. 大量创建线程。

1. 频繁的 IPC 通讯。