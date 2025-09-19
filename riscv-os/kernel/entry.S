# RISC-V启动入口点
.section .text.entry
.globl _start
_start:
    # 调试输出：在设置栈前输出 'S'
    li t0, 0x10000000      # UART基地址
    li t1, 'S'             # 字符'S'
    sb t1, 0(t0)           # 输出到UART
    
    # 设置栈指针
    la sp, stack_top
    
    # 调试输出：设置栈后输出 'P'
    li t1, 'P'             # 字符'P'
    sb t1, 0(t0)           # 输出到UART
    
    # 跳转到C主函数
    call main
    
    # 死循环（防止返回）
1:  j 1b

# 定义栈大小和栈顶位置
.section .bss.stack
.globl stack_top
stack_top:
    .space 4096    # 4KB内核栈
.globl stack0
stack0:

