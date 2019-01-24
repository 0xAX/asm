section .data
    msg db "Merhaba, dünya!"

section .text
    global _start
_start:
    mov rax,1        ;sys_write syscall için
    mov rdi,1        ;sys_write ilk argümanı için. 1 sayısı standart output'u ifade eder.
    mov rsi,msg      ;msg işaretçisini rdi registerında saklıyoruz. sys_write için ikinci buf argümanı olacak.
    mov rdx,16       ;ve stringin uzunluğunu rdx e geçiriz. sys_write için üçüncü argüman olacak
    syscall          ;syscall fonksiyonunu çağırdık.

    mov rax,60       ;programdan çıkmak için exit syscall numarasi
    mov rdi,0        ;0 hata kodu numarası
    syscall                                                                                                                                                                                                                   
