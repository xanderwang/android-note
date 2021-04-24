---
seo_title: Android 性能优化 - 稳定性优化
title: Android 性能优化 - 稳定性优化
date: 2021-04-07 17:15:00
tags: 
- Android
- Performance
- 稳定性优化
categories: 
- Android 性能优化
---

## 系列文章

- {% post_link android_performance/android_performance_summary Android 性能优化概要 %}
- {% post_link android_performance/android_performance_app_size APK 瘦身优化 %}
- {% post_link android_performance/android_performance_app_start 启动速度优化 %}
- {% post_link android_performance/android_performance_app_crash 稳定性优化 %}
- {% post_link android_performance/android_performance_app_memory 内存的优化 %}
- {% post_link android_performance/android_performance_app_caton 操作流畅度优化 %}

## APP 稳定性的维度

app 稳定一般指的是 app 能正常运行， app 不能正常运行的情况分为两大类，分别是 `Crash` 和 `ANR`

> Crash：运行过程中发生的错误，是无法避免的。

> ANR：应用再运行时，由于无法再规定的时间段内响应完，系统做出的一个操作。

## 如何治理 `Crash`

应用发生 Crash 是由于应用在运行时，应用产生了一个未处理的异常(就是没有被 try catch 捕获的异常)。这会导致 app 无法正常运行。

如果需要解决的话，就需要知道这个未处理的异常是在哪里产生的，一般是通过分析未处理的异常的方法调用堆栈来解决问题。

Android APP 可以分为 2 层，Java 层和 Native 层。所以如何捕获需要分开说。

### Java 层获取未处理的异常的调用堆栈

这个需要了解 `Java` 虚拟机是如何把一个未捕获的异常报上来的。

未捕获的异常，会沿着方法的调用链依次上抛，直到 `ThreadGroup` 的 `uncaughtException` 方法

```java
    public void uncaughtException(Thread t, Throwable e) {
        if (parent != null) {
            // 递归调用，可以忽略
            parent.uncaughtException(t, e); 
        } else {
            // 交给了 Thread.getDefaultUncaughtExceptionHandler() 来处理未捕获的异常
            Thread.UncaughtExceptionHandler ueh =
                Thread.getDefaultUncaughtExceptionHandler();
            if (ueh != null) {
                ueh.uncaughtException(t, e);
            } else if (!(e instanceof ThreadDeath)) {
                System.err.print("Exception in thread \""
                                 + t.getName() + "\" ");
                e.printStackTrace(System.err);
            }
        }
    }
```
查阅代码发现，发现 `ThreadGroup` 最终会给 `Thread` 的 `defaultUncaughtExceptionHandler` 处理。

```java
private static volatile UncaughtExceptionHandler defaultUncaughtExceptionHandler;
```

 上面的代码显示：`Thread` 的 `defaultUncaughtExceptionHandler` 是 `Thread` 类的一个静态变量。

看到这里，如何捕获 `Java` 层未处理的异常就很清晰了，给 `Thread` 设置一个`新的 defaultUncaughtExceptionHandler`，在这个新的` defaultUncaughtExceptionHandler` 里面收集需要的信息就可以了。

需要注意的一点是 `旧的 defaultUncaughtExceptionHandler` 需要保存下来，然后`新的 defaultUncaughtExceptionHandler` 收集信息后，需要再转给`旧的 defaultUncaughtExceptionHandler` 继续处理。

### Native 层获取未处理的异常的相关信息

Java 层如何收集未处理的异常的信息说过了，我们来看看 Native 层发生未处理的异常的话，是如何处理的。 Native 层的处理，需要掌握 linux 的一些知识，由于本人不是特别了解 linux ，这里就直接参考别人的文章了。如果有错误，还请指正。

本人通过查阅资料发现，Native 层如果发生未处理的异常(注:如果 Native 层捕获了异常，是可以通过 JNI 抛到 Java 层去处理的) ，系统会发出信号给 Native 层，在 Native 层如果要收集未处理的异常信息，就需要注册对应信号的处理函数。当发生异常的时候，Native 层会收到信息，然后通过处理器来收集信息。

