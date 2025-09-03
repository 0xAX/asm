#include <stdio.h>
#include <string.h>

int main() {
	char* str = "Hello World\n";
	long len = strlen(str);
	int ret = 0;

	__asm__("movq $1, %%rax \n\t"     // rax = 1 - Specify the number of the system call (1 is `sys_write`).
		"movq $1, %%rdi \n\t"     // rdi = 1 - Set the first argument of `sys_write` to 1 (`stdout`).
		"movq %1, %%rsi \n\t"     // rsi = str - Set the second argument of `sys_write` to the reference of the `str` variable.
		"movq %2, %%rdx \n\t"     // rdx = len(str) - Set the third argument of `sys_write` to the length of the `str` variable's value.
		"syscall"                 // Call the `sys_write` system call.
		: "=g"(ret)               // Return the result in the `ret` variable.
		: "g"(str), "g" (len));   // Put `str` and `len` variables in any general operand (memory, register or immediate if possible)

        printf("Bytes written: %d\n", ret);
	return 0;
}
