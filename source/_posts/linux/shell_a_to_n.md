---
seo_title: shell 脚本 -a 到 -n 的意思
title: shell 脚本 -a 到 -n 的意思
date: 2021-02-28 22:00:00
tags:
- shell
categories: 
- 其他
---

- [-a file]  

如果 file 存在则为真

- [-b file]  

如果 file 存在且是一个块特殊文件则为真

- [-c file]  

如果 file 存在且是一个字特殊文件则为真

- [-d file]  

如果file文件存在且是一个目录则为真
-d 前的 ! 是逻辑非
例如：
if [ ! -d $lcd_path/$par_date ] 表示后面的那个目录不存在，则执行后面的 then 操作

- [-e file] 

如果 file 文件存在则为真

- [-f file] 

如果 file 存在且是一个普通文件则为真

- [-g file] 

如果 file 存在且已经设置了 SGID 则为真（SUID 是 Set User ID, SGID 是 Set Group ID的意思）

- [-h file] 

如果 file 存在且是一个符号连接则为真

- [-k file] 

如果 file 存在且已经设置粘制位则为真

当一个目录被设置为"粘制位"(用chmod a+t),则该目录下的文件只能由
1. 超级管理员删除
2. 该目录的所有者删除
3. 该文件的所有者删除

也就是说,即便该目录是任何人都可以写,但也只有文件的属主才可以删除文件。

具体例子如下：

#ls -dl /tmp

drwxrwxrwt 4 root root .........

注意other位置的t，这便是粘连位。

- [-p file] 

如果 file 存在且是一个名字管道（F如果O）则为真
管道是 linux 里面进程间通信的一种方式，其他的还有像信号（signal）、信号量、消息队列、共享内存、套接字（socket）等。

- [-r file] 

如果 file 存在且是可读的则为真

- [-s file] 

如果 file 存在且大小不为 0 则为真

- [-t FD] 

如果文件描述符 FD 打开且指向一个终端则为真

- [-u file] 

如果 file 存在且设置了SUID（set userID）则为真

- [-w file] 

如果 file 存在且是可写的则为真

- [-x file] 

如果 file 存在且是可执行的则为真

- [-O file] 

如果 file 存在且属有效用户ID则为真

- [-G file] 

如果 file 存在且属有效用户组则为真

- [-L file] 

如果 file 存在且是一个符号连接则为真

- [-N file] 

如果 file 存在 and has been mod 如果 ied since it was last read 则为真

- [-S file] 

如果 file 存在且是一个套接字则为真

- [file1 –nt file2] 

如果 file1 has been changed more recently than file2 或者 file1 exists and file2 does not 则为真

- [file1 –ot file2] 

如果 file1 比 file2 要老，或者 file2 存在且 file1 不存在则为真

- [file1 –ef file2] 

如果 file1 和 file2 指向相同的设备和节点号则为真

- [-o optionname] 

如果 shell 选项 “optionname” 开启则为真

- [-z string] 

“string” 的长度为零则为真

- [-n string] or [string] 

“string” 的长度为非零 non-zero 则为真

- [sting1==string2] 

如果 2 个字符串相同。
1. “=” may be used instead of 
2. “==” for strict posix compliance
则为真

- [string1!=string2] 

如果字符串不相等则为真

- [string1<string2] 

如果 “string1” sorts before “string2”，lexicographically in the current locale 则为真

- [arg1 OP arg2] 

“OP”is one of –eq,-ne,-lt,-le,-gt or –ge.These arithmetic binary oprators return true if “arg1”is equal to,not equal to,less than,less than or equal to,greater than,or greater than or equal to“agr2”,respectively.“arg1”and “agr2”are integers.