---
seo_title: Android 性能优化 - 内存优化
title: Android 性能优化 - 内存优化
date: 2021-04-10 17:15:00
tags: 
- Android
- Performance
- 内存优化
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

硬件的内存总是有限的，所有每个应用分到的内存也是有限的，所有内存的优化很有必要，否则应用就没有足够的内存使用了，这个时候就会 Crash 。

## 内存都消耗在哪里了

优化内存的话，需要了解内存在哪里消耗了了，针对内存消耗大的场景做优化，对症下药，才可以有一个好的优化效果。

`Android Studio` 里面的 `Profiler` 工具是一个很好用的工具，通过里面的 `memory` 工具可以`实时监控` APP 运行过程中的内存分配。

![内存性能分析器](https://img.imgdb.cn/item/60742b578322e6675cac02b9.jpg)

dump APP 内存堆栈后，还可以看到各个类占用的内存情况。

![有关每个已分配对象的详细信息显示在右侧的 Instance View 中](https://img.imgdb.cn/item/60742b928322e6675cac8841.jpg)

可以查看每个对象的详细信息。

`Android Studio` 里面的 `Profiler` 工具的具体使用教程请参考[官方教程](https://developer.android.google.cn/studio/profile/memory-profiler?hl=zh-cn)，这里就不做详细介绍了。

## 如何合理使用内存

利用上面的方法，找到内存消耗大的场景，就需要做优化了，主要做法就是想办法减少特定场景下的内存的使用。个人总结了一下平时可能会做的优化。

- 图片相关的优化

图片是我目前做的应用里面占用内存比较大的一块了，也碰到了一些问题，我主要是通过以下的方法来做优化。

1. 暂时用不上的图片不加载，比如说，有个网络加载异常的图，不要一开始就初始化，等到真的有异常了需要展示的时候再初始化
2. 加载图片的时候，尽量加载指定大小的图片，因为有时候会碰到控件的大小小于实际图片尺寸的情况，这个时候，会浪费一些内存。有需要的话，可以让后台返回不同尺寸的图片。
3. 根据不同的图片格式
4. 不显示的图片，可以考虑先释放。

- 尽可能少地创建对象

毫无疑问，如果对象少，内存肯定也消耗的少，那平时需要注意哪些呢？

1. 自定义 view 的时候，不要在 onDraw 方法里面频繁创建对象。因为 onDraw 方法可能会频繁调用，这个时候就会创建大量的对象。从而造成浪费，同时也会导致 gc 触发的频率升高，造成卡顿。
2. 尽量少创建线程，创建线程其实是比较消耗资源的，创建一个空的线程，大概会占用 1-2 M 内存。同时一般异步任务很快就会执行完，如果频繁创建线程来做异步任务，除了内存使用的多，还可能 GC 造成卡顿。执行异步任务的话，一般建议用线程池来执行，但是需要注意线程池的使用。
3. 尽量用 StringBuilder 或者 StringBuffer 来拼接字符串。平时发现的问题主要是在打印 logcat 的时候和拼接后台返回的数据的时候会创建大量的 String，所以如果有类似的情况也可以考虑做一些优化。


## 内存泄漏是什么

内存泄漏指的是本应该释放的内存，由于一些原因，被 GC ROOT 对象持有，从而而无法在 GC 的时候释放，这样可能会导致的一个问题就是，重复操作以后，APP 没有足有的内存使用了，这个时候系统会杀死 APP 。所以内存泄漏是需要排查的。

## 如何监控和分析内存泄漏问题

上一个小结总结了上面是内存泄漏，是因为某些 GC ROOT 对象持有了期望释放的对象，导致期望释放的内存无法及时释放。所以如何监控和分析内存泄漏问题就成了如何找到 GC ROOT 的问题。

一般手动分析的步骤是：重复操作怀疑有内存泄漏的场景，然后触发几次 GC 。等几秒钟后，把 APP 的内存堆栈 dump 下来(可以使用 as 的工具 dump)，然后用 sdk 里面的 cover 工具转换一下，然后用 MAT 工具来分析内存泄漏的对象到 GC ROOT 的引用链。

手动分析总是很麻烦的，一个好消息是，有一个特别好用的自动监控和分析内存泄漏的工具，这个工具就是 leakcanary ，它可以自动监控并给出内存泄漏的对象到 GC ROOT 的引用链。

使用很简单，只需要在 APP  的 build.gradle 下面新增

```
debugImplementation 'com.squareup.leakcanary:leakcanary-android:2.0-alpha-2'
```

leakcanary 比较核心的一个原理就是利用了弱引用的一个特性，这个特性就是：

> 在创建弱引用的时候，可以指定一个 RefrenceQueue ，当弱引用引用的对象的可达性发生变化的时候，系统会把这个弱引用引用的对象放到之前指定的 RefrenceQueue 中等待处理。

所以 GC 后，引用对象仍然没有出现在 RefrenceQueue 的时候，说明可能发生了内存泄漏，这个时候 leakcanary 就会 dump 应用的 heap ，然后用 shark 库分析 heap ，找出一个到 GC ROOT 的最短引用链并提示。

## 常见的内存泄漏的场景

个人总结了下工作中碰到内存泄漏的一些场景，现记录下来，大家可以参考下。

1. 静态变量持有 Context 等。
2. 单例实例持有 Context 等。
3. 一些回调没有反注册，比如广播的注册和反注册等，有时候一些第三方库也需要注意。
4. 一些 Listener 没有手动断开连接。
5. 匿名内部类持有外部类的实例。比如 Handler , Runnable 等常见的用匿名内部类的实现，常常会不小心持有 Context 等外部类实例。

# 联系我

- Github: [https://github.com/XanderWang](https://github.com/XanderWang)

- Mail: <420640763@qq.com>

- Blog: [https://xander_wang.gitee.io/android-note/](https://xander_wang.gitee.io/android-note/)