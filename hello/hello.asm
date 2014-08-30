section .data
    msg db      "hello, world!"

section .text

global _start

_start:
    ;; write syscal
    mov     rax, 1
    ;; file descritor, standard output
    mov     rdi, 1
    ;; message address
    mov     rsi, msg
    ;; length of message
    mov     rdx, 13
    ;; call write syscall
    syscall

    ;;
    mov    rax, 60
    mov    rdi, 0

    syscall
