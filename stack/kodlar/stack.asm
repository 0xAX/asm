section .data
    SYS_WRITE equ 1
    STD_IN    equ 1
    SYS_EXIT  equ 60
    EXIT_CODE equ 0

    NEW_LINE   db 0xa
    WRONG_ARGC db "İki komut satırı argümanı olmalıdır", 0xa

section .text
    global  _start

_start:
    ; rcx - argc
    pop rcx

    ; argc'i kontrol et
    cmp rcx, 3
    jne argcError

    ;  argümanları toplamaya başla
    ;  argv[0]'ı atla - program adı
    add rsp, 8

    ; argv[1]'i al
    pop rsi
    ; argv[1]'i stringden tamsayıya çevir
    call    str_to_int
    ; r10'a ilk sayıyı koy
    mov r10, rax
    ; argv[2]'i al
    pop rsi
    ; argv[2]'i stringden tamsayıya çevir
    call    str_to_int
    ; r11'e ikinci sayıyı koy
    mov r11, rax
    ; topla
    add r10, r11

    ; stringe çevir
    mov rax, r10
    ; sayı sayacı
    xor r12, r12
    ; stringe çevir
    jmp int_to_str

; argc hatasını yazdır
argcError:
    ; sys_write syscall
    mov rax, 1
    ; file descriptor(dosya tanıtıcı), standart çıktı
    mov rdi, 1
    ; mesaj adresi
    mov rsi, WRONG_ARGC
    ; mesajın uzunluğu
    mov rdx, 35
    ; write syscall'u çağır
    syscall
    ; programdan çık
    jmp cikis

; tamsayıyı stringe çevir
int_to_str:
    ; bölümden kalan
    mov rdx, 0
    ; base
    mov  rbx, 10
    ; rax = rax / 10
    div rbx
    ; add \0
    add rdx, 48
    add rdx, 0x0
    ; kalanı stack'e pushla
    push rdx
    ; go next
    inc r12
    ; check factor with 0
    cmp rax, 0x0
    ; loop again
    jne int_to_str
    ; sonucu yazdır
    jmp yaz

; stringi tamsayıya çevir
str_to_int:
    ; accumulator
    xor rax, rax
    ; base for multiplication
    mov  rcx,  10
next:
    ; stringin sonu olup olmadığını kontrol et
    cmp [rsi], byte 0
    ; return int
    je  return_str
    ; mov current char to bl
    mov bl, [rsi]
    ; sayıyı al
    sub bl, 48
    ; rax = rax * 10
    mul rcx
    ; ax = ax + digit
    add rax, rbx
    ; sonraki sayıyı al
    inc rsi
    ; again
    jmp next

return_str:
    ret

; sayıyı yazdır
yaz:
    ; sayının uzunluğunu hesapla
    mov rax, 1
    mul r12
    mov r12, 8
    mul r12
    mov rdx, rax

    ; toplamı yazdır
    mov rax, SYS_WRITE
    mov rdi, STD_IN
    mov rsi, rsp
    ; sys_write'ı çağır
    syscall

    ; yeni satır
    jmp yeniSatirYazdir

; Sayıyı yazdır
yeniSatirYazdir:
    mov rax, SYS_WRITE
    mov rdi, STD_IN
    mov rsi, NEW_LINE
    mov rdx, 1
    syscall
    jmp cikis

; programdan çık
cikis:
    ; syscall sayısı
    mov rax, SYS_EXIT
    ; exit kodu
    mov rdi, EXIT_CODE
    ; sys_exit'i çağır
    syscall
