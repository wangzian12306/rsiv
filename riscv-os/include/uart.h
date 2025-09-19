#ifndef UART_H
#define UART_H

// UART寄存器偏移
#define UART_RHR 0     // 接收保持寄存器
#define UART_THR 0     // 发送保持寄存器
#define UART_IER 1     // 中断使能寄存器
#define UART_FCR 2     // FIFO控制寄存器
#define UART_LCR 3     // 线路控制寄存器
#define UART_LSR 5     // 线路状态寄存器

// LSR位定义
#define UART_LSR_TX_IDLE 0x20

void uart_init(void);
void uart_putc(char c);
void uart_puts(char *s);

#endif

