---
seo_title: Android 性能优化 - 启动速度优化
title: Android 性能优化 - 启动速度优化
date: 2020-04-06 17:13:00
tags: 
- Android
- Performance
- 启动速度优化
categories: 
- Android
---

## 如何查看 apk 大小组成

可以看到占大头的是 res 、so 、以及代码 

## 如何减少 res 资源大小

1. 删除冗余的资源

可以使用 lint 工具来搜索项目中不再使用的图片等资源

2. 重复资源的优化

除了有冗余资源，还有些是文件名不一样，但是内容一样的图片，可以通过比较 md5 值来判断是不是一样的资源，然后编辑 resource.r

3. 图片压缩

未压缩的图片文件占用空间较大，可以考虑压缩未压缩过的图片来瘦身。常用的工具是  [tinypng](https://tinypng.com/) 网站。

同时也可以借助 [TinyPngPlugin](https://github.com/Deemonser/TinyPngPlugin) 等插件或者其他开源工具来帮助压缩图片。

4. 资源混淆

通过将资源路径 `res/drawable/wechat` 变为 `r/d/a` 的方式来减少 apk 的大小，当 apk 有较多资源项的时候，效果比较明显，这是一款微信开源的工具，详细地址是：[AndResGuard](https://github.com/shwenzhang/AndResGuard)

5. 指定语言

如果没有特殊的需求的话，可以只编译中文，因为其他的语言用不上，如果用不上的语言编译了，会在 resource 的表里面占用大量的空间，故

```
android {
    defaultConfig {
        ...
        // 仅支持 中文
        resConfigs "zh" 
    }
}
```


## 如何减少 so 库资源大小

1. 自己编译的 so 

release 包的  so 中移除调试符号。可以使用 Android NDK 中提供的 `arm-eabi-strip` 工具从原生库中移除不必要的调试符号。

如果是 cmake 来编译的话，可以再编辑脚本添加如下代码

```
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -s")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -s")
```


2. 别人编译的 so

联系作者修改，一般很难联系到。

3. 动态下发 so

可以通过服务器下发 so , 下载完后再进入应用，但是体验不好，但是是一个思路。

4. 只编译指定平台的 so 

一般我们都是给 arm 平台的机器开发，如果没有特殊情况，我们一般只需要考虑 arm 平台的。具体的方法是 app 下的 build.gradle 添加如下代码

```
android {
    defaultConfig {
        ndk {
            abiFilter "armeabi"
        }
    }
}
```

各个平台的差别如下：

|平台|说明|
| -- | -- |
|armeabi-v7a| arm 第 7 代及以上的处理器，2011 年后的设备基本都是。|
|arm64-v8a|arm 第 8 代 64 位处理器设备，很少，s6|
|armeabi|arm第 5、6 代处理器，早期的机器都是这个平台|
|x86|x86 32 位平台，平板和模拟器用的多|
|x86_64|x86 64 位平台|

## 如何减少代码资源大小

1. 一个功能尽量用一个库

比如加载图片库，不要 glide 和 fresco 混用，因为功能是类似的，只是使用的方法不一样，用了多个库来做类似的事情，代码肯定就变多了。

2. 混淆

混淆的话，减少了生成的 class 大小，这样积少成多，也可以从一定层度减少 apk 的大小。

3. R 文件内联

通过把 R 文件里面的资源内联到代码中，从而减少 R 文件的大小。

可以使用 [shrink-r-plugin](https://github.com/bytedance/ByteX/blob/master/shrink-r-plugin/README-zh.md) 工具来做 R 文件的内联

## 参考文档

[Android App包瘦身优化实践](https://tech.meituan.com/2017/04/07/android-shrink-overall-solution.html)


