;; Definition of the .data section
section .data
        ;; The first number
        num1 dq 0x64
        ;; The second number
        num2 dq 0x32
        ;; The message to print if the sum is correct
        msg db "The sum is correct!", 10

;; Definition of the .text section
section .text
        ;; Reference to the entry point of our program
        global _start

;; Entry point
_start:
        ;; Set the value of num1 to rax
        mov rax, [num1]
        ;; Set the value of num2 to rbx
        mov rbx, [num2]
        ;; Get the sum of rax and rbx. The result is stored in rax.
        add rax, rbx
.compare:
        ;; Compare the rax value with 150
        cmp rax, 150
        ;; Go to the .exit label if the rax value is not 150
        jne .exit
        ;; Go to the .correctSum label if the rax value is 150
        jmp .correctSum

;; Print a message that the sum is correct
.correctSum:
        ;; Specify the system call number (1 is `sys_write`).
        mov rax, 1
        ;; Set the first argument of `sys_write` to 1 (`stdout`).
        mov rdi, 1
        ;; Set the second argument of `sys_write` to the reference of the `msg` variable.
        mov rsi, msg
        ;; Set the third argument to the length of the `msg` variable's value (20 bytes).
        mov rdx, 20
        ;; Call the `sys_write` system call.
        syscall
        ;; Go to the exit of the program.
        jmp .exit

;; Exit procedure
.exit:
        ;; Specify the number of the system call (60 is `sys_exit`).
        mov rax, 60
        ;; Set the first argument of `sys_exit` to 0. The 0 status code is success.
        mov rdi, 0
        ;; Call the `sys_exit` system call.
        syscall
