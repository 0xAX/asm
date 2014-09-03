 ;initialised data section
section .data
	; Define constants
    num1:   equ 100
    num2:   equ 50
    ; http://geekswithblogs.net/MarkPearl/archive/2011/04/13/more-nasm.aspx
	msg:    db "Sum is correct", 10

;;
;; program code
;;
section .text

    global _start

;; entry point
_start:
    ; get sum of num1 and num2
	mov rax, num1
    mov rbx, num2
	add rax, rbx
    ; compare rax with correct sum - 150
	cmp rax, 150
    ; if rax is not 150 go to exit
	jne .exit
	; if rax is 150 print msg
	jmp .rightSum

; Print message that sum is correct
.rightSum:
	;; write syscall
    mov     rax, 1
    ;; file descritor, standard output
    mov     rdi, 1
    ;; message address
    mov     rsi, msg
    ;; length of message
    mov     rdx, 15
    ;; call write syscall
    syscall
    ; exit from program
	jmp .exit

; exit procedure
.exit:
    mov    rax, 60
    mov    rdi, 0
    syscall
