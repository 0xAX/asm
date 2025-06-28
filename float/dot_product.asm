;; Definition of the .data section
section .data
        ;; Number of the `sys_read` system call.
        SYS_READ equ 0
        ;; Number of the `sys_write` system call.
        SYS_WRITE equ 1
        ;; Number of the `sys_exit` system call.
        SYS_EXIT equ 60
        ;; Number of the standard input file descriptor.
        STD_IN equ 0
        ;; Number of the standard output file descriptor.
        STD_OUT equ 1
        ;; Exit code from the program. The 0 status code is a success.
        EXIT_CODE equ 0

        ;; Maximum number of elements in a vector
        MAX_ELEMS equ 100
        ;; Size of buffer that we will use to read vectors
        BUFFER_SIZE equ 1024

        ;; Prompt for the first vector
        FIRST_INPUT_MSG: db "Input first vector: "
        ;; Length of the prompt for the first vector
        FIRST_INPUT_MSG_LEN equ 20

        ;; Prompt for the second vector
        SECOND_INPUT_MSG: db "Input second vector: "
        ;; Length of the prompt for the second vector
        SECOND_INPUT_MSG_LEN equ 21

        ;; Error message that we will print if the number of items in the vectors is not the same..
        ERROR_MSG: db "Error: the number of values in vectors should be the same", 0xA, 0
        ;; Length of the error message.
        ERROR_MSG_LEN equ 59

        ;; Format string for the result
        PRINTF_FORMAT: db "Dot product = %f", 0xA, 0

;; Definition of the .bss section
section .bss
        ;; Buffer to store double values of the first vector
        vector_1: resq MAX_ELEMS
        ;; Buffer to store double values of the second vector
        vector_2: resq MAX_ELEMS

        ;; Buffer to store input for the first vector
        buffer_1: resq BUFFER_SIZE
        ;; Pointer within the `buffer_1` which points to the current position
        ;; that we use to parse floats
        end_buffer_1: resq 1

        ;; Buffer to store input for the second vector
        buffer_2: resq BUFFER_SIZE
        ;; Pointer within the `buffer_2` which points to the current position
        ;; that we use to parse floats
        end_buffer_2: resq 1

;; Definition of the .text section
section .text
        ;; Reference to the C stdlib functions that we will use
        extern strtod, printf
        ;; Reference to the entry point of our program.
        global _start

;; Entry point of the program.
_start:
        ;; Read the first input string with floating-point values
        jmp _read_first_float_vector

;; Read the first input string with floating-point values
_read_first_float_vector:
        ;; Set the length of the prompt string to print.
        mov rdx, FIRST_INPUT_MSG_LEN
        ;; Specify the system call number (1 is `sys_write`).
        mov rax, SYS_WRITE
        ;; Set the first argument of `sys_write` to 1 (`stdout`).
        mov rdi, STD_OUT
        ;; Set the second argument of `sys_write` to the reference of the prompt string to print.
        mov rsi, FIRST_INPUT_MSG
        ;; Call the `sys_write` system call.
        syscall

        ;; Set the length of string we want to read from the standard input.
        mov rdx, BUFFER_SIZE
        ;; Specify the system call number (0 is `sys_read`)
        mov rdi, SYS_READ
        ;; Set the first argument of `sys_read` to 0 (`stdin`)
        mov rax, STD_IN
        ;; Set the second argument of `sys_read` to the reference of the buffer where we will
        ;; read the data for the vector.
        mov rsi, buffer_1
        ;; Call the `sys_read` system call.
        syscall

        ;; Save the number of bytes we have read from the standard input in the rcx register.
        mov rcx, rax
        ;; Set the pointer to the beginning of the buffer with the input data to the rdx register.
        mov rdx, buffer_1
        ;; Move pointer within the buffer to the end of input.
        add rdx, rcx
        ;; Fill the last byte of the input with 0.
        mov byte [rdx], 0

        ;; Reset the value of the r14 register to store the number of floating-point numbers
        ;; from the first vector.
        xor r14, r14
        ;; Set the pointer to the beginning of the buffer with the input data to the rdx register.
        mov rdi, buffer_1