注册信号处理函数如下：

```c
#include <signal.h> 
int sigaction(int signum,const struct sigaction *act,struct sigaction *oldact));
```

- signum：代表信号编码，可以是除SIGKILL及SIGSTOP外的任何一个特定有效的信号，如果为这两个信号定义自己的处理函数，将导致信号安装错误。
- act：指向结构体sigaction的一个实例的指针，该实例指定了对特定信号的处理，如果设置为空，进程会执行默认处理。
- oldact：和参数act类似，只不过保存的是原来对相应信号的处理，也可设置为NULL。

有了信号处理函数，后面还要做的事情就是收集信息了，由于本人不是很熟悉 Native 的开发，这里就不展开说了了，大家可以参考 [Android 平台 Native 代码的崩溃捕获机制及实现](https://www.cnblogs.com/mingfeng002/p/9118253.html)。

## 如何治理 `ANR`

`ANR` 是 `Applicatipon No Response` 的简称。如果应用卡死或者响应过慢，系统就会杀死应用。为什么要杀死应用？其实也很好理解，如果不杀死应用，大家会以为系统坏了。

那我们如何监控 `ANR` 呢？以及我们如何分析 ANR 的问题呢？常见的导致 ANR 的原因有哪些呢？

首先，`ANR` 的原理是 `AMS` 在 `UI 操作`开始的时候，会根据 `UI 操作`的类型开启一个延时任务，如果这个任务被触发了，就表示应用卡死或者响应过慢。这个任务会在 `UI 操作`结束的时候被移除。

然后，如何分析 `ANR` 问题呢？

一般 `ANR` 发生的时候， `logcat` 里面会打印 `ANR` 相关的信息，过滤关键字 `ANR` 就可以看到，这里不做详细分析，可以参考后面的文章。

然后一般会在 `/data/anr` 目录下面生成 `traces.txt` 文件，里面一般包含了 `ANR` 发生的时候，系统和所有应用的线程等信息(需要注意的是，不同的 rom 可能都不一样)，通过 `logcat` 打印的信息和 `traces.txt` 里面的信息，大部分的 `ANR` 可以分析出原因，但是呢，也有相当一部分的 ANR 问题无法分析，因为 `logcat` 和 `traces.txt` 提供的信息有限，有时候甚至没有特别有用的信息，特别是 `Android` 的权限收紧， `traces.txt` 文件在`高 Android 版本`无法读取，给 `ANR` 问题的分析增加了不少的困难。不过好在最近发现头条给 `ANR` 写了一个系列的文章，里面对 ANR 问题的治理方法，个人觉得很好，这里引用一下。

- [今日头条 ANR 优化实践系列 - 设计原理及影响因素](https://mp.weixin.qq.com/s/ApNSEWxQdM19QoCNijagtg)
- [今日头条 ANR 优化实践系列 - 监控工具与分析思路](https://mp.weixin.qq.com/s/_Z6GdGRVWq-_JXf5Fs6fsw)
- [今日头条 ANR 优化实践系列分享 - 实例剖析集锦](https://mp.weixin.qq.com/s/4-_SnG4dfjMnkrb3rhgUag)
- [今日头条 ANR 优化实践系列 - Barrier 导致主线程假死](https://mp.weixin.qq.com/s/OBYWrUBkWwV8o6ChSVaCvw)

本人之前写过一个小的[性能监测的工具](https://github.com/XanderWang/performance)，其中有监控 `UI` 线程 `Block` 的功能，考虑后续加入头条的 `ANR` 监测机制，等后续完成了，在做一个详细的总结吧。这次的总结就写到这里。

## 联系我

- Github: [https://github.com/XanderWang](https://github.com/XanderWang)

- Mail: <420640763@qq.com>

- Blog: [https://xander_wang.gitee.io/android-note/](https://xander_wang.gitee.io/android-note/)

