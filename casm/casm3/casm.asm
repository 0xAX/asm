global printHelloWorld

section .text
printHelloWorld:
		;; 1 arg
		mov r10, rdi
		;; 2 arg
		mov r11, rsi
		;; call write syscall
		mov rax, 1
		mov rdi, 1
		mov rsi, r10
		mov rdx, r11
		syscall
		ret
