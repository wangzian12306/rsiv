#include "console.h"
#include <stdarg.h>

static void print_number(int num, int base, int sign) {
    char buf[32];
    int i = 0;
    unsigned int n;

    if (sign && num < 0) {
        n = -((unsigned int)num);
        console_putc('-');
    } else {
        n = (unsigned int)num;
    }

    // 处理0
    if (n == 0) {
        buf[i++] = '0';
    } else {
        while (n) {
            int d = n % base;
            buf[i++] = (d < 10) ? ('0' + d) : ('a' + d - 10);
            n /= base;
        }
    }

    // 逆序输出
    while (i--) {
        console_putc(buf[i]);
    }
}

int printf(const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    int cnt = 0;

    for (; *fmt; fmt++) {
        if (*fmt != '%') {
            console_putc(*fmt);
            cnt++;
            continue;
        }
        fmt++;
        if (!*fmt) break;
        switch (*fmt) {
        case 'd':
            print_number(va_arg(ap, int), 10, 1);
            break;
        case 'x':
            print_number(va_arg(ap, int), 16, 0);
            break;
        case 's': {
            char *s = va_arg(ap, char*);
            if (!s) s = "(null)";
            console_puts(s);
            break;
        }
        case 'c':
            console_putc((char)va_arg(ap, int));
            break;
        case '%':
            console_putc('%');
            break;
        default:
            // 未知格式符，原样输出
            console_putc('%');
            console_putc(*fmt);
            break;
        }
    }
    va_end(ap);
    return cnt;
}