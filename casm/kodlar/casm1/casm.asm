global _start

extern yaz

section .text

_start:
	call    yaz

	mov	rax, 60
	mov	rdi, 0
	syscall
