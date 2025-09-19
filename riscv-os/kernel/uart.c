#include "types.h"
#include "memlayout.h"
#include "uart.h"

// 初始化UART
void uart_init(void) {
    // 禁用中断
    *(volatile uint8*)(UART0 + UART_IER) = 0x00;
    
    // 设置波特率（假设QEMU已配置好）
    // 8位数据，无校验，1位停止位
    *(volatile uint8*)(UART0 + UART_LCR) = 0x03;
    
    // 启用FIFO
    *(volatile uint8*)(UART0 + UART_FCR) = 0x01;
}

// 输出一个字符
void uart_putc(char c) {
    // 等待发送缓冲区为空
    while((*(volatile uint8*)(UART0 + UART_LSR) & UART_LSR_TX_IDLE) == 0);
    
    // 写入字符
    *(volatile uint8*)(UART0 + UART_THR) = c;
}

// 输出字符串
void uart_puts(char *s) {
    while(*s) {
        uart_putc(*s);
        s++;
    }
}

