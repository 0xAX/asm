;;
;; initialized data
;;
section .data
		SYS_WRITE equ 1
		STD_OUT   equ 1
		SYS_EXIT  equ 60
		EXIT_CODE equ 0

		NEW_LINE db 0xa
		INPUT db "Hello world!"

;;
;; non initialized data
;;
section .bss
		OUTPUT resb 1

;;
;; code
;;
section .text
        global _start

;;
;; main routine
;;
_start:
		;; get addres of INPUT
		mov rsi, INPUT
		;; zeroize rcx for counter
		xor rcx, rcx
		; df = 0 si++
		cld
		; remember place after function call
		mov rdi, $ + 15
        ;; get string lengt
		call calculateStrLength
		;; write zeros to rax
		xor rax, rax
		;; additional counter for reverseStr
		xor rdi, rdi
		;; reverse string
		jmp reverseStr

;;
;; calculate length of string
;;
calculateStrLength:
		;; check is it end of string
		cmp byte [rsi], 0
		;; if yes exit from function
		je exitFromRoutine
		;; load byte from rsi to al and inc rsi
		lodsb
		;; push symbol to stack
		push rax
		;; increase counter
		inc rcx
		;; loop again
		jmp calculateStrLength

;;
;; back to _start
;;
exitFromRoutine:
		;; push return addres to stack again
		push rdi
		;; return to _start
		ret

;;
;; reverse string
;;
;; 31 in stack
reverseStr:
		;; check is it end of string
		cmp rcx, 0
		;; if yes print result string
		je printResult
		;; get symbol from stack
		pop rax
		;; write it to output buffer
		mov [OUTPUT + rdi], rax
		;; decrease length counter
		dec rcx
		;; increase additional length counter (for write syscall)
		inc rdi
		;; loop again
		jmp reverseStr

;;
;; Print result string
;;
printResult:
		mov rdx, rdi
		mov rax, 1
		mov rdi, 1
		mov rsi, OUTPUT
        syscall
		jmp printNewLine

;;
;; Print new line
;;
printNewLine:
		mov rax, SYS_WRITE
		mov rdi, STD_OUT
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