;; Parse the floating-point values from the input buffer.
_parse_first_float_vector:
        ;; Initialize the rsi register with the pointer which will point to the place where
        ;; the strtod(3) will finish its work.
        mov rsi, end_buffer_1
        ;; Call the strtod(3) to conver floating-point value from the input buffer to double.
        call strtod

        ;; Preserve the pointer to the next floating-point value from the input buffer
        ;; in the rax register.
        mov rax, [end_buffer_1]
        ;; Check is it the end of the input string.
        cmp rax, rdi
        ;; Proceed with the second vector if we reached the end of the first.
        je _read_second_float_vector

        ;; Store the reference to the beginning of the buffer where we will store
        ;; our double values to the rdx register.
        mov rdx, vector_1
        ;; Store the number of floating-point values we already have read in the rcx register.
        mov rcx, r14
        ;; Multiple the number of floating-point values by 8.
        shl rcx, 3
        ;; Move the pointer from the beginning of the buffer with floating-point values that
        ;; we have parsed from the input string to the next value.
        add rdx, rcx
        ;; Store the next floating-point value in the buffer.
        movq [rdx], xmm0

        ;; Increase the number of floating-point value that we already have parsed.
        inc r14

        ;; Move the pointer within the input buffer to the next floating-point value.
        mov rdi, rax
        ;; Continue to parse floating-point values from the input string.
        jmp _parse_first_float_vector

;; Read the second input string with floating-point values
_read_second_float_vector:
        ;; Set the length of the prompt string to print.
        mov rdx, SECOND_INPUT_MSG_LEN
        ;; Specify the system call number (1 is `sys_write`).
        mov rax, SYS_WRITE
        ;; Set the first argument of `sys_write` to 1 (`stdout`).
        mov rdi, STD_OUT
        ;; Set the second argument of `sys_write` to the reference of the prompt string to print.
        mov rsi, SECOND_INPUT_MSG
        ;; Call the `sys_write` system call.
        syscall

        ;;; Set the length of string we want to read from the standard input.
        mov rdx, BUFFER_SIZE
        ;; Specify the system call number (0 is `sys_read`).
        mov rdi, SYS_READ
        ;; Set the first argument of `sys_read` to 0 (`stdin`).
        mov rax, STD_IN
        ;; Set the second argument of `sys_read` to the reference of the buffer where we will
        ;; read the data for the vector.
        mov rsi, buffer_2
        ;; Call the `sys_read` system call.
        syscall

        ;; Save the number of bytes we have read from the standard input in the rcx register.
        mov rcx, rax
        ;; Set the pointer to the beginning of the buffer with the input data to the rdx register.
        mov rdx, buffer_2
        ;; Move pointer within the buffer to the end of input.
        add rdx, rcx
        ;; Fill the last byte of the input with 0.
        mov byte [rdx], 0

        ;; Reset the value of the r15 register to store the number of floating-point numbers
        ;; from the second vector.
        xor r15, r15
        ;; Set the pointer to the beginning of the buffer with the input data to the rdx register.
        mov rdi, buffer_2

