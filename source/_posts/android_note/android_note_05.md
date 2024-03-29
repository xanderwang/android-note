---
seo_title: Android 开发总结笔记(五) - Java 线程总结
title: Android 开发总结笔记(五) - Java 线程总结
date: 2021-02-26 21:30:00
tags:
- Android
- 线程
categories: 
- Android 总结
---

# Java 线程总结

## Java 线程安全

### 什么是线程安全

在上一节的 Java 内存模型里面说到，程序在运行的时候，线程并不是直接从主存里面，而是先从主内存拷贝一份到工作内存(线程私有的)，然后执行代码，最后把计算结果从工作内存写回到主内存。

有个小问题，为是么需要 JMM ？

cpu 在存取数据或者存取指令的时候，如果都是在一片连续的区域，效率会高，所以栈里面会有一个变量的副本，这样会把需要参与计算的变量放到一片连续的区域，会提高执行效率，但是这样就会有一个数一致性问题，也就是线程安全问题。说到底就是数据同步问题。

当有多个线程同时访问同一个变量的时候，因为线程在运算的时候，可能并不是拿的“最新”的值来参与计算的，或者说，参与计算的值不是“最新的”，因为其他线程更新了这个变量，但是线程不知道，还是用的“旧的值”。最终，执行完代码后，写回到主存的值是不符合预期的值。这种情况就是线程不安全，所以，对应的，线程安全就是多个线程同时访问同一个变量的时候，最终的结果和预期结果一致，就表明是线程安全的。

线程要保证安全，需要满足三个条件

- 原子性(Synchronized / Lock)

原子性的意思是，某个操作要么执行完，要么不做。比如读取值，执行时，开始读数据了，需要保证不能被打断。要么不读值。

- 可见性(Volatile / Synchronized / Lock)

可见性的意思是对值得读写可以立刻捕获，就是说某个线程可以“观察”到其他线程对值得修改，同时，这个线程对值的修改，其他线程也可以“观察”到。

- 有序性(Volatile / Synchronized / Lock)

说到有序性需要说到指令重排，指令重排是为了提高 CPU 的指令执行效率，执行代码的时候，会把一些源码上的不影响方法执行结果的代码打乱执行，以提高 CPU 执行效率。有序性的意思就是说最终代码编译的指令是按照代码的书写顺序执行的。

### Volatile

上面说到了，线程安全在于没有“及时”读取到最新的值。要想“及时”读取到最新的值，我们需要用到 volatile 关键字，我们先看看值是如何读取的。

#### Java 变量的读写

Java 变量读的读写是以下的指令来完成的，通过以下的指令，把变量的值从主内存读取到工作内存，工作内存变化后，写入主内存。

指令|含义
--|--
lock | 作用于主内存，把变量标识为线程独占状态。
unlock | 作用于主内存，解除独占状态。
read | 作用主内存，把一个变量的值从主内存传输到线程的工作内存。
load | 作用于工作内存，把 read 操作传过来的变量值放入工作内存的变量副本中。
use | 作用工作内存，把工作内存当中的一个变量值传给执行引擎。
assign | 作用工作内存，把一个从执行引擎接收到的值赋值给工作内存的变量。
store | 作用于工作内存的变量，把工作内存的一个变量的值传送到主内存中。
write | 作用于主内存的变量，把 store 操作传来的变量的值放入主内存的变量中。

#### volatile 如何保持内存可见性

- read、load、use 动作必须连续出现。
- assign、store、write 动作必须连续出现。

所以，使用 volatile 变量能够保证:

- 每次`读取前`必须先从主内存刷新最新的值。
- 每次`写入后`必须立即同步回主内存当中。

有了这 2 条规则，线程就可以及时“观察”到变量值得变化了。

#### volatile 如何防止指令重排序

通过内存屏障来实现的。

