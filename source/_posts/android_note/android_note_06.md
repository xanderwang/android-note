---
seo_title: Android 开发总结笔记(六) - 网络编程总结
title: Android 开发总结笔记(六) - 网络编程总结
date: 2021-02-26 21:31:00
tags:
- Android
- 网络编程
- HTTP/HTTPS
- TCP/IP
categories: 
- Android 总结
---

# 网络编程总结

## 网络协议总览

### 网络协议分层

![网络协议分层图](https://img-blog.csdnimg.cn/20190311164958423.png)

### 网络协议框架

![网络协议框架图](https://pic2.zhimg.com/80/v2-0ca19e8fa75661a2de8fbbc93f060c05_720w.jpg)

### 各层协议之间的区别合联系

```
应用层: Http WebSocket FTP 等
传输层: TCP UDP
网络层: IP
链路层: -
``` 

- TCP 和 UDP

> TCP 是面向连接的一种传输控制协议。TCP 链接连通后，客户端和服务器可以互相发送和接收消息。在客户端或者服务端没有主动断开链接的情况下，链接一直存在，所以一般 TCP 也成为长链接。TCP 的特点是，连接有耗时(三次握手)，数据传输无限制，准确可靠。

> UDP 是无连接的用户数据报协议。无连接就是传输数据前不用建立连接，直接向指定位置传输数据。特点是速度快，但不稳定，可广播，数据大小有限制。

两者比较的话， TCP 可以类比打电话， UDP 可以类比发短信。

- HTTP

> HTTP 是基于 TCP 协议的，请求时，建立 TCP 连接，请求结束后断开连接。HTTP v1.1 版本新增了 keep-alive ，可以复用之前的 TCP 连接，减少资源消耗。这个也是网络优化的一个点。

- WebSocket

> WebSocket 也是一种协议，属于应用层。WebSocket 协议分为 2 部分，一部分为"连接"，一部分为"数据传输"。

- Socket 连接和 TCP 连接

> Socket 是传输层的门面，TCP 和 UDP 是一个协议，应用层和传输层之间的交互是通过 Socket 来实现的。

- HTTP 和 WebSocket 的区别

> 都是应用层的协议，而且都是基于 TCP 协议的，不同的是 HTTP 无状态的一次连接后就会关闭， WebSocket 是全双工的，连接后可以互相发送和接收消息。 


## HTTP 协议

### HTTP 协议是什么

HTTP 协议的中文翻译是超文本传输协议，从字面的意思来看，HTTP 协议是用来解决互联网上的机器之间如何传输超文本内容问题的协议。

### HTTP 协议是如何工作的

HTTP 协议是用来解决互联网上 2 台机器之间传输超文本内容的问题的。我们先看一个基础的问题， 2 台机器如何传输数据。

这是一个很复杂的问题，涉及到软硬件之前的协作。直接通讯肯定和硬件相关，通讯的内容是什么和软件相关。为了更好的发展，或者说减少网络开发的门槛，整个网络相关的开发(软硬件)，理论上分成了 7 层，实际实现了 4 层。

![网络分层图](https://img-blog.csdnimg.cn/20190311164958423.png)

分层设计的好处就是各层相互独立，同时减少耦合，提高了开发效率，易扩展。

HTTP 协议是建立在 TCP/IP 的基础上的，属于应用层。

数据在网络上的流向大概下面

> 发送方机器应用层封装原始数据后传给传输层。 -> 传输层接收应用层数据后封装数据，然后把数据传递给网络层。 -> 网络层接收数据后封装数据，然后把数据传递给链路层。 -> 链路层把数据交给网络，最终数据传递到了接收方机器 -> 接收方机器链路层收到发送方链路层的数据 -> 接收方网络层接收到链路层数据，解开数据后传给传输层 -> 接收方传输层接收到数据后，解开数据，然后把数据传给应用层 -> 接收方应用层接收到数据后，解析数据然后展示。

### TCP/IP 的三次握手和四次挥手

#### 三次握手

上一小节简单描述了数据在整个网络中的大概流向。有一些相对来说关键且重要的问题。

1. 如何保证接收方是我们的期望接收方？
2. 如何能保证网络相对稳定可靠，即 C 和 S 都觉得对方和自己都是可以接收和发送消息的？

三次握手就是用来解决这些关键问题的，主要是解决问题 2 的，因为问题1 不管是几次握手都需要解决的。

先说下三次握手是如何工作的，然后再说下为什么是三次握手。

1. 第一次握手: C 端 发送 SYN=1 信号，同时 seq=x 来请求 S 端
2. 第二次握手: S 端 发送 SYN=1 ACK=1 信号，同时 seq=y ack=x+1 给 C 端，表示对 C 的 SYN 信号应答，同时发送一个 SYN 
3. 第三次握手: C 端发送一个 ACK=1 信号，同时 ack=y+1 ，服务器接收到后就可以开始传输数了，

因为经过三次握手， C 端确认了自己是可以发送和接收的，S 端也是可以发送和接收的(1-2握手)。
S 端也确认了自己是可以发送和接收的，同时 C 端也是可以接收和发送的(2-3握手)。

#### 四次挥手

tcp/ip 是全双工的，就是说 C 和 S 都是有发送和接收的。断开的时候需要发送和接收都断开。所以需要四次挥手来做到。

1. 第一次挥手 C 发送 FIN=1 信号， seq=u ，接着 **C 关闭发送数据**，就是说后续不能发送数据流，表示数据发送完。
2. 第二次挥手 S 发送 ACK=1 信号，ack=u+1,seq=v 表示接收到了 C 的 FIN 信号。
3. 第三次挥手 S 发送 FIN=1,ACK=1 信号，同时 seq=w,ack=u+1 然后 **S 关闭接收数据**，即后续 S 不在接收数据，数据发送完了。
4. 第四次挥手 C 端接收到第三次挥手的请求后，发送 ACK=1 信号，表示确认接受完数据， S 端可以关闭接收了，2 timel 后 **C 端关闭接收**。同时 S 端接收到第四次挥手请求后**，S 端关闭接收**

至此，挥手完毕。

[重学TCP/IP协议和三次握手四次挥手](https://blog.csdn.net/ThinkWon/article/details/104903925)

### 如何理解 HTTP 协议是无状态的，无连接的

无连接，或者叫无持续连接合适些。最早的协议，一次处理一个连接，连接处理完后，就断开，后续加了 keep-alive 来解决这个问题。

无状态，是指两次连接之间没有关系，不会记录两次连接之间的关系。实际交互也许有关系，但是作为两次连接，在通讯的时候，是没有关系的，就是不会直接有影响两次连接。这是协议的内容，但是实际搞了个 cookies 

[http协议无状态中的 "状态" 到底指的是什么？！](https://www.cnblogs.com/bellkosmos/p/5237146.html)

### HTTP 各个版本比较

- http 0.9 
- http 1.0 新增了 POST GET PUT 等方式，新增了请求头和响应头概念，扩充了传输的内容格式。图片等都可以传输了。
- http 1.1 目前引用最广泛的协议，做了优化，支持 keep-alive，管道化、断点续传。
- http 2.0 主要是改进传输性能，实现低延迟和高吞吐。采用二进制传输数据。
- http 3.0 将弃用TCP协议，改为使用基于UDP协议的QUIC协议实现。


### GET 和 POST 的区别

- 语义上的区别， GET 用户请求数据，一般请求到的内容是固定的， POST 一般是向服务器提交数据。

- GET 请求参数在 url 中， post 请求参数在 request body 里面。

- GET 是安全、幂等和可缓存的， POST 是不安全，不幂等和不可缓存的。(安全是说，资源是只读的，幂等是指请求一次或者多次，返回的结果都是一样的。可缓存的)

参考资料:

[GET 和 POST 到底有什么区别？](https://www.zhihu.com/question/28586791)

[TCP、UDP、HTTP、SOCKET、WebSocket之间的区别](https://zhuanlan.zhihu.com/p/112537312)

[1小时教你理解HTTP，TCP，UDP，Socket，WebSocket](https://www.jianshu.com/p/42260a2575f8)

## HTTPS 协议原理

HTTPS 是在 HTTP 中加入了一层 SSL/TLS 加密层，用来保护中间数据的安全。


需要注意的而是 HTTP 和 HTTPS 都是基于 TCP/IP 协议的，就是说 HTTPS 先进行三次握手建立链接后，才做证书认证等

在介绍 HTTPS 之前，我们先简单介绍下密码学的一些基础知识。

> 明文: 未被加密的原始数据 

> 密文: 加密后的数据，无法直接查看，需要通过解密后才可以查看

> 密钥: 一种参数，用于明文转为密文，或者密文转为明文时候的参数，分为对称密钥和非对称密钥。

> 对称加密: 也叫私钥加密，即数据的发送者和接收者用的是用一个密钥来加密和解密数据。加密过程中的密钥称为私钥，即不能公开，私人所有。公开后或者泄露后，第三方很容易解密密文。

> 非对称加密:也叫做公钥加密。密钥是一对，分为公钥和密钥，加密的时候可以用公钥或者密钥中的一个加密，解密的时候需要用另外一个密钥解密。

HTTPS 实际上是 HTTP 协议 + SSL/TLS 协议，就是说内容通过 SSL/TLS 协议加密后，在通过 HTTP 协议传输。

![HTTPS 原理图](https://imgconvert.csdnimg.cn/aHR0cDovL2ltZy5ibG9nLmNzZG4ubmV0LzIwMTYwNjA4MjIwMzM3Njky?x-oss-process=image/format,png)

HTTPS 涉及到了对称加密和非对称加密，可以分为 8 个小步骤

1. 客户端向服务器 443 端口发起 HTTPS 请求。
2. 服务器接收到请求后，找到保存的公钥和密钥。
3. 服务器发送公钥(也就是证书)给客户端。
4. 客户端接收到公钥后，验证公钥是否有效，如果无效，提示异常；如果有效，那么生成一个随机的密钥。
5. 客户端用公钥对这个生成的密钥加密后发送给服务器。
6. 服务器接收到加密后的随机密钥后，服务器用密钥加密后的带随机密钥。
7. 服务器用随机密钥加密数据后发送给服务器。
8. 客户端接收到数据后用随机密钥解密，就可以得到数据。


这里面涉及到了非对称加密和对称加密。

- 非对称加密用于校验网站公钥，也就是证书。同时用来加密客户端生成的随机密钥
- 随机密钥用于对称加密，用于加密数据。

第 4 步的验证公钥是否有效，需要说到公钥(证书)的来由，是由网站去 CA 组织申请的，申请通过后，CA 会用自己的私钥对网站信息，授权的期限等信息加密后生成的一个数字证书。简单说就是网站的公钥(证书)是 CA 组织私钥加密后的产物，然后终端设备都会内置 CA 组织的所有公钥。在终端设备拿到网站证书后，会用内置的 CA 公钥对网站证书解密，如果成功解密，就可以根据解密后的信息来判断当前证书是否有效，如果不能解密成功，说明网站公钥(证书)无效。 

[Https原理及流程](https://www.jianshu.com/p/14cd2c9d2cd2)

[HTTPS理论基础及其在Android中的最佳实践](https://blog.csdn.net/iispring/article/details/51615631)


### HTTP 和 HTTPS 的区别

HTTPS 加密的


## 网络开源库框架有哪些

- httpclient 废弃不用了
- volley 基本不用了
- okhttp 在用，主流网络请求框架

### okhttp 源码解析

1 创建一个 OkHttpClient

2 创建一个 Request

3 调用 OkHttpClient 的 newCall 方法后生成一个 RealCall

4 调用 RealCall 的 execute 同步开始请求或者异步加入队列

5 同步调用的时候会调用 RealInterceptorChain 的 proceed 方法，这个方法做的事情主要是通过找到 interceptor ，然后把任务交给 interceptor 的 intercept 方法继续执行。

[OKHttp源码解析(一)--初阶](https://www.jianshu.com/p/82f74db14a18)

## 如何优化网络

- 开启 Gzip 压缩，开启后可以减少数据传输的大小，减少数据传输时间。
- 考虑用 Protocol Buffer 代替 JSON 或者 XML， XML 肯定是需要替换的。
- OKHttp 接入 HTTPDNS，在 `OkHttp.build()` 时，通过 `dns()` 方法配置。HTTPDNS 的好处就是绕过运营商的 LocalDNS 解析，提高解析效率和有效防止域名劫持。
- okhttpClient 尽量只创建一个实例。这样请求都在一个线程池里面。

参考资料:

[OkHttp3线程池相关之Dispatcher中的ExecutorService](https://github.com/soulrelay/InterviewMemoirs/issues/7)


