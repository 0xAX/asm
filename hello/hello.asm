section .data
	msg	db "hello, world!",`\n`

section .text
	global	_start

_start:
	;; write syscall
	mov	rax, 1
	;; file descriptor, standard output
	mov	rdi, 1
	;; message address
	mov	rsi, msg
	;; length of message
	mov	rdx, 14
	;; call write syscall
	syscall

	;; exit
	mov	rax, 60
	mov	rdi, 0

	syscall
