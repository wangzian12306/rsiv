#include "types.h"
#include "memlayout.h"
#include "uart.h"

// 内核栈
__attribute__((aligned(16))) char stack[4096];

// 简单的字符输出函数（不依赖uart_init）
void simple_putc(char c) {
    volatile char *uart = (char *)0x10000000;
    *uart = c;
}

// 内核主函数
void main(void) {
    // 直接输出字符，不初始化UART
    simple_putc('H');
    simple_putc('e');
    simple_putc('l');
    simple_putc('l');
    simple_putc('o');
    simple_putc(' ');
    simple_putc('O');
    simple_putc('S');
    simple_putc('\n');
    
    // 死循环
    while(1);
}