屏障|举例|含义
---|---|---
LoadLoad | Load1;LoadLoad;Load2 | Load2 以及之后的读操作要在 Load1 完成之后
LoadStore | Load1;LoadStore;Store | Store2 以及之后的写操作要在 Load1 完成之后
StoreStore | Store1;StoreStore;Store2 | Store2 以及之后的写操作要在 Store1 完成之后
StoreLoad | Store1;StoreLoad;Load2 | Load2  以及之后的读操作需要在 Store1 完成之后 

为了实现volatile的内存语义，编译器在生成字节码时，会在指令序列中插入内存屏障来禁止特定类型的处理器重排序。然而，对于编译器来说，发现一个最优布置来最小化插入屏障的总数几乎不可能，为此，Java内存模型采取保守策略。

下面是基于保守策略的JMM内存屏障插入策略：

- 在每个 volatile 写操作的前面插入一个 StoreStore 屏障。
- 在每个 volatile 写操作的后面插入一个 StoreLoad 屏障。
- 在每个 volatile 读操作的后面插入一个 LoadLoad 屏障。
- 在每个 volatile 读操作的后面插入一个 LoadStore 屏障。

[volatile关键字的作用、原理](https://monkeysayhi.github.io/2016/11/29/volatile%E5%85%B3%E9%94%AE%E5%AD%97%E7%9A%84%E4%BD%9C%E7%94%A8%E3%80%81%E5%8E%9F%E7%90%86/)

[Java内存模型](https://www.cnblogs.com/zhengbin/p/6407137.html)

[JVM内存模型、指令重排、内存屏障概念解析](https://www.cnblogs.com/chenyangyao/p/5269622.html)


解决这个问题(线程不安全)的办法有以下几种方式

1. synchronized
2. Lock + volatile

说到底，线程安全的主要的思想就是利用某种方式，保证同时只有一个线程在使用这个变量或者说是方法块，其他的线程“阻塞”，等待正在执行的线程执行完。线程油冰雪执行变成串行执行。

### 线程安全的实现方式

#### synchronized

synchronized 通过字节码指令 enterMoniter 和 exitMoniter 实现同时只有一个线程可以执行某段代码块，等这段代码块执行完以后，其他的线程才可以执行。

这里面需要了解 synchronized 的作用对象，作用对象是一个 Object 。

大概的原理就是:每个对象都有一个对象头，这个对象头里面存储了相应的锁的信息(无锁、偏向锁、轻量锁和重量锁)。当代码执行到 synchronized 代码的时候，会看这个锁作用的对象的对象头，是有锁还是无锁，无锁就加锁后继续执行。有锁后就阻塞，等待其他线程执行完。

但是一开始 synchronized 是一个比较重的操作，后续做了优化，这些优化分别是自旋锁、轻量锁、偏向锁。

自旋就是不会立即 block 线程，而是做一段小的自循环，如果还是无法获取锁，再 block 线程。

轻量锁是指，虽然对于同一段代码，有多个线程竞争，但是竞争发生在不同的时间段。轻量锁的做法是第一次对锁对象加锁的时候，锁对象的对象头记录指向线程中的锁记录。再次执行代码，加锁锁对象的时候，如果锁对象的对象头指向的锁记录是这个线程，就直接执行，跳过加锁过程。

偏向锁就是，锁对象被加锁的时候，锁对象的对象头会保存持有锁的线程 id , 当同步代码执行完后，再次对锁对象加锁的时候，如果锁对象的对象头是偏向锁，并且 thread id 是当前线程，那么就不做加锁过程，直接执行。

轻量级锁和偏向锁如果存在竞争，最终还是会膨胀为重量锁的。

#### 锁膨胀过程

偏向锁(01)：做一次 cas 操作，如果成功，说明获取偏向锁成功，对象头记录获取锁的 ThreadId ，如果失败，说明有竞争，这个时候需要膨胀为轻量级锁。

轻量级锁(00)：某个线程获取锁的时候，如果对象头是偏向锁，就看 ThreadId 对应的线程是否还活着，如果活着，就看是否退出同步块，如果不存活或者已经退出同步块，就尝试 cas 操作获取偏向锁，如果 cas 失败，说明有竞争，这个时候需要由偏向锁膨胀为轻量级锁，具体的过程就是 JVM 会把当前获取锁的线程挂起，然后再线程的当前栈帧里面创建一个锁记录，然后把对象头用 CAS 拷贝进去，同时创建一个 Owner 指针指向锁对象的对象头，然后锁对象的对象头指向这个锁记录，然后之前获取锁的线程继续执行，没有获取到锁的线程先自旋一段时间，如果自旋结束后成功获取到轻量级锁，就继续执行，如果自旋后还是获取不到轻量级锁，说明由更严重(多个线程)的竞争，需要膨胀为重量级锁。

重量级锁(10)：线程


参考资料：

[https://juejin.im/post/5ca766dcf265da30d02fb35c](https://juejin.im/post/5ca766dcf265da30d02fb35c)

[JAVA锁的膨胀过程和优化](https://www.cnblogs.com/dsj2016/p/5714921.html)

[聊聊Java 锁的JVM锁](https://zhuanlan.zhihu.com/p/133319319)

[JAVA锁的膨胀过程和优化](https://xinghelanchen.github.io/2018/08/22/JAVA%E9%94%81%E7%9A%84%E8%86%A8%E8%83%80%E8%BF%87%E7%A8%8B%E5%92%8C%E4%BC%98%E5%8C%96/)

#### Lock + volatile

lock 的话主要是利用 AQS 框架来实现的同步机制。

AQS 框架内部利用了 CAS 来判断是否有线程持有锁。当有其他线程持有锁的时候，会 block 当前线程，然后入队列(入队的时候可能会有自旋)，当持有锁的线程释放锁后，会唤醒 block 的线程。

CAS 是 Java 提供的原子性操作 API 。

AQS 框架的理解：

```java
acquire 独占式获取锁，如果没有获取成功，就入队列并阻塞。

tryAcquire 独占式锁子类需要复写的方法，独占式请求锁。返回 true 表示线程获取锁成功，false 表示获取锁失败。

acquireShare 共享式获取锁，当获取锁的线程数量超过指定数量(tryAcquireShare的返回结果小于0)，就阻塞尝试获取锁的线程。

tryAcquireShare 共享式锁子类需要复写的方法。返回值如果小于 0 表示共享锁的数量消耗完，需要阻塞。

acquireQueued 独占的时候，入队列
addWaiter  具体的入队列入口
doAcquireShared 共享的时候，入队列
```

### Java 里锁的分类

- 公平/非公平锁

公平：按照请求锁的时间顺序依次获取锁，非公平锁就是不一定是按照请求锁的时间顺序来获取锁的。

- 独占/共享锁

独占锁(ReentrantLock)就是锁只能同时被一个线程持有，共享锁(CountDownLatch/Semaphone)就是锁可以同时被多个线程持有。

- 自旋锁

没有请求到锁的时候，做一段循环，等待持有锁的线程释放锁，然后请求锁。坏处就是，如果自旋过久，也会消耗大量的 cpu 资源。

- 偏向锁/轻量锁/重量锁

synchornized 的优化，如果再偏向锁发生竞争的时候会锁膨胀

- 可重入/不可重入

线程获取某个锁后，再次请求这个锁，仍然可以获取锁就是可重入锁。
反之，获取锁后，再次请求这个锁，无法获取到锁就是不可重入锁。

- 可中断锁

这个待完善。

### 常用锁的原理分析

- ReentrantLock

可重入锁，独占式的，默认是非公平锁，可通过构造方法来决定是公平锁还是非公平锁。

调用 lock 方法去尝试获取锁。

调用 unlock 方法释放锁。

- CountDownLatch

`await` 方法，调用此方法的时候，只有当 state 为 0 的时候才不阻塞，state 为其他值的情况下会阻塞线程

CountDownLatch 构造方法需要指定 count , 也就是 state

`countDown` 方法，会使 count - 1 ，其实就是 count ，当  count - 1 == 0 的时候唤醒阻塞的线程。

适用于事情开始前，一些条件达成(条件达成，计数器减一)，然后继续。

需要注意的是 count 只有减少的方法，没有增加和重置的方法，故不可复用。

- CyclicBarrier 

强调的是，事情做完后，等其他线程也达到同等条件，然后在继续执行。

适用于事情做完后，等待某一条件达成，然后继续。

- ReentrantReadWriteLock

里面包含读锁和写锁。读读不互斥，读写，写写互斥。就是两个线程都读数据的时候，不会阻塞，两个或者多个线程读写或者写写的时候会阻塞线程。

相对其他的锁，锁的粒度更小，效率会高一些，同样的，实现会复杂些。

默认是非公平锁，同样可以通过构造方法控制是否为公平锁。

read 锁为共享锁

write 锁为独占锁

这两个锁共用一个 AQS 框架的 state , state 高16位表示共享锁的 state , 低 16 为表示 write 锁的 state

- AQS 框架小结

上面的四种框架很好的利用了 AQS 框架，重点基本在 `tryAcquire`、`tryAcquireShare` 里面，这 2 个方法的返回值是子类控制AQS框架是否阻塞线程的入口，如果需要自定义一种锁的话，需要好好设计这两个方法。 ReentrantReadWriteLock 就是一个很好的例子。

## 线程间通信

这种互相通信的过程就是线程间的协作

多线程之间通讯，其实就是多个线程在操作同一个资源，但是操作的动作不同

线程间通信方式

1. wait/notify 

synchornized 的时候，通过 wait/notify 来暂停线程和通知线程，从而达到通信的目的。

```java
Object 类的方法，final 的，表示子类不可修改
wait(long time)  主动释放锁，然后休眠，在指定的时间长度后自动唤醒或者被系统唤醒。
notify() 随机唤醒一个等待的线程进入就绪队列
notifyAll() 唤醒所有等待的线程进入就绪队列
```

参考资料

[JAVA线程通信详解](https://blog.csdn.net/u011635492/article/details/83043212)

[java condition使用及分析](https://blog.csdn.net/bohu83/article/details/51098106)

2. lock/condition

这个其实和 wait/notify  类似，不过这个是语言层面实现的，不是虚拟机层面的实现。

3. 管道 

PipedInputStream/PipedOutputStream 来实现的，一个是开始，一个是结束。

Object 和 Thread 常用方法介绍
```java
Object: 下面的方法都只能在同步块中调用

wait()  释放锁资源，并等待唤醒

wait(long time)  释放锁资源，并在指定事件后唤醒

notify()  随机唤醒一个线程进入就绪列表

notifyAll() 唤醒所有线程进入就绪列表
```

```java
Thread: 类方法

sleep(long time) 让线程休眠指定事件，但是不释放锁资源。

join() 等待目标线程结束
```

## 线程池

通过 ThreadPoolExcutor 类来创建线程池。

创建线程池 5 个参数的含义

|参数|含义|
|--|--|
|corePoolSize|线程池的基本大小，即在没有任务需要执行的时候线程池的大小，并且只有在工作队列满了的情况下才会创建超出这个数量的线程|
|maximumPoolSize|线程池中允许的最大线程数，只有工作队列满了，才可能继续创建线程，但是同时运行的线程数不会超过这个|
|keepAliveTime|当 idle 的线程数大于 corePoolSize 时，idle 的线程可以存活的时间。 |
|unit|时间单位|
|workQueue|没有被执行的任务会放到这个队列里面|
|threadFactory|用来创建新的线程的|
|handler||

参考资料

[理解ThreadPoolExecutor线程池的corePoolSize、maximumPoolSize和poolSize](https://www.cnblogs.com/frankyou/p/10135212.html)

[探索 Android 多线程优化方法](https://juejin.im/post/6844903909178212359)

[一次Android线程优化的探索](https://juejin.im/post/6855586076132655118)
