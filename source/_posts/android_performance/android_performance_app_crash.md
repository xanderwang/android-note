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

- {% post_link android_performance/android_performance_all Android 性能优化总结 %}
- {% post_link android_performance/android_performance_apk_size APK 瘦身优化 %}
- {% post_link android_performance/android_performance_app_start 启动速度优化 %}
- {% post_link android_performance/android_performance_app_crash 稳定性优化 %}
- 内存的优化
- 操作流畅度优化
- 电量优化



## APP 稳定性的维度

app 稳定一般指的是 app 能正常运行， app 不能正常运行的情况分为两大类，分别是 `Crash` 和 `ANR`

> Crash：运行过程中发生的错误，是无法避免的。

> ANR：应用再运行时，由于无法再规定的时间段内响应完，系统做出的一个操作。

## 如何治理 `Crash`

Crash 是运行时的未处理发生的异常，导致 app 无法正常运行。如果需要解决的话，就需要捕获这个未处理的异常，获取方法调用堆栈，从而解决问题。

Android app 可以分为 2 层，Java 层和 C/C++ 层。所以如何捕获需要分开说。

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

`Thread` 的 `defaultUncaughtExceptionHandler` 是 `Thread` 类的一个静态变量。

看到这里，如果捕获 `Java` 层未处理的异常就很清晰了，给 `Thread` 设置一个`新的 defaultUncaughtExceptionHandler`，在这个新的` defaultUncaughtExceptionHandler` 里面收集需要的信息就可以了。

需要注意的一点是， `旧的 defaultUncaughtExceptionHandler` 需要保存下来，然后`新的 defaultUncaughtExceptionHandler` 收集信息后，需要再转给`旧的 defaultUncaughtExceptionHandler` 继续处理。


### Native 层获取未处理的异常的相关信息

Native 层发生未处理的异常的话，后续如何处理，需要掌握 linux 的一些知识，由于本人不是特别了解 linux ，这里就直接参考别人的文章了。如果有错误，还请指正。

本人通过查阅资料发现，Native 层如果发生未处理的异常(注:如果 Native 层捕获了异常，是可以通过 JNI 抛到 Java 层去处理的) ，系统会发出信号给 Native 层，在 Native 层，注册对应信号的处理器就可以了。

待续...

## 如何治理 `ANR`

ANR 是 的简称，说的是，本来自己也写了一个小总结，但是最近发现头条给 ANR 写了一个系列的文章，觉得很好，这里忍不住引用一下。

- [今日头条 ANR 优化实践系列 - 设计原理及影响因素](https://mp.weixin.qq.com/s/ApNSEWxQdM19QoCNijagtg)
- [今日头条 ANR 优化实践系列 - 监控工具与分析思路](https://mp.weixin.qq.com/s/_Z6GdGRVWq-_JXf5Fs6fsw)
- [今日头条 ANR 优化实践系列分享 - 实例剖析集锦](https://mp.weixin.qq.com/s/4-_SnG4dfjMnkrb3rhgUag)

其实具体的为什么会产生，以及如何去捕获 ANR 的发生，以及如何分析解决 ANR 问题，上面的文章都有了详细的解释。很想说一句看上面的总结文章就好了，但是这样就失去了写文章的初心，所以我就总结下我看过上面的文章后的收获吧。

待续...

