#ifndef MEMLAYOUT_H
#define MEMLAYOUT_H

// 物理内存布局 - 更新内核基地址
#define KERNBASE 0x80200000L
#define PHYSTOP (KERNBASE + 16*1024*1024)  // 16MB RAM
#define UART0 0x10000000L

// 内核栈大小
#define KSTACKSIZE 4096

#endif

