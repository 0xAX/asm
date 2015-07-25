global _start

extern print

section .text

_start:
	call	print

	mov	rax, 60
	mov	rdi, 0
	syscall
