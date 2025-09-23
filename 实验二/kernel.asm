
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
    8020000c:	00001117          	auipc	sp,0x1
    80200010:	48b10113          	addi	sp,sp,1163 # 80201497 <stack_top>
    
    # 调试输出：设置栈后输出 'P'
    li t1, 'P'             # 字符'P'
    80200014:	05000313          	li	t1,80
    sb t1, 0(t0)           # 输出到UART
    80200018:	00628023          	sb	t1,0(t0)
    
    # 跳转到C主函数
    call main
    8020001c:	008000ef          	jal	ra,80200024 <main>
    
    # 死循环（防止返回）
1:  j 1b
    80200020:	0000006f          	j	80200020 <_start+0x20>

0000000080200024 <main>:
#include "uart.h"
#include "console.h"
#include "printf.h"

// 内核主函数
void main(void) {
    80200024:	ff010113          	addi	sp,sp,-16
    80200028:	00113423          	sd	ra,8(sp)
    8020002c:	00813023          	sd	s0,0(sp)
    80200030:	01010413          	addi	s0,sp,16
    uart_init();
    80200034:	03c000ef          	jal	ra,80200070 <uart_init>
    uart_puts("Hello OS\n");
    80200038:	00000517          	auipc	a0,0x0
    8020003c:	42050513          	addi	a0,a0,1056 # 80200458 <printf+0x1a4>
    80200040:	090000ef          	jal	ra,802000d0 <uart_puts>
    
    clear_screen();
    80200044:	138000ef          	jal	ra,8020017c <clear_screen>
    printf("Hello OS! %d %x %s %c %%\n", 123, 0xabc, "test", 'A');
    80200048:	04100713          	li	a4,65
    8020004c:	00000697          	auipc	a3,0x0
    80200050:	41c68693          	addi	a3,a3,1052 # 80200468 <printf+0x1b4>
    80200054:	00001637          	lui	a2,0x1
    80200058:	abc60613          	addi	a2,a2,-1348 # abc <_start-0x801ff544>
    8020005c:	07b00593          	li	a1,123
    80200060:	00000517          	auipc	a0,0x0
    80200064:	41050513          	addi	a0,a0,1040 # 80200470 <printf+0x1bc>
    80200068:	24c000ef          	jal	ra,802002b4 <printf>
    while(1);
    8020006c:	0000006f          	j	8020006c <main+0x48>

0000000080200070 <uart_init>:
#include "types.h"
#include "memlayout.h"
#include "uart.h"

// 初始化UART
void uart_init(void) {
    80200070:	ff010113          	addi	sp,sp,-16
    80200074:	00813423          	sd	s0,8(sp)
    80200078:	01010413          	addi	s0,sp,16
    // 禁用中断
    *(volatile uint8*)(UART0 + UART_IER) = 0x00;
    8020007c:	100007b7          	lui	a5,0x10000
    80200080:	000780a3          	sb	zero,1(a5) # 10000001 <_start-0x701fffff>
    
    // 设置波特率（假设QEMU已配置好）
    // 8位数据，无校验，1位停止位
    *(volatile uint8*)(UART0 + UART_LCR) = 0x03;
    80200084:	00300713          	li	a4,3
    80200088:	00e781a3          	sb	a4,3(a5)
    
    // 启用FIFO
    *(volatile uint8*)(UART0 + UART_FCR) = 0x01;
    8020008c:	00100713          	li	a4,1
    80200090:	00e78123          	sb	a4,2(a5)
}
    80200094:	00813403          	ld	s0,8(sp)
    80200098:	01010113          	addi	sp,sp,16
    8020009c:	00008067          	ret

00000000802000a0 <uart_putc>:

// 输出一个字符
void uart_putc(char c) {
    802000a0:	ff010113          	addi	sp,sp,-16
    802000a4:	00813423          	sd	s0,8(sp)
    802000a8:	01010413          	addi	s0,sp,16
    // 等待发送缓冲区为空
    while((*(volatile uint8*)(UART0 + UART_LSR) & UART_LSR_TX_IDLE) == 0);
    802000ac:	10000737          	lui	a4,0x10000
    802000b0:	00574783          	lbu	a5,5(a4) # 10000005 <_start-0x701ffffb>
    802000b4:	0207f793          	andi	a5,a5,32
    802000b8:	fe078ce3          	beqz	a5,802000b0 <uart_putc+0x10>
    
    // 写入字符
    *(volatile uint8*)(UART0 + UART_THR) = c;
    802000bc:	100007b7          	lui	a5,0x10000
    802000c0:	00a78023          	sb	a0,0(a5) # 10000000 <_start-0x70200000>
}
    802000c4:	00813403          	ld	s0,8(sp)
    802000c8:	01010113          	addi	sp,sp,16
    802000cc:	00008067          	ret

00000000802000d0 <uart_puts>:

// 输出字符串
void uart_puts(char *s) {
    802000d0:	fe010113          	addi	sp,sp,-32
    802000d4:	00113c23          	sd	ra,24(sp)
    802000d8:	00813823          	sd	s0,16(sp)
    802000dc:	00913423          	sd	s1,8(sp)
    802000e0:	02010413          	addi	s0,sp,32
    802000e4:	00050493          	mv	s1,a0
    while(*s) {
    802000e8:	00054503          	lbu	a0,0(a0)
    802000ec:	00050a63          	beqz	a0,80200100 <uart_puts+0x30>
        uart_putc(*s);
    802000f0:	fb1ff0ef          	jal	ra,802000a0 <uart_putc>
        s++;
    802000f4:	00148493          	addi	s1,s1,1
    while(*s) {
    802000f8:	0004c503          	lbu	a0,0(s1)
    802000fc:	fe051ae3          	bnez	a0,802000f0 <uart_puts+0x20>
    }
}
    80200100:	01813083          	ld	ra,24(sp)
    80200104:	01013403          	ld	s0,16(sp)
    80200108:	00813483          	ld	s1,8(sp)
    8020010c:	02010113          	addi	sp,sp,32
    80200110:	00008067          	ret

0000000080200114 <console_putc>:
#include "uart.h"
#include "console.h"

// 控制台输出单字符
void console_putc(char c) {
    80200114:	ff010113          	addi	sp,sp,-16
    80200118:	00113423          	sd	ra,8(sp)
    8020011c:	00813023          	sd	s0,0(sp)
    80200120:	01010413          	addi	s0,sp,16
    uart_putc(c);
    80200124:	f7dff0ef          	jal	ra,802000a0 <uart_putc>
}
    80200128:	00813083          	ld	ra,8(sp)
    8020012c:	00013403          	ld	s0,0(sp)
    80200130:	01010113          	addi	sp,sp,16
    80200134:	00008067          	ret

0000000080200138 <console_puts>:

// 控制台输出字符串
void console_puts(const char *s) {
    80200138:	fe010113          	addi	sp,sp,-32
    8020013c:	00113c23          	sd	ra,24(sp)
    80200140:	00813823          	sd	s0,16(sp)
    80200144:	00913423          	sd	s1,8(sp)
    80200148:	02010413          	addi	s0,sp,32
    8020014c:	00050493          	mv	s1,a0
    while (s && *s) {
    80200150:	00051863          	bnez	a0,80200160 <console_puts+0x28>
    80200154:	0140006f          	j	80200168 <console_puts+0x30>
        console_putc(*s++);
    80200158:	00148493          	addi	s1,s1,1
    uart_putc(c);
    8020015c:	f45ff0ef          	jal	ra,802000a0 <uart_putc>
    while (s && *s) {
    80200160:	0004c503          	lbu	a0,0(s1)
    80200164:	fe051ae3          	bnez	a0,80200158 <console_puts+0x20>
    }
}
    80200168:	01813083          	ld	ra,24(sp)
    8020016c:	01013403          	ld	s0,16(sp)
    80200170:	00813483          	ld	s1,8(sp)
    80200174:	02010113          	addi	sp,sp,32
    80200178:	00008067          	ret

000000008020017c <clear_screen>:

void clear_screen(void) {
    8020017c:	ff010113          	addi	sp,sp,-16
    80200180:	00113423          	sd	ra,8(sp)
    80200184:	00813023          	sd	s0,0(sp)
    80200188:	01010413          	addi	s0,sp,16
    uart_putc(c);
    8020018c:	01b00513          	li	a0,27
    80200190:	f11ff0ef          	jal	ra,802000a0 <uart_putc>
    80200194:	05b00513          	li	a0,91
    80200198:	f09ff0ef          	jal	ra,802000a0 <uart_putc>
    8020019c:	03200513          	li	a0,50
    802001a0:	f01ff0ef          	jal	ra,802000a0 <uart_putc>
    802001a4:	04a00513          	li	a0,74
    802001a8:	ef9ff0ef          	jal	ra,802000a0 <uart_putc>
    802001ac:	01b00513          	li	a0,27
    802001b0:	ef1ff0ef          	jal	ra,802000a0 <uart_putc>
    802001b4:	05b00513          	li	a0,91
    802001b8:	ee9ff0ef          	jal	ra,802000a0 <uart_putc>
    802001bc:	04800513          	li	a0,72
    802001c0:	ee1ff0ef          	jal	ra,802000a0 <uart_putc>
    console_putc('2');
    console_putc('J');
    console_putc('\033');
    console_putc('[');
    console_putc('H');
    802001c4:	00813083          	ld	ra,8(sp)
    802001c8:	00013403          	ld	s0,0(sp)
    802001cc:	01010113          	addi	sp,sp,16
    802001d0:	00008067          	ret

00000000802001d4 <print_number>:
#include "console.h"
#include <stdarg.h>

static void print_number(int num, int base, int sign) {
    802001d4:	fc010113          	addi	sp,sp,-64
    802001d8:	02113c23          	sd	ra,56(sp)
    802001dc:	02813823          	sd	s0,48(sp)
    802001e0:	02913423          	sd	s1,40(sp)
    802001e4:	03213023          	sd	s2,32(sp)
    802001e8:	04010413          	addi	s0,sp,64
    802001ec:	00058913          	mv	s2,a1
    char buf[32];
    int i = 0;
    unsigned int n;

    if (sign && num < 0) {
    802001f0:	00060463          	beqz	a2,802001f8 <print_number+0x24>
    802001f4:	04054e63          	bltz	a0,80200250 <print_number+0x7c>
        n = -((unsigned int)num);
        console_putc('-');
    } else {
        n = (unsigned int)num;
    802001f8:	0005049b          	sext.w	s1,a0
    }

    // 处理0
    if (n == 0) {
    802001fc:	06049063          	bnez	s1,8020025c <print_number+0x88>
        buf[i++] = '0';
    80200200:	03000793          	li	a5,48
    80200204:	fcf40023          	sb	a5,-64(s0)
            n /= base;
        }
    }

    // 逆序输出
    while (i--) {
    80200208:	00000693          	li	a3,0
    8020020c:	fc040793          	addi	a5,s0,-64
    80200210:	00d784b3          	add	s1,a5,a3
    80200214:	fbf40793          	addi	a5,s0,-65
    80200218:	00d78933          	add	s2,a5,a3
    8020021c:	02069693          	slli	a3,a3,0x20
    80200220:	0206d693          	srli	a3,a3,0x20
    80200224:	40d90933          	sub	s2,s2,a3
        console_putc(buf[i]);
    80200228:	0004c503          	lbu	a0,0(s1)
    8020022c:	ee9ff0ef          	jal	ra,80200114 <console_putc>
    while (i--) {
    80200230:	fff48493          	addi	s1,s1,-1
    80200234:	ff249ae3          	bne	s1,s2,80200228 <print_number+0x54>
    }
}
    80200238:	03813083          	ld	ra,56(sp)
    8020023c:	03013403          	ld	s0,48(sp)
    80200240:	02813483          	ld	s1,40(sp)
    80200244:	02013903          	ld	s2,32(sp)
    80200248:	04010113          	addi	sp,sp,64
    8020024c:	00008067          	ret
        n = -((unsigned int)num);
    80200250:	40a004bb          	negw	s1,a0
        console_putc('-');
    80200254:	02d00513          	li	a0,45
    80200258:	ebdff0ef          	jal	ra,80200114 <console_putc>
        while (n) {
    8020025c:	fc040613          	addi	a2,s0,-64
    int i = 0;
    80200260:	00000693          	li	a3,0
            int d = n % base;
    80200264:	0009071b          	sext.w	a4,s2
            buf[i++] = (d < 10) ? ('0' + d) : ('a' + d - 10);
    80200268:	00900513          	li	a0,9
    8020026c:	0300006f          	j	8020029c <print_number+0xc8>
    while (i--) {
    80200270:	f8059ee3          	bnez	a1,8020020c <print_number+0x38>
    80200274:	fc5ff06f          	j	80200238 <print_number+0x64>
            buf[i++] = (d < 10) ? ('0' + d) : ('a' + d - 10);
    80200278:	0577879b          	addiw	a5,a5,87
    8020027c:	0ff7f793          	andi	a5,a5,255
    80200280:	0016859b          	addiw	a1,a3,1
    80200284:	00f60023          	sb	a5,0(a2)
            n /= base;
    80200288:	02e4d7bb          	divuw	a5,s1,a4
        while (n) {
    8020028c:	00160613          	addi	a2,a2,1
    80200290:	fee4e0e3          	bltu	s1,a4,80200270 <print_number+0x9c>
            n /= base;
    80200294:	00078493          	mv	s1,a5
            buf[i++] = (d < 10) ? ('0' + d) : ('a' + d - 10);
    80200298:	00058693          	mv	a3,a1
            int d = n % base;
    8020029c:	02e4f7bb          	remuw	a5,s1,a4
            buf[i++] = (d < 10) ? ('0' + d) : ('a' + d - 10);
    802002a0:	0007859b          	sext.w	a1,a5
    802002a4:	fcb54ae3          	blt	a0,a1,80200278 <print_number+0xa4>
    802002a8:	0307879b          	addiw	a5,a5,48
    802002ac:	0ff7f793          	andi	a5,a5,255
    802002b0:	fd1ff06f          	j	80200280 <print_number+0xac>

00000000802002b4 <printf>:

int printf(const char *fmt, ...) {
    802002b4:	f5010113          	addi	sp,sp,-176
    802002b8:	06113423          	sd	ra,104(sp)
    802002bc:	06813023          	sd	s0,96(sp)
    802002c0:	04913c23          	sd	s1,88(sp)
    802002c4:	05213823          	sd	s2,80(sp)
    802002c8:	05313423          	sd	s3,72(sp)
    802002cc:	05413023          	sd	s4,64(sp)
    802002d0:	03513c23          	sd	s5,56(sp)
    802002d4:	03613823          	sd	s6,48(sp)
    802002d8:	03713423          	sd	s7,40(sp)
    802002dc:	03813023          	sd	s8,32(sp)
    802002e0:	01913c23          	sd	s9,24(sp)
    802002e4:	07010413          	addi	s0,sp,112
    802002e8:	00050493          	mv	s1,a0
    802002ec:	00b43423          	sd	a1,8(s0)
    802002f0:	00c43823          	sd	a2,16(s0)
    802002f4:	00d43c23          	sd	a3,24(s0)
    802002f8:	02e43023          	sd	a4,32(s0)
    802002fc:	02f43423          	sd	a5,40(s0)
    80200300:	03043823          	sd	a6,48(s0)
    80200304:	03143c23          	sd	a7,56(s0)
    va_list ap;
    va_start(ap, fmt);
    80200308:	00840793          	addi	a5,s0,8
    8020030c:	f8f43c23          	sd	a5,-104(s0)
    int cnt = 0;

    for (; *fmt; fmt++) {
    80200310:	00054503          	lbu	a0,0(a0)
    80200314:	10050263          	beqz	a0,80200418 <printf+0x164>
    int cnt = 0;
    80200318:	00000a93          	li	s5,0
        if (*fmt != '%') {
    8020031c:	02500993          	li	s3,37
            cnt++;
            continue;
        }
        fmt++;
        if (!*fmt) break;
        switch (*fmt) {
    80200320:	06400a13          	li	s4,100
    80200324:	07300c13          	li	s8,115
        case 'x':
            print_number(va_arg(ap, int), 16, 0);
            break;
        case 's': {
            char *s = va_arg(ap, char*);
            if (!s) s = "(null)";
    80200328:	00000c97          	auipc	s9,0x0
    8020032c:	168c8c93          	addi	s9,s9,360 # 80200490 <printf+0x1dc>
        switch (*fmt) {
    80200330:	07800b93          	li	s7,120
    80200334:	06300b13          	li	s6,99
    80200338:	01c0006f          	j	80200354 <printf+0xa0>
            console_putc(*fmt);
    8020033c:	dd9ff0ef          	jal	ra,80200114 <console_putc>
            cnt++;
    80200340:	001a8a9b          	addiw	s5,s5,1
            continue;
    80200344:	00048913          	mv	s2,s1
    for (; *fmt; fmt++) {
    80200348:	00190493          	addi	s1,s2,1
    8020034c:	00194503          	lbu	a0,1(s2)
    80200350:	0c050663          	beqz	a0,8020041c <printf+0x168>
        if (*fmt != '%') {
    80200354:	ff3514e3          	bne	a0,s3,8020033c <printf+0x88>
        fmt++;
    80200358:	00148913          	addi	s2,s1,1
        if (!*fmt) break;
    8020035c:	0014c783          	lbu	a5,1(s1)
    80200360:	0a078e63          	beqz	a5,8020041c <printf+0x168>
        switch (*fmt) {
    80200364:	05478863          	beq	a5,s4,802003b4 <printf+0x100>
    80200368:	02fa7663          	bgeu	s4,a5,80200394 <printf+0xe0>
    8020036c:	07878463          	beq	a5,s8,802003d4 <printf+0x120>
    80200370:	09779a63          	bne	a5,s7,80200404 <printf+0x150>
            print_number(va_arg(ap, int), 16, 0);
    80200374:	f9843783          	ld	a5,-104(s0)
    80200378:	00878713          	addi	a4,a5,8
    8020037c:	f8e43c23          	sd	a4,-104(s0)
    80200380:	00000613          	li	a2,0
    80200384:	01000593          	li	a1,16
    80200388:	0007a503          	lw	a0,0(a5)
    8020038c:	e49ff0ef          	jal	ra,802001d4 <print_number>
            break;
    80200390:	fb9ff06f          	j	80200348 <printf+0x94>
        switch (*fmt) {
    80200394:	07378263          	beq	a5,s3,802003f8 <printf+0x144>
    80200398:	07679663          	bne	a5,s6,80200404 <printf+0x150>
            console_puts(s);
            break;
        }
        case 'c':
            console_putc((char)va_arg(ap, int));
    8020039c:	f9843783          	ld	a5,-104(s0)
    802003a0:	00878713          	addi	a4,a5,8
    802003a4:	f8e43c23          	sd	a4,-104(s0)
    802003a8:	0007c503          	lbu	a0,0(a5)
    802003ac:	d69ff0ef          	jal	ra,80200114 <console_putc>
            break;
    802003b0:	f99ff06f          	j	80200348 <printf+0x94>
            print_number(va_arg(ap, int), 10, 1);
    802003b4:	f9843783          	ld	a5,-104(s0)
    802003b8:	00878713          	addi	a4,a5,8
    802003bc:	f8e43c23          	sd	a4,-104(s0)
    802003c0:	00100613          	li	a2,1
    802003c4:	00a00593          	li	a1,10
    802003c8:	0007a503          	lw	a0,0(a5)
    802003cc:	e09ff0ef          	jal	ra,802001d4 <print_number>
            break;
    802003d0:	f79ff06f          	j	80200348 <printf+0x94>
            char *s = va_arg(ap, char*);
    802003d4:	f9843783          	ld	a5,-104(s0)
    802003d8:	00878713          	addi	a4,a5,8
    802003dc:	f8e43c23          	sd	a4,-104(s0)
    802003e0:	0007b503          	ld	a0,0(a5)
            if (!s) s = "(null)";
    802003e4:	00050663          	beqz	a0,802003f0 <printf+0x13c>
            console_puts(s);
    802003e8:	d51ff0ef          	jal	ra,80200138 <console_puts>
            break;
    802003ec:	f5dff06f          	j	80200348 <printf+0x94>
            if (!s) s = "(null)";
    802003f0:	000c8513          	mv	a0,s9
    802003f4:	ff5ff06f          	j	802003e8 <printf+0x134>
        case '%':
            console_putc('%');
    802003f8:	00098513          	mv	a0,s3
    802003fc:	d19ff0ef          	jal	ra,80200114 <console_putc>
            break;
    80200400:	f49ff06f          	j	80200348 <printf+0x94>
        default:
            // 未知格式符，原样输出
            console_putc('%');
    80200404:	00098513          	mv	a0,s3
    80200408:	d0dff0ef          	jal	ra,80200114 <console_putc>
            console_putc(*fmt);
    8020040c:	0014c503          	lbu	a0,1(s1)
    80200410:	d05ff0ef          	jal	ra,80200114 <console_putc>
            break;
    80200414:	f35ff06f          	j	80200348 <printf+0x94>
    int cnt = 0;
    80200418:	00000a93          	li	s5,0
        }
    }
    va_end(ap);
    return cnt;
    8020041c:	000a8513          	mv	a0,s5
    80200420:	06813083          	ld	ra,104(sp)
    80200424:	06013403          	ld	s0,96(sp)
    80200428:	05813483          	ld	s1,88(sp)
    8020042c:	05013903          	ld	s2,80(sp)
    80200430:	04813983          	ld	s3,72(sp)
    80200434:	04013a03          	ld	s4,64(sp)
    80200438:	03813a83          	ld	s5,56(sp)
    8020043c:	03013b03          	ld	s6,48(sp)
    80200440:	02813b83          	ld	s7,40(sp)
    80200444:	02013c03          	ld	s8,32(sp)
    80200448:	01813c83          	ld	s9,24(sp)
    8020044c:	0b010113          	addi	sp,sp,176
    80200450:	00008067          	ret
