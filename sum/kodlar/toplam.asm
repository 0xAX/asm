section .data
    ; Sabitleri tanımla
    num1:   equ 100
    num2:   equ 50
    ; mesajı ata
    msg:    db "Toplam doğru\n"
  
section .text
    global _start

;; giriş noktası
_start:
    ; num1 değerini rax ‘a ata
    mov rax, num1
    ; num2 değerini rbx‘a ata
    mov rbx, num2
    ; rax ve rbx toplamını al ve değerini rax olarak sakla.
    add rax, rbx
    ; rax ve 150 karşılaştır.
    cmp rax, 150
    ;  rax ve 150 eşit değilse .cikis etiketine git
    jne .cikis
    ; rax ve 150 eşitse .dogruToplam etiketine git
    jmp .dogruToplam

; Toplam doğru ise mesajı yazdır
.dogruToplam:
    ; write syscall(sistem çağrısı)
    mov   rax, 1
    ; file descritor(dosya tanıtıcı), standart output(çıktı)
    mov   rdi, 1
    ; mesajın adresi
    mov   rsi, msg
    ; mesajın uzunluğu
    mov   rdx, 13
    ; write syscall(sistem çağrısı) çağır
    syscall
    ; programdan çık
    jmp .cikis

; çıkış prosedürü
.cikis:
    ; exit syscall
    mov    rax, 60
    ; çıkış kodu
    mov    rdi, 0
    ; exit syscall(sistem çağrısı) çağır
    syscall
