---
seo_title: Android 性能优化 - 操作流畅度优化
title: Android 性能优化 - 操作流畅度优化
date: 2021-04-10 18:15:00
tags: 
- Android
- Performance
- 操作流畅度优化
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

## 为什么会卡顿

为什么卡顿之前，我们先需要简单了解一点硬件相关的知识。就是在界面绘制的过程中， CPU 主要的任务是计算出屏幕上所有 View 对应的图形和向量等信息。 GPU 的主要任务就是把 CPU 计算出的图形栅格化并转化为位图，可以简单理解为屏幕像素点对应的值。

如果操作过程中卡顿了，一般就是 CPU 和 GPU 其中的一个或者多个无法短时间完成对应的任务。

一般而言，CPU 除了需要计算 View 对应的图形和向量等信息，还要做逻辑运算和文件读写等任务，所以 CPU 造成卡顿更常见。一般也是通过减少 CPU 的计算任务来优化卡顿。

影响 CPU 的使用率一般有以下几个方面：

- 读写文件
- 解析大量图片
- 频繁请求网络
- 复杂的布局
- 频繁创建对象 

## 如何检测卡顿

虽然我们知道了大概哪些原因会导致卡顿，但是我们无法准确定位出问题的代码点在哪里，针对上面的部分问题，本人写了一个开源库来自动检测，这个开源库的地址是

> [https://github.com/XanderWang/performance](https://github.com/XanderWang/performance)

详细的原理，可以参考上面的连接，这里简单总结下监控 UI 卡段的原理。

我们知道，`Android` 里面，界面的刷新需要再主线程或者说 UI 线程执行。而界面的绘制起始点又利用了 `Looper 消息循环`机制。`Looper 消息循环`机制有一个有意思的特点，就是 Looper 在 `dispatch` Message 的时候，会在 `dispatch 前`和 `dispatch 后`利用 `Printer` 打印`特定 tag` 的字符串，通过`接管 Printer` ，我们就可以获取 `dispatch message` 前后的时机。

然后我们可以在 `dispatch message 之前`，在`异步线程`启动一个抓取系统信息的延时任务。在 `dispatch message 之后`，我们可以`移除`异步线程的这个延时任务。如果某个消息的执行没有超过阈值，那就表示在异步线程的延时任务被取消，表明没有卡顿。如果某个消息的执行时间超过了阈值，那异步线程里的延时任务就会执行，表明有卡顿，异步线程的延时任务会获取此时的系统状态，从而辅助我们分析卡顿问题。

## 如何优化卡顿

如何检测说完了，我们来说说如何优化。在 为什么会卡顿 小结我总结了几种常见，现在对几种场景的优化总结下。

### 读写文件

最常见的一个读写文件而不自知的就是 `SharePerfrences` 的使用，使用 `sp` 的时候需要注意不要频繁调用 `apply` 或者 `commit` 方法，因为每调用一次就有可能会有一次写文件操作(高版本系统做了优化 apply 做了优化，不一定会写文件)。所以，如果调用次数多的话，就会多次写文件，写文件又是一个耗时且耗资源的操作，所以要少做。

一般优化方法是合理`拆分` sp 文件，一个 sp 文件不要包含太多的项，同时每一项的内容尽量短。尽量批量提交数据后再 commit 或者 apply 。同时需要注意的是 commit 会直接触发写文件(内容有变化的时候)，所以如果在 UI 线程调用 commit 方法需要注意可能会阻塞 UI 线程。

如果有更高的性能需求，可以考虑用 [mmkv](https://github.com/Tencent/MMKV) 来替换或者 [DataStore](https://developer.android.google.cn/topic/libraries/architecture/datastore?hl=zh-cn) 来替换 sp 。具体的替换方法就不细说了。网上有很多资料参考。

另外一个常见的读写文件的场景是从 xml 文件里面读取布局、色值等操作，这些都是一些 io 操作。从 xml 读取布局的话，可以考虑用代码直接创建 view 来优化，从 xml 里面读取颜色可以考虑加个 HashMap 来优化。

### 解析大量图片

解码图片毫无疑问是一个计算量大的操作，所以一般加载图片的时候最好根据实际显示的尺寸做压缩，并且保存压缩后的缩略图，方便下次直接加载。

另外还需要注意列表滚动过程中，控制对图片的加载，一般列表在滑动过程中，不加载图片，等列表滚动停止后，才开始加载图片。

另外的一个优化的方法就是减少图片的使用，不过这个难度有点大。

另外还可以考虑针对不同的图片格式，用不同的解码格式。比如 `png` 格式的图片根据机器实际情况选择 `8888` 或者 `4444` 解码方式解码图片。如果是 `jpg/jpeg` 格式的图片，就用 `565` 的解码方式解码图片。对于用不同的解码方式解码图片，效率是否会高，本人没做过测试，但是毫无疑问，内存的使用是不同的。

### 频繁请求网络

网络请求的话，可以参考下面的优化方法。

1. 如果使用 `okhttp` 请求网络的话，尽量全局使用一个 `httpclient` ，这样做的好处是可以复用，提高网络请求效率。

2. 后台支持的话，开启 `gzip` 压缩，这样网络传输的数据量小些，传输效率会高些。

3. 自定义 `dns` ，减少解析 `dns` 的时间。

4. 通过和后台商量，部分数据后台接口一步到位，尽量避免多次请求后才拿到完整的目标数据。

### 复杂的布局

如果布局复杂的话， CPU 要进行大量的计算才可以确定最终的图形。所以布局复杂的话，CPU 需要大量的运算资源，所以优化复杂的布局是很有必要的。

1. 减少布局层次，可以利用 ViewStub 、merge 和 include 等标签来尝试减少布局层次。

2. 使用高效的布局容器，比如 ConstraintLayout，可以不用嵌套布局容器来实现复杂效果。

3. 部分效果可以考虑用自定义 View 实现。

这个优化感觉不是特别好做，可能优化了，但是效果不好，但是又不能不做。
### 频繁创建对象 

为什么这个要列出来呢？因为频繁创建对象，可能会短时间内消耗大量内存，然后内存不足的时候系统就会尝试 GC 来回收对象，而 GC 是很耗资源的操作，虽然现在 Android 系统对 GC 做了很多优化，但是尽量减少 GC 的触发总是好的。

一般频繁创建对象的场景有:

- 自定义 View 的时候，在 onDraw 方法创建临时对象
- 循环里面使用 "+" 拼接字符串
- ArrayList 等有容积限制的容器类初始化的容量不合理，导致后续新增数据频繁扩容。

可能还有一些场景没有列出来，如果大家有好的建议，可以提出来。

除了频繁创建对象可能会触发 GC ，如果某次使用过大的内存也可能会导致 GC ，比如展示一个超大的 Bitmap ，虽然可以用缩略图来展示，但是可能会碰到需要放大查看具体细节的场景，这个时候可以考虑采用裁剪显示区域(BitmapRegionDecoder)的方式来解析图片。
## 联系我

- Github: [https://github.com/XanderWang](https://github.com/XanderWang)

- Mail: <420640763@qq.com>

- Blog: [https://xander_wang.gitee.io/android-note/](https://xander_wang.gitee.io/android-note/)