;; Parse the floating-point values from the input buffer.
_parse_second_float_vector:
        ;; Initialize the rsi register with the pointer which will point to the place where
        ;; the strtod(3) will finish its work.
        mov rsi, end_buffer_2
        ;; Call the strtod(3)
        call strtod

        ;; Preserve the pointer to the next floating-point value from the input buffer
        ;; in the rax register.
        mov rax, [end_buffer_2]
        ;; Check is it the end of the input string.
        cmp rax, rdi
        ;; Calculate the dot product after we have both vectors.
        je _calculate_dot_product
        
        ;; Store the reference to the beginning of the buffer where we will store
        ;; our double values to the rdx register.
        mov rdx, vector_2
        ;; Store the number of floating-point values we already have read in the rcx register.
        mov rcx, r15
        ;; Multiple the number of floating-point values by 8.
        shl rcx, 3        
        ;; Move the pointer from the beginning of the buffer with floating-point values that
        ;; we have parsed from the input string to the next value.
        add rdx, rcx
        ;; Store the next floating-point value in the buffer.
        movq [rdx], xmm0

        ;; Increase the number of floating-point value that we already have parsed.
        inc r15

        ;; Move the pointer within the input buffer to the next floating-point value.
        mov rdi, rax
        ;; Continue to parse floating-point values from the input string.
        jmp _parse_second_float_vector

;; Prepare to calculate the dot product of the two vectors.
_calculate_dot_product:
        ;; Check if the number of items in our vectors is not equal.
        test r14, r15
        ;; Print error and exit if not.
        jle _error

        ;; Set address of the first vector to the rdi register.
        mov rdi, vector_1
        ;; Set address of the second vector to the rdi register.
        mov rsi, vector_2
        ;; Set the number of values within the vectors to the rdx register.
        mov rdx, r14
        ;; Calculate the dot product of the two vectors.
        call _dot_product

        ;; Specify reference to the format string for the printf(3) in the rdi register.
        mov rdi, PRINTF_FORMAT
        ;; Number of arguments of the floating-point registers passed as arguments
        ;; to printf(3). We specify - `1` because we need to pass only `xmm0` with
        ;; the result of the program.
        mov rax, 1
        ;; Call the printf(3) function that will print the result.
        call printf

        ;; Exit from the program.
        jmp _exit

;; Calculate the dot product of the two vectors.
_dot_product:
        ;; Reset the value of the rax register to 0.
        xor rax, rax
        ;; Reset the value of the xmm1 register to 0.
        pxor xmm1, xmm1
        ;; Current rdx contains the number of floating-point values within the vectors.
        ;; Multiple it by 8 to get the number of bytes occupied by these values.
        sal rdx, 3
;; Calculate the the dot product in the loop.
_loop:
        ;; Move the floating-point value from the first vector to xmm0 register.
        movsd xmm0, [rdi + rax]
        ;; Multiple the floating-point from the second vector to the value from the first vector
        ;; and store the result in the xmm0 register.
        mulsd xmm0, [rsi + rax]
        ;; Move to the next floating-point values in the vector buffers.
        add rax, 8
        ;; Add the result of multiplication of floating-point values from the vectors in the
        ;; xmm1 register.
        addsd xmm1, xmm0
        ;; Check did we go through the all the floating-point values in the vector buffers.
        cmp rax, rdx
        ;; If not yet - repeat the loop.
        jne _loop
        ;; Move the result to the xmm0 register.
        movapd xmm0, xmm1
        ;; Return from the _dot_product back to the `_calculate_dot_product`.
        ret

;; Print error and exit.
_error:
        ;; Set the length of the prompt string to print.
        mov rdx, ERROR_MSG_LEN
        ;; Specify the system call number (1 is `sys_write`).
        mov rax, SYS_WRITE
        ;; Set the first argument of `sys_write` to 1 (`stdout`).
        mov rdi, STD_OUT
        ;; Set the second argument of `sys_write` to the reference of the prompt string to print.
        mov rsi, ERROR_MSG
        ;; Call the `sys_write` system call.
        syscall
        ;; Exit from the program
        jmp _exit

;; Exit from the program.
_exit:  
    ;; Specify the number of the system call (60 is `sys_exit`).
    mov rax, SYS_EXIT
    ;; Set the first argument of `sys_exit` to 0. The 0 status code is success.
    mov rdi, EXIT_CODE
    ;; Call the `sys_exit` system call.
    syscall
