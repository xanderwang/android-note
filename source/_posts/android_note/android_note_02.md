---
seo_title: Android 开发总结笔记(二) - Java 反射和注解总结
title: Android 开发总结笔记(二) - Java 反射和注解总结
date: 2021-02-07 22:00:00
tags:
- Android
- 反射
- 注解
categories: 
- Android 总结
---

# 反射总结

## 什么是反射

反射是 Java 语言的一个特性，就是在程序运行状态中，对于任何一个类，都可以通过反射知道这个类所有的方法和属性。对于任何一个实例，都可以调用这个实例的任何方法和属性。这个**在运行时动态获取类或者实例的属性和方法，动态调用属性和方法的特性**就叫反射。

## 反射有什么用

从特性可以看出，在运行时可以动态调整属性的值和调用代码，可以让程序更灵活。主要用于以下几点

- 动态创建实例( class.newInstance 方法 )
- 调用某个方法( method.invoke 方法 )
- 修改或者获取某个字段的值

### 反射的常用方法介绍

#### Class 常用方法介绍

```
getDeclaringClass  一般针对内部类，如 B 是 A 的内部类，在 B 的 class 上调用这个方法，返回的是 A 

getDeclaredClasses 获取当前类声明的内部类

getClasses  包含当前类的父类和声明的 public 的内部类

newInstance  创建一个类的实例

forName 获取一个类，如果类没有加载会加载

getConstructor 系列方法，可以获取构造方法类实例，然后调用实例的 newInstance 方法可以获得一个实例
```
#### Method 常用方法介绍

```
getMethod  获取 public 的方法，包括继承的

getDeclaredMethod  该类里面的定义的方法，包括私有的和实现的接口的方法。

invoke 该方法可以调用某个实例的某个方法。第一个参数为 null 时表示调用静态方法，第一个参数传入某个实例的时候，表示调用实例的某个方法。
```
#### Filed 常用方法介绍

```
getField 获取字段

getDeclaredField 
```

## 常用的场景

### 动态配置

可以通过 `Class.forName` 方法加载指定的配置类，然后读取配置，以达到动态配置的效果。

### 动态代理

动态代理底层用到了反射。

### hook 框架

动态生成实例，修改字段值、调用非 `public` 方法

参考资料：

[学习java应该如何理解反射？](https://www.zhihu.com/question/24304289)

# 注解总结

## 什么是注解

注解是 JDK 1.5 引入的一个特性，用来给 Java 代码提供元数据。注解本身不直接影响代码的执行。

如何理解呢？**注解是 Java 的一个特性，元数据可以理解为给编译器或者 jvm 看的++注释++，不直接影响程序的运行**。但是可以在运行时通过读取注解做一些事情。可以把元数据理解为额外的一些可用可不用的额外信息。

### 注解定义

和定义接口类似，只不过关键字是 `@interface`。下面一段代码演示了如何定义个注解

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface TestAnnotation {
    int id();
    String msg();
}
```

## 注解的应用场景

- 提供信息给编译器  这个接触的不多
- 编译阶段的处理    比如生产文档，这个有时候会用
- 运行时的处理   这个相对用的多，就是说运行时读取注解的值，来做一些事情，比如 Retrofit  框架库，就用到了注解。具体的原理分析在后续笔记记录。

参考资料：

[java注解-最通俗易懂的讲解](https://zhuanlan.zhihu.com/p/37701743)