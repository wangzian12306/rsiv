# 工具链配置
CROSS_COMPILE = riscv64-unknown-elf-
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

# 编译选项
CFLAGS = -Wall -Werror -O -fno-omit-frame-pointer -ggdb -gdwarf-2
CFLAGS += -ffreestanding -fno-common -nostdlib -mcmodel=medany
CFLAGS += -march=rv64g -mabi=lp64
CFLAGS += -Iinclude

# 链接选项
LDFLAGS = -z max-page-size=4096

# 目标文件
OBJS = \
	kernel/entry.o \
	kernel/main.o \
	kernel/uart.o \
	kernel/console.o \
	kernel/printf.o
# 默认目标
all: kernel.elf

# 链接内核
kernel.elf: $(OBJS) kernel/kernel.ld
	$(LD) $(LDFLAGS) -T kernel/kernel.ld -o kernel.elf $(OBJS)
	$(OBJDUMP) -S kernel.elf > kernel.asm
	$(OBJDUMP) -t kernel.elf | grep -E "(main|_start)"

# 编译规则
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

# 运行QEMU
qemu: kernel.elf
	qemu-system-riscv64 -machine virt -nographic -kernel kernel.elf

# 调试QEMU
qemu-gdb: kernel.elf
	qemu-system-riscv64 -machine virt -nographic -kernel kernel.elf -S -s

# 清理
clean:
	rm -f *.o */*.o *.elf *.bin *.asm

