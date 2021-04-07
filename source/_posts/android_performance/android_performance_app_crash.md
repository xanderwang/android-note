---
seo_title: Android 性能优化 - 稳定性优化
title: Android 性能优化 - 稳定性优化
date: 2021-04-07 17:15:00
tags: 
- Android
- Performance
- 稳定性
categories: 
- Android
---

## 系列文章

- {% post_link android_performance/android_performance Android 性能优化总结 %}
- {% post_link android_performance/android_performance_apk_size APK 瘦身优化 %}
- {% post_link android_performance/android_performance_app_start 启动速度优化 %}
- {% post_link android_performance/android_performance_app_crash 稳定性优化 %}
- 内存的优化
- 操作流畅度优化
- 电量优化



## app 稳定性的维度

app 稳定一般指的是 app 能正常运行， app 不能正常运行的情况分为两大类，分别是 `Crash` 和 `ANR`

> Crash：运行过程中发生的错误，是无法避免的。

> ANR：应用再运行时，由于无法再规定的时间段内响应完，系统做出的一个操作。

## 如何治理 `Crash`

Crash 是运行时的错误，所以如果需要解决的话，就需要捕获这个 Crash ，获取方法调用堆栈，从而解决问题。

Android app 可以分为 2 层，Java 层和 C/C++ 层。所以如何捕获需要分开说

### Java 层获取 Crash 调用堆栈

这个需要了解虚拟机时如何


## 如何治理 `ANR`


