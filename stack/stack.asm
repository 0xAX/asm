section .data
		SYS_WRITE equ 1
		STD_IN    equ 1
		SYS_EXIT  equ 60
		EXIT_CODE equ 0

		NEW_LINE   db 0xa
		WRONG_ARGC db "Must be two command line argument", 0xa

section .text

        global _start

_start:
		;; rcx - argc
		pop rcx

		;;
		;; Check argc
		;;
		cmp rcx, 3
		jne argcError

		;;
		;; start to sum arguments
		;;

		;; skip argv[0] - program name
		add rsp, 8

		;; get argv[1]
		pop rsi
		;; convert argv[1] str to int
		call str_to_int
		;; put first num to r10
		mov r10, rax
        ;; get argv[2]
		pop rsi
		;; convert argv[2] str to int
		call str_to_int
        ;; put second num to r10
		mov r11, rax
		;; sum it
		add r10, r11

		;;
		;; Convert to string
		;;
		mov rax, r10
		;; number counter
		xor r12, r12
		;; convert to string
		jmp int_to_str

;;
;; Print argc error
;;
argcError:
        ;; sys_write syscall
		mov     rax, 1
        ;; file descritor, standard output
		mov     rdi, 1
        ;; message address
        mov     rsi, WRONG_ARGC
        ;; length of message
        mov     rdx, 34
        ;; call write syscall
        syscall
        ;; exit from program
	    jmp exit


;;
;; Convert int to string
;;
int_to_str:
		;; reminder from division
		mov rdx, 0
		;; base
		mov rbx, 10
		;; rax = rax / 10
		div rbx
		;; add \0
		add rdx, 48
		add rdx, 0x0
		;; push reminder to stack
		push rdx
		;; go next
		inc r12
		;; check factor with 0
		cmp rax, 0x0
		;; loop again
		jne int_to_str
		;; print result
		jmp print

;;
;; Convert string to int
;;
str_to_int:
		;; accumulator
		xor rax, rax
		;; base for multiplication
		mov rcx,  10
next:
		;; check that it is end of string
		cmp [rsi], byte 0
		;; return int
		je return_str
		;; mov current char to bl
		mov bl, [rsi]
        ;; get number
		sub bl, 48
		;; rax = rax * 10
		mul rcx
		;; ax = ax + digit
		add rax, rbx
		;; get next number
		inc rsi
		;; again
		jmp next

return_str:
		ret


;;
;; Print number
;;
print:
		;;;; calculate number length
		mov rax, 1
		mul r12
		mov r12, 8
		mul r12
		mov rdx, rax
		;;;;

		;;;; print sum
		mov rax, SYS_WRITE
		mov rdi, STD_IN
		mov rsi, rsp
		;; call sys_write
		syscall
		;;;;

        ;; newline
		jmp printNewline

;;
;; Print number
;;
printNewline:
		mov rax, SYS_WRITE
		mov rdi, STD_IN
		mov rsi, NEW_LINE
		mov rdx, 1
		syscall
		jmp exit

;;
;; Exit from program
;;
exit:
		;; syscall number
		mov rax, SYS_EXIT
		;; exit code
		mov rdi, EXIT_CODE
		;; call sys_exit
		syscall
