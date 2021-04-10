---
seo_title: Android 性能优化 - 启动速度优化
title: Android 性能优化 - 启动速度优化
date: 2021-04-06 17:15:00
tags: 
- Android
- Performance
- 启动速度优化
categories: 
- Android
---

## 系列文章

- {% post_link android_performance/android_performance_all Android 性能优化总结 %}
- {% post_link android_performance/android_performance_all Android 性能优化总结 %}
- {% post_link android_performance/android_performance_app_size APK 瘦身优化 %}
- {% post_link android_performance/android_performance_app_start 启动速度优化 %}
- {% post_link android_performance/android_performance_app_crash 稳定性优化 %}
- {% post_link android_performance/android_performance_app_memory 内存的优化 %}
- {% post_link android_performance/android_performance_app_caton 操作流畅度优化 %}

## 启动的类型

一般分为，冷启动和热启动

> 冷启动：启动时，后台没有任何该应用的进程，系统需要重新创建一个进程，并结合启动参数启动该应用。

> 热启动：启动时，系统已经有该应用的进程(比如按 home 键临时退出该应用)下启动该应用。

## 如何获取启动时间

1. adb 命令

adb shell am start -S -W 包名/启动类的全名

```
adb shell am start -S -W xxx/xxxActivity
Stopping: xxx
Starting: Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] cmp=xxx/xxxActivity }
Status: ok
Activity: xxx/xxxActivity
ThisTime: 770
TotalTime: 770
WaitTime: 848
Complete
```

**ThisTime**: 表示最后一个 Activity 启动时间

**TotalTime**: 表示启动过程中，所有的 Activity 的启动时间

**WaitTime**: 表示应用进程的创建时间 + TotalTime

一般我们关注 `TotalTime` 就好了。

另外，谷歌在 Android4.4（API 19）上也提供了测量方法，在 logcat 中过滤 Displayed 字段也可以看到启动时间

> 2021-04-06 19:25:52.803 2210-2245 I/ActivityManager: Displayed xxx/xxxActivity: +623ms

`+623ms` 就是Activity 的启动时间。

2. 时间戳

时间戳的方法基于以下的 2 个知识点。

- 应用进程刚创建，会调用 Application 的 onCreate 方法。
- 首次进入一个 Activity 后会在 onResume() 方法后面调用 onWindowsFocusChange 方法。

结合这 2 个特性，我们可以在
A
Application 的 onCreate() 方法和 Activity 的 onWindowsFocusChange 方法里面，通过时间戳来获取应用的冷启动时间。

## 如何监控启动过程

1. systrace

systrace 是一个功能很强大的工具，除了可以查看卡顿问题，也可以用来查看应用的启动问题。使用示例如下：

> python $ANDROID_HOME/platform-tools/systrace/systrace.py gfx view wm am pm ss dalvik app sched -b 90960 -a 你的包名 -o test.log.html

用 Google  浏览器打开 `test.log.html` 就可以看到详细的启动信息。

2. Debug 接口

```
package android.os;
...
class Debug {
    ...
    public static void startMethodTracingSampling(String tracePath, int bufferSize, int intervalUs) {

    }
    public static void startMethodTracing(String tracePath, int bufferSize) {

    }
}
```

利用 Debug 类的这两个方法，可以生成一个 `trace` 文件，这个 `trace` 文件，可以直接在 `AS` 里面打开，可以看到从 `startMethodTracingSampling` 到 `startMethodTracing` 过程中的方法调用等信息，也可以较好的分析启动问题。

## 一般有那些方法

1. 耗时操作放到异步进程

比如文件解压、读写等耗时 IO 操作可以新开一个线程来执行。

2. 延时初始化

即暂时不适用的工具类等延后到使用的时候再去初始化。比如从 xml 里面读取颜色，可以考虑在使用的时候再去读取和解析。


3. 线程优化

线程的创建需要消耗较多的系统系统资源，减少线程的创建。可以考虑共用一个线程池。

如何检测线程的创建，可以参考我个开源库 [performance](https://github.com/XanderWang/performance)

4. 布局等优化

减少布局的层次，合理使用 ViewStub

