# file:hello.s
#
# Translated to gas syntax.
# assemble with:
# as --64 -o hello.o hello.s
# link with:
# ld -o hellos hellos.o
#
# Modifications to original code considered trivial and to be
# public domain.
#
# Support intel syntal vs. ATT and don't use % before register names
.intel_syntax noprefix

.section .data
    msg: .asciz "hello, world!\n"

.section .text

.global _start

_start:
    # write syscal
    mov     rax, 1
    # file descritor, standard output
    mov     rdi, 1
    # message address
    mov     rsi, OFFSET FLAT:msg
    # length of message
    mov     rdx, 14
    # call write syscall
    syscall

    #
    mov    rax, 60
    mov    rdi, 0

    syscall
