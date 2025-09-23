#include "uart.h"
#include "console.h"

// 控制台输出单字符
void console_putc(char c) {
    uart_putc(c);
}

// 控制台输出字符串
void console_puts(const char *s) {
    while (s && *s) {
        console_putc(*s++);
    }
}

void clear_screen(void) {
    // ANSI转义序列：清屏+光标归位
    console_putc('\033');
    console_putc('[');
    console_putc('2');
    console_putc('J');
    console_putc('\033');
    console_putc('[');
    console_putc('H');
}