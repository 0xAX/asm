# X86_64 어셈블리와 친해지기 [파트 5]

이 글은 x86_64 어셈블리의 다섯 번째 파트로 매크로를 다룹니다. 
이 포스트는 x86_64에 대한 블로그 포스트가 아니라 NASM 어셈블러와 그 전처리기에 대한 것입니다. 관심이 있다면 계속 읽어보세요.

## 매크로

NASM은 두 가지 형태의 매크로를 지원합니다:

* 단일 라인 매크로
* 다중 라인 매크로

단일 라인 매크로는 %define 지시어로 시작해야 합니다. 형식은 다음과 같습니다:

```assembly
%define macro_name(parameter) value
```

NASM 매크로는 C의 매크로와 비슷하게 작동합니다. 예를 들어, 다음과 같은 단일 라인 매크로를 만들 수 있습니다:

```assembly
%define argc rsp + 8
%define cliArg1 rsp + 24
```

그리고 이를 코드에서 사용할 수 있습니다:

```assembly
;;
;; argc는 rsp + 8로 확장됩니다
;;
mov rax, [argc]
cmp rax, 3
jne .mustBe3args
```

다중 라인 매크로는 %macro NASM 지시어로 시작하고 %endmacro로 끝납니다. 일반 형식은 다음과 같습니다:

```assembly
%macro number_of_parameters
    instruction
    instruction
    instruction
%endmacro
```

예를 들어:

```assembly
%macro bootstrap 1
          push ebp
          mov ebp,esp
%endmacro
```

그리고 이를 다음과 같이 사용할 수 있습니다:

```assembly
_start:
    bootstrap
```

다음은 PRINT 매크로의 예입니다:

```assembly
%macro PRINT 1
    pusha
    pushf
    jmp %%astr
%%str db %1, 0
%%strln equ $-%%str
%%astr: _syscall_write %%str, %%strln
popf
popa
%endmacro

%macro _syscall_write 2
	mov rax, 1
        mov rdi, 1
        mov rsi, %%str
        mov rdx, %%strln
        syscall
%endmacro
```

매크로가 어떻게 작동하는지 살펴보겠습니다: 
첫 번째 줄에서는 매개변수가 하나인 PRINT 매크로를 정의합니다. 

그 다음에는 모든 일반 레지스터(pusha 명령어를 사용하여)와 플래그 레지스터(pushf 명령어를 사용하여)를 푸시합니다.
이후 %%astr 레이블로 점프합니다. 매크로 내의 모든 레이블은 %%로 시작해야 합니다.

이제 _syscall_write 매크로로 이동합니다. 이 매크로는 두 개의 매개변수를 받습니다.
write 시스템 호출을 사용하여 문자열을 stdout으로 출력합니다. _syscall_write 매크로의 구현을 살펴보면:

```assembly
;; write 시스템 호출 번호
mov rax, 1
;; 파일 디스크립터, 표준 출력
mov rdi, 1
;; 메시지 주소
mov rsi, msg
;; 메시지 길이
mov rdx, 14
;; 시스템 호출 호출
syscall
```

매크로는 먼저 rax에 1을 설정하여 write 시스템 호출 번호를 지정하고, rdi에 1을 설정하여 표준 출력 파일 디스크립터를 지정합니다. 
그런 다음 rsi에 %%str을 설정하여 문자열의 포인터를 지정하고, %%str은 PRINT 매크로의 첫 번째 매개변수로 전달된 문자열입니다 (매크로 매개변수는 $parameter_number로 접근합니다). 

문자열은 0으로 끝나야 합니다. %%strlen은 문자열 길이를 계산합니다. 이후 시스템 호출을 syscall 명령어로 호출합니다.

이제 다음과 같이 사용할 수 있습니다:

```assembly
label: PRINT "Hello World!"
```

## 유용한 표준 매크로

NASM은 다음과 같은 표준 매크로를 지원합니다:

### STRUC

`STRUC`와 `ENDSTRUC`를 사용하여 데이터 구조를 정의할 수 있습니다. 예를 들어:

```assembly
struc person
   name: resb 10
   age:  resb 1
endstruc
```

그리고 이제 우리의 구조체 인스턴스를 만들 수 있습니다:

```assembly
section .data
    p: istruc person
      at name db "name"
      at age  db 25
    iend

section .text
_start:
    mov rax, [p + person.name]
```

### %include

다른 어셈블리 파일을 포함하고 %include 지시어를 사용하여 레이블로 점프하거나 함수를 호출할 수 있습니다.
