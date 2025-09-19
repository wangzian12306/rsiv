#include "uart.h"

 void uart_init(void)
 {

 }
 
 void uart_putc(char c)
 {
     volatile char *uart = (volatile char *)UART0;
     
     /* 等待发送寄存器空闲 */
     volatile char *lsr = (volatile char *)(UART0 + UART_LSR);
     while ((*lsr & UART_LSR_THRE) == 0) {
         /* 等待 */
     }
     
     /* 发送字符 */
     *uart = c;
 }
 
 /* 输出字符串 */
 void uart_puts(char *s)
 {
     while (*s) {
         uart_putc(*s);
         s++;
     }
 }