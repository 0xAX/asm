extern printResult

section .data
	radius		dq  1.7
	result		dq  0

	SYS_EXIT	equ 60
	EXIT_CODE	equ 0

section .text
	global	_start

_start:
	fld	qword [radius]
	fld	qword [radius]
	fmul

	fldpi
	fmul
	fstp	qword [result]

	mov	rax, 0
	movq	xmm0, [result]
	call	printResult

	mov	rax, SYS_EXIT
	mov	rdi, EXIT_CODE
	syscall