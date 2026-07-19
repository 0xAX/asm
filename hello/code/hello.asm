;; Definition of the `data` section

;; Run it in UNIX or UNIX-like OS, and clearly don't compile on DOS mode
section .data
        ;; String variable with the value `hello world!`. 
        ;; Also, 0ah is the way to make the new line symbol.
        msg db "hello world!", 0ah ;;0ah is newline in ASM 
        ;;The size of the string/variable (14 charaters)
        .size equ $ - msg

;; Definition of the text section
section .text
        ;; Reference to the entry point of our program
        global _start
;; Entry point
_start:
.syswritefunc:
;Specify the number of syscall (sys_write)
mov rax, 1
;First argument, to let the computer know that it's an output(stdout)
mov rdi, 1
;Second argument, used to refernce the msg variable
mov rsi, msg
;To let the computer know the size of msg
mov rdx, msg.size
;Call the 'sys_write' call
syscall

jmp .exit

.exit:
;To let the computer know the number of syscall (sys_exit)
mov rax, 60
;To let it know it's a success
mov rdi, 0
;Call the 'sys_exit' call
syscall
