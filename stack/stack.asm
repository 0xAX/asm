;; Definition of the .data section
section .data
        ;; Number of the `sys_write` system call
        SYS_WRITE equ 1
        ;; Number of the `sys_exit` system call
        SYS_EXIT equ 60
        ;; Number of the standard output file descriptor
        STD_OUT equ 1
        ;; Exit code from the program. The 0 status code is a success.
        EXIT_CODE equ 0
        ;; ASCII code of the new line symbol ('\n')
        NEW_LINE db 0xa
        ;; Error message that is printed in a case of not enough command-line arguments
        WRONG_ARGC_MSG  db "Error: expected two command-line arguments", 0xa
        ;; Length of the WRONG_ARGC_MSG message
        WRONG_ARGC_MSG_LEN equ 42

;; Definition of the .text section
section .text
        ;; Reference to the entry point of our program
        global _start

;; Entry point
_start:
        ;; Fetch the number of arguments from the stack and store it in the rcx register.
        pop rcx
        ;; Check the number of the given command-line arguments.
        cmp rcx, 3
        ;; If not enough, jump to the error subroutine.
        jne argcError

        ;; Skip the first command-line argument which is usually the program name.
        add rsp, 8

        ;; Fetch the first command-line argument from the stack and store it in the rsi register.
        pop rsi
        ;; Convert the first command-line argument to an integer number.
        call str_to_int
        ;; Store the result in the r10 register.
        mov r10, rax

        ;; Fetch the second command-line argument from the stack and store it in the rsi register.
        pop rsi
        ;; Convert the second command-line argument to an integer number.
        call str_to_int
        ;; Store the result in the r11 register.
        mov r11, rax

        ;; Calculate the sum of the arguments. The result will be stored in the r10 register.
        add r10, r11

        ;; Move the sum value to the rax register.
        mov rax, r10
        ;; Initialize counter by resetting it to 0. It will store the length of the result string.
        xor rcx, rcx
        ;; Convert the sum from a number to a string to print the result to the standard output.
        jmp int_to_str

;; Print the error message if not enough command-line arguments.
argcError:
        ;; Specify the system call number (1 is `sys_write`).
        mov rax, SYS_WRITE
        ;; Set the first argument of `sys_write` to 1 (`stdout`).
        mov rdi, STD_OUT
        ;; Set the second argument of `sys_write` to the reference of the `WRONG_ARGC_MSG` variable.
        mov rsi, WRONG_ARGC_MSG
        ;; Set the third argument to the length of the `WRONG_ARGC_MSG` variable's value.
        mov rdx, WRONG_ARGC_MSG_LEN
        ;; Call the `sys_write` system call.
        syscall
        ;; Go to the exit of the program.
        jmp exit

;; Convert the command-line argument to the integer number.
str_to_int:
        ;; Set the value of the rax register to 0. It will store the result.
        xor rax, rax
        ;; Base for multiplication
        mov rcx, 10
__repeat:
        ;; Compare the first element in the given string with the `NUL` terminator (end of the string).
        cmp [rsi], byte 0
        ;; If we reached the end of the string, return from the procedure. The result is stored in the rax register.
        je __return
        ;; Move the current character from the command-line argument to the bl register.
        mov bl, [rsi]
        ;; Subtract the value 48 from the ASCII code of the current character.
        ;; This will give us the numeric value of the character.
        sub bl, 48
        ;; Multiple our result number by 10 to get the place for the next digit.
        mul rcx
        ;; Add the next digit to our result number.
        add rax, rbx
        ;; Move to the next character in the command-line argument string.
        inc rsi
        ;; Repeat until we reach the end of the string.
        jmp __repeat
__return:
        ;; Return from the str_to_int procedure.
        ret

;; Convert the sum to a string and print it to the standard output.
int_to_str:
        ;; High part of the dividend. The low part is in the rax register.
        mov rdx, 0
        ;; Set the divisor to 10.
        mov rbx, 10
        ;; Divide the sum stored in `rax. The resulting quotient will be stored in `rax`,
        ;; and the remainder will be stored in the `rdx` register.
        div rbx
        ;; Add 48 to the remainder to get a string ASCII representation of the number value.
        add rdx, 48
        ;; Store the remainder on the stack.
        push rdx
        ;; Increase the counter.
        inc rcx
        ;; Compare the rest of the sum with zero.
        cmp rax, 0x0
        ;; If it is not zero, continue to convert it to string.
        jne int_to_str
        ;; Otherwise, print the result.
        jmp printResult

;; Print the result to the standard output.
printResult:
        ;; Put the number of string characters to the rax register.
        mov rax, rcx
        ;; Put the value 8 to the rcx register.
        mov rcx, 8
        ;; Calculate the number of bytes in the given string by multiplying rax by 8.
        ;; The result will be stored in the rax register.
        mul rcx

        ;; Set the third argument to the length of the result string to print.
        mov rdx, rax
        ;; Specify the system call number (1 is `sys_write`).
        mov rax, SYS_WRITE
        ;; Set the first argument of `sys_write` to 1 (`stdout`).
        mov rdi, STD_OUT
        ;; Set the second argument of `sys_write` to the reference of the result string to print.
        mov rsi, rsp
        ;; Call the `sys_write` system call.
        syscall

        ;; Specify the system call number (1 is `sys_write`).
        mov rax, SYS_WRITE
        ;; Set the first argument of `sys_write` to 1 (`stdout`).
        mov rdi, STD_OUT
        ;; Set the second argument of `sys_write` to the reference of the `NWE_LINE` variable.
        mov rsi, NEW_LINE
        ;; Set the third argument to the length of the `NEW_LINE` variable's value (1 byte).
        mov rdx, 1
        ;; Call the `sys_write` system call.
        syscall

exit:
        ;; Specify the number of the system call (60 is `sys_exit`).
        mov rax, SYS_EXIT
        ;; Set the first argument of `sys_exit` to 0. The 0 status code is a success.
        mov rdi, EXIT_CODE
        ;; Call the `sys_exit` system call.
        syscall
