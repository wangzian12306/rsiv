
kernel.elf:     file format elf64-littleriscv


Disassembly of section .text:

0000000080200000 <_start>:
# RISC-V启动入口点
.section .text.entry
.globl _start
_start:
    # 调试输出：在设置栈前输出 'S'
    li t0, 0x10000000      # UART基地址
    80200000:	100002b7          	lui	t0,0x10000
    li t1, 'S'             # 字符'S'
    80200004:	05300313          	li	t1,83
    sb t1, 0(t0)           # 输出到UART
    80200008:	00628023          	sb	t1,0(t0) # 10000000 <_start-0x70200000>
    
    # 设置栈指针
    la sp, stack_top
    8020000c:	00000117          	auipc	sp,0x0
    80200010:	13410113          	addi	sp,sp,308 # 80200140 <stack_top>
    
    # 调试输出：设置栈后输出 'P'
    li t1, 'P'             # 字符'P'
    80200014:	05000313          	li	t1,80
    sb t1, 0(t0)           # 输出到UART
    80200018:	00628023          	sb	t1,0(t0)
    
    # 跳转到C主函数
    call main
    8020001c:	028000ef          	jal	ra,80200044 <main>
    
    # 死循环（防止返回）
1:  j 1b
    80200020:	0000006f          	j	80200020 <_start+0x20>

0000000080200024 <simple_putc>:

// 内核栈
__attribute__((aligned(16))) char stack[4096];

// 简单的字符输出函数（不依赖uart_init）
void simple_putc(char c) {
    80200024:	ff010113          	addi	sp,sp,-16
    80200028:	00813423          	sd	s0,8(sp)
    8020002c:	01010413          	addi	s0,sp,16
    volatile char *uart = (char *)0x10000000;
    *uart = c;
    80200030:	100007b7          	lui	a5,0x10000
    80200034:	00a78023          	sb	a0,0(a5) # 10000000 <_start-0x70200000>
}
    80200038:	00813403          	ld	s0,8(sp)
    8020003c:	01010113          	addi	sp,sp,16
    80200040:	00008067          	ret

0000000080200044 <main>:

// 内核主函数
void main(void) {
    80200044:	ff010113          	addi	sp,sp,-16
    80200048:	00813423          	sd	s0,8(sp)
    8020004c:	01010413          	addi	s0,sp,16
    *uart = c;
    80200050:	100007b7          	lui	a5,0x10000
    80200054:	04800713          	li	a4,72
    80200058:	00e78023          	sb	a4,0(a5) # 10000000 <_start-0x70200000>
    8020005c:	06500713          	li	a4,101
    80200060:	00e78023          	sb	a4,0(a5)
    80200064:	06c00713          	li	a4,108
    80200068:	00e78023          	sb	a4,0(a5)
    8020006c:	00e78023          	sb	a4,0(a5)
    80200070:	06f00713          	li	a4,111
    80200074:	00e78023          	sb	a4,0(a5)
    80200078:	02000713          	li	a4,32
    8020007c:	00e78023          	sb	a4,0(a5)
    80200080:	04f00713          	li	a4,79
    80200084:	00e78023          	sb	a4,0(a5)
    80200088:	05300713          	li	a4,83
    8020008c:	00e78023          	sb	a4,0(a5)
    80200090:	00a00713          	li	a4,10
    80200094:	00e78023          	sb	a4,0(a5)
    simple_putc('O');
    simple_putc('S');
    simple_putc('\n');
    
    // 死循环
    while(1);
    80200098:	0000006f          	j	80200098 <main+0x54>

000000008020009c <uart_init>:
#include "types.h"
#include "memlayout.h"
#include "uart.h"

// 初始化UART
void uart_init(void) {
    8020009c:	ff010113          	addi	sp,sp,-16
    802000a0:	00813423          	sd	s0,8(sp)
    802000a4:	01010413          	addi	s0,sp,16
    // 禁用中断
    *(volatile uint8*)(UART0 + UART_IER) = 0x00;
    802000a8:	100007b7          	lui	a5,0x10000
    802000ac:	000780a3          	sb	zero,1(a5) # 10000001 <_start-0x701fffff>
    
    // 设置波特率（假设QEMU已配置好）
    // 8位数据，无校验，1位停止位
    *(volatile uint8*)(UART0 + UART_LCR) = 0x03;
    802000b0:	00300713          	li	a4,3
    802000b4:	00e781a3          	sb	a4,3(a5)
    
    // 启用FIFO
    *(volatile uint8*)(UART0 + UART_FCR) = 0x01;
    802000b8:	00100713          	li	a4,1
    802000bc:	00e78123          	sb	a4,2(a5)
}
    802000c0:	00813403          	ld	s0,8(sp)
    802000c4:	01010113          	addi	sp,sp,16
    802000c8:	00008067          	ret

00000000802000cc <uart_putc>:

// 输出一个字符
void uart_putc(char c) {
    802000cc:	ff010113          	addi	sp,sp,-16
    802000d0:	00813423          	sd	s0,8(sp)
    802000d4:	01010413          	addi	s0,sp,16
    // 等待发送缓冲区为空
    while((*(volatile uint8*)(UART0 + UART_LSR) & UART_LSR_TX_IDLE) == 0);
    802000d8:	10000737          	lui	a4,0x10000
    802000dc:	00574783          	lbu	a5,5(a4) # 10000005 <_start-0x701ffffb>
    802000e0:	0207f793          	andi	a5,a5,32
    802000e4:	fe078ce3          	beqz	a5,802000dc <uart_putc+0x10>
    
    // 写入字符
    *(volatile uint8*)(UART0 + UART_THR) = c;
    802000e8:	100007b7          	lui	a5,0x10000
    802000ec:	00a78023          	sb	a0,0(a5) # 10000000 <_start-0x70200000>
}
    802000f0:	00813403          	ld	s0,8(sp)
    802000f4:	01010113          	addi	sp,sp,16
    802000f8:	00008067          	ret

00000000802000fc <uart_puts>:

// 输出字符串
void uart_puts(char *s) {
    802000fc:	fe010113          	addi	sp,sp,-32
    80200100:	00113c23          	sd	ra,24(sp)
    80200104:	00813823          	sd	s0,16(sp)
    80200108:	00913423          	sd	s1,8(sp)
    8020010c:	02010413          	addi	s0,sp,32
    80200110:	00050493          	mv	s1,a0
    while(*s) {
    80200114:	00054503          	lbu	a0,0(a0)
    80200118:	00050a63          	beqz	a0,8020012c <uart_puts+0x30>
        uart_putc(*s);
    8020011c:	fb1ff0ef          	jal	ra,802000cc <uart_putc>
        s++;
    80200120:	00148493          	addi	s1,s1,1
    while(*s) {
    80200124:	0004c503          	lbu	a0,0(s1)
    80200128:	fe051ae3          	bnez	a0,8020011c <uart_puts+0x20>
    }
}
    8020012c:	01813083          	ld	ra,24(sp)
    80200130:	01013403          	ld	s0,16(sp)
    80200134:	00813483          	ld	s1,8(sp)
    80200138:	02010113          	addi	sp,sp,32
    8020013c:	00008067          	ret
