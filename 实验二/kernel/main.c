#include "types.h"
#include "memlayout.h"
#include "uart.h"
#include "console.h"
#include "printf.h"

// 内核主函数
void main(void) {
    uart_init();
    uart_puts("Hello OS\n");
    
    clear_screen();
    printf("Hello OS! %d %x %s %c %%\n", 123, 0xabc, "test", 'A');
    while(1);
}

