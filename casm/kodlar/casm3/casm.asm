global merhabaDunyaYazdir

section .text
merhabaDunyaYazdir:
	;; 1 arg
	mov	r10, rdi
	;; 2 arg
	mov	r11, rsi
	;; write syscall çağır
	mov	rax, 1
	mov	rdi, 1
	mov	rsi, r10
	mov	rdx, r11
	syscall
	ret
