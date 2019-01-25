; ilk değer atanmış veri
section .data
    SYS_WRITE   equ 1
    STD_OUT     equ 1
    SYS_EXIT    equ 60
    EXIT_CODE   equ 0

    NEW_LINE    db 0xa
    INPUT   db "Merhaba dunya!"

; ilk değer atanmamış veri
section .bss
    OUTPUT  resb 1

; kod
section .text
    global  _start

; ana program
_start:
    ; INPUT'un adresini al
    mov rsi, INPUT
    ;; zeroize rcx for counter
    xor rcx, rcx
    ; df = 0 si++
    cld
    ; Fonksiyon çağrısından sonraki yeri hatırla.
    mov rdi, $ + 15
    ; stringin uzunluğunu al
    call    stringUzunluguHesapla
    ; rax'a sıfır yaz
    xor rax, rax
    ; tersString için ek sayaç
    xor rdi, rdi
    ; ters string
    jmp tersString

;  stringin uzunluğunu hesapla
stringUzunluguHesapla:
    ; stringin sonu olup olmadığını kontrol et
    cmp byte [rsi], 0
    ; evet ise fonksiyondan çık.
    je  programdanCikis
    ;; load byte from rsi to al and inc rsi
    lodsb
    ; sembolü stack'e pushla
    push  rax
    ; sayacı arttır
    inc rcx
    ; tekrar döngü
    jmp stringUzunluguHesapla

; _start'a dön programdanCikis
programdanCikis:
    ; geri dönüş adresini tekrar stack'e pushla
    push    rdi
    ; _start'a geri dön
    ret

; ters string
;; 31 in stack
tersString:
    ; stringin sonu olup olmadığını kontrol et
    cmp rcx, 0
    ; Eğer evet ise stringi yazdır
    je  printResult
    ; sembolü stackten al
    pop rax
    ; output buffer'a yaz.
    mov [OUTPUT + rdi], rax
    ; sayacın uzunluğunu azalt
    dec rcx
    ; ek olarak sayacı arttır (write syscall için)
    inc rdi
    ; tekrar döngü
    jmp tersString

;Sonuç stringini yazdır
printResult:
    mov rdx, rdi
    mov rax, 1
    mov rdi, 1
    mov rsi, OUTPUT
    syscall
    jmp yeniSatirYazdir

; Yeni satırı yazdır
yeniSatirYazdir:
    mov rax, SYS_WRITE
    mov rdi, STD_OUT
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
