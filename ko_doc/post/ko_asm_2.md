며칠 전에 첫 블로그 포스트인 "x64 어셈블리 소개 - x64 어셈블리와 친해지기 [파트 1]"을 작성했는데, 예상외로 큰 관심을 받았습니다:

![newscombinator](/content/assets/newscombinator-screenshot.png)
![reddit](/content/assets/reddit-screenshot.png)

이것은 저를 더욱 학습하는 데 동기 부여를 해주었습니다.
그동안 많은 사람들로부터 피드백을 받았고, 감사의 말을 많이 들었습니다. 
하지만 저에게 더 중요한 것은 많은 조언과 적절한 비판이었습니다. 특히 훌륭한 피드백을 주신 분들에게 감사의 말씀을 전하고 싶습니다:

* [Fiennes](https://reddit.com/user/Fiennes)
* [Grienders](https://disqus.com/by/Universal178/)
* [nkurz](https://news.ycombinator.com/user?id=nkurz)

그리고 Reddit과 Hacker News에서 토론에 참여한 모든 분들께도 감사합니다.    
첫 번째 파트가 절대 초보자에게는 다소 명확하지 않았다는 의견이 많아서, 더 많은 정보를 담은 포스트를 작성하기로 결정했습니다.   
자, 이제 x86_64 어셈블리와 친해지기 [파트 2]를 시작해 보겠습니다.

## 용어 및 개념

위에서 언급했듯이, 첫 번째 포스트의 일부 부분이 명확하지 않다는 피드백을 많이 받았습니다. 그래서 이번 포스트부터는 우리가 이번과 다음 포스트에서 볼 수 있는 몇 가지 용어를 설명하려고 합니다.

레지스터 - 레지스터는 프로세서 내부의 소량의 저장소입니다. 프로세서의 주요 역할은 데이터 처리입니다. 프로세서는 메모리에서 데이터를 가져올 수 있지만, 이는 느린 작업입니다. 그래서 프로세서에는 레지스터라는 내부 제한된 데이터 저장소가 있습니다.

리틀 엔디안 - 메모리를 하나의 큰 배열로 상상할 수 있습니다. 이 배열은 바이트를 포함합니다. 각 주소는 메모리 배열의 한 요소를 저장합니다. 각 요소는 하나의 바이트입니다. 예를 들어, 4바이트가 AA 56 AB FF로 주어졌을 때, 리틀 엔디안에서는 가장 낮은 주소에 가장 낮은 유의 바이트가 저장됩니다:

```
    0 FF
    1 AB
    2 56
    3 AA
```


여기서 0, 1, 2, 3은 메모리 주소입니다.

빅 엔디안 - 빅 엔디안은 리틀 엔디안과 반대 순서로 바이트를 저장합니다. 따라서 AA 56 AB FF 바이트 시퀀스는 다음과 같습니다:

```
    0 AA
    1 56
    2 AB
    3 FF
```

시스템 호출 (Syscall) - 사용자 수준 프로그램이 운영 체제에게 작업을 요청하는 방법입니다. 시스템 호출 테이블은 [여기](https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_64.tbl)에서 찾을 수 있습니다.

스택 (Stack) - 프로세서는 매우 제한된 수의 레지스터를 가지고 있습니다. 따라서 스택은 연속적인 메모리 영역으로, `RSP`, `SS`, `RIP`와 같은 특수 레지스터로 주소 지정됩니다. 스택에 대해서는 다음 포스트에서 자세히 살펴보겠습니다.

섹션 (Section) - 모든 어셈블리 프로그램은 섹션으로 나뉩니다. 다음과 같은 섹션이 있습니다:

* `data` - 초기화된 데이터 또는 상수를 선언하는 데 사용됩니다.
* `bss` - 초기화되지 않은 변수를 선언하는 데 사용됩니다.
* `text` - 코드에 사용됩니다.

범용 레지스터 (General-purpose registers) - 총 16개의 범용 레지스터가 있습니다 - rax, rbx, rcx, rdx, rbp, rsp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15. 물론, 어셈블리 프로그래밍과 관련된 용어와 개념은 이 리스트에 포함되지 않은 것들이 많습니다. 다음 블로그 포스트에서 낯선 단어를 만나게 되면, 그에 대한 설명이 있을 것입니다.

## 데이터 타입

기본 데이터 타입은 바이트, 워드, 더블워드, 쿼드워드, 더블 쿼드워드입니다. 바이트는 8비트, 워드는 2바이트, 더블워드는 4바이트, 쿼드워드는 8바이트, 더블 쿼드워드는 16바이트 (128비트)입니다.

현재는 정수 숫자만 다룰 것이므로, 이에 대해 살펴보겠습니다. 정수에는 부호 없는 정수와 부호 있는 정수가 있습니다. 부호 없는 정수는 바이트, 워드, 더블워드, 쿼드워드에 저장된 부호 없는 이진 숫자입니다. 그 값의 범위는 부호 없는 바이트 정수의 경우 0부터 255까지, 부호 없는 워드 정수의 경우 0부터 65,535까지, 부호 없는 더블워드 정수의 경우 0부터 2^32 – 1까지, 부호 없는 쿼드워드 정수의 경우 0부터 2^64 – 1까지입니다. 부호 있는 정수는 부호가 있는 이진 숫자이며, 부호 없는 바이트, 워드 등에 저장됩니다. 부호 비트는 음수 정수에 대해 설정되고 양수 정수와 0에 대해 지워집니다. 정수 값의 범위는 바이트 정수의 경우 -128부터 +127까지, 워드 정수의 경우 -32,768부터 +32,767까지, 더블워드 정수의 경우 -2^31부터 +2^31 – 1까지, 쿼드워드 정수의 경우 -2^63부터 +2^63 – 1까지입니다.

## 섹션

앞서 언급했듯이, 모든 어셈블리 프로그램은 섹션으로 나뉩니다. 데이터 섹션, 텍스트 섹션, bss 섹션 등이 있습니다. 데이터 섹션을 살펴보겠습니다. 이 섹션의 주요 목적은 초기화된 상수를 선언하는 것입니다. 예를 들면:

```assembly
section .data
    num1:   equ 100
    num2:   equ 50
    msg:    db "Sum is correct", 10
```

여기까지 거의 모든 것이 명확합니다. `num1`, `num2`, `msg`라는 이름의 3개의 상수와 각각의 값으로 100, 50, "Sum is correct", 10이 정의되었습니다. 그런데 `db`, `equ`는 무엇일까요? 실제 NASM은 여러 가지 의사 명령어를 지원합니다:

* DB, DW, DD, DQ, DT, DO, DY, DZ - 초기화된 데이터를 선언하는 데 사용됩니다. 예를 들어:

```assembly
;; 4바이트 1h, 2h, 3h, 4h 초기화
db 0x01,0x02,0x03,0x04

;; 0x12 0x34로 워드 초기화
dw    0x1234
```

* RESB, RESW, RESD, RESQ, REST, RESO, RESY, RESZ - 초기화되지 않은 변수를 선언하는 데 사용됩니다.
* INCBIN - 외부 이진 파일 포함
* EQU - 상수를 정의합니다. 예를 들면:

```assembly
;; now one is 1
one equ 1
```

이 글에서는 그 중 일부를 실제로 살펴볼 것입니다. 다른 내용은 다음 게시물에서 다룰 예정입니다.

## 제어 흐름

일반적으로 프로그래밍 언어는 평가 순서를 변경할 수 있는 기능을 가지고 있습니다 (if 문, case 문, goto 등). 어셈블리에서도 이러한 기능이 있습니다. cmp 명령어는 두 값 간의 비교를 수행합니다. 이 명령어는 조건부 점프 명령어와 함께 사용되어 결정적인 동작을 수행합니다. 예를 들어:

```assembly
;; compare rax with 50
cmp rax, 50
```

`cmp` 명령어는 단순히 두 값을 비교할 뿐, 그 값들에 영향을 주거나 비교 결과에 따라 어떤 것도 실행하지 않습니다. 비교 후 어떤 동작을 수행하려면 조건부 점프 명령어를 사용합니다. 다음과 같은 명령어들이 있습니다:

* `JE` - 같으면
* `JZ` - 0이면
* `JNE` - 같지 않으면
* `JNZ` - 0이 아니면
* `JG` - 첫 번째 피연산자가 두 번째보다 크면
* `JGE` - 첫 번째 피연산자가 두 번째보다 크거나 같으면
* `JA` - JG와 동일하지만 부호 없는 비교 수행
* `JAE` - JGE와 동일하지만 부호 없는 비교 수행

예를 들어, C에서의 if/else 문과 비슷한 것을 구현하고 싶다면:

```C
if (rax != 50) {
    exit();
} else {
    right();
}
```

# 어셈블리 구문 비교와 점프

`cmp` 명령어는 단순히 두 값을 비교할 뿐, 그 값들에 영향을 주거나 비교 결과에 따라 어떤 것도 실행하지 않습니다. 비교 후 어떤 동작을 수행하려면 조건부 점프 명령어를 사용합니다. 다음과 같은 명령어들이 있습니다:

* `JE` - 같으면
* `JZ` - 0이면
* `JNE` - 같지 않으면
* `JNZ` - 0이 아니면
* `JG` - 첫 번째 피연산자가 두 번째보다 크면
* `JGE` - 첫 번째 피연산자가 두 번째보다 크거나 같으면
* `JA` - JG와 동일하지만 부호 없는 비교 수행
* `JAE` - JGE와 동일하지만 부호 없는 비교 수행

예를 들어, C에서의 if/else 문과 비슷한 것을 구현하고 싶다면 어셈블리에서는 다음과 같이 됩니다:

```assembly
;; rax를 50과 비교
cmp rax, 50
;; rax가 50과 같지 않으면 .exit 수행
jne .exit
jmp .right
```

또한 무조건 점프 구문도 있습니다:

```assembly
JMP label
```

예를 들면:

```assembly
_start:
    ;; ....
    ;; do something and jump to .exit label
    ;; ....
    jmp .exit

.exit:
    mov    rax, 60
    mov    rdi, 0
    syscall
```

여기서 우리는 _start 레이블 다음에 일부 코드를 가질 수 있고, 이 모든 코드는 실행될 것입니다. 어셈블리는 제어를 .exit 레이블로 이전하고, .exit: 다음의 코드가 실행되기 시작할 것입니다.
무조건 점프는 종종 반복문에서 사용됩니다. 예를 들어 우리는 레이블과 그 뒤에 일부 코드를 가집니다. 
이 코드는 무언가를 실행하고, 그 다음 조건이 있고 조건이 성공적이지 않으면 이 코드의 시작으로 점프합니다. 반복문은 다음 파트에서 다룰 것입니다.

## 예제

간단한 예제를 봅시다. 두 개의 정수를 받아, 이 숫자들의 합을 구하고 미리 정의된 숫자와 비교합니다.
미리 정의된 숫자가 합과 같으면 화면에 무언가를 출력하고, 그렇지 않으면 그냥 종료합니다. 여기 우리 예제의 소스 코드가 있습니다:

```assembly
section .data
    ; Define constants
    num1:   equ 100
    num2:   equ 50
    ; initialize message
    msg:    db "Sum is correct\n"

section .text

    global _start

;; entry point
_start:
    ; set num1's value to rax
    mov rax, num1
    ; set num2's value to rbx
    mov rbx, num2
    ; get sum of rax and rbx, and store it's value in rax
    add rax, rbx
    ; compare rax and 150
    cmp rax, 150
    ; go to .exit label if rax and 150 are not equal
    jne .exit
    ; go to .rightSum label if rax and 150 are equal
    jmp .rightSum

; Print message that sum is correct
.rightSum:
    ;; write syscall
    mov     rax, 1
    ;; file descritor, standard output
    mov     rdi, 1
    ;; message address
    mov     rsi, msg
    ;; length of message
    mov     rdx, 15
    ;; call write syscall
    syscall
    ; exit from program
    jmp .exit

; exit procedure
.exit:
    ; exit syscall
    mov    rax, 60
    ; exit code
    mov    rdi, 0
    ; call exit syscall
    syscall
```

소스 코드를 살펴봅시다. 우선 데이터 섹션에 두 개의 상수 num1, num2와 "Sum is correct\n" 값을 가진 변수 msg가 있습니다. 이제 14번째 줄을 보세요. 
여기서 프로그램의 진입점이 시작됩니다. num1과 num2 값을 범용 레지스터 rax와 rbx로 전송합니다. 
add 명령어로 이들을 더합니다. add 명령어 실행 후, rax와 rbx의 값을 더하고 그 결과를 rax에 저장합니다. 
이제 rax 레지스터에 num1과 num2의 합이 있습니다.

좋습니다. num1은 100이고 num2는 50입니다. 우리의 합은 150이 되어야 합니다. 
cmp 명령어로 이를 확인해 봅시다. rax와 150을 비교한 후 비교 결과를 확인합니다.
rax와 150이 같지 않으면(jne로 확인) .exit 레이블로 갑니다. 같다면 .rightSum 레이블로 갑니다.

이제 두 개의 레이블이 있습니다: .exit와 .rightSum. 첫 번째는 단순히 rax에 60을 설정합니다.
이는 exit 시스템 콜 번호이며, rdi에는 0을 설정합니다. 이는 종료 코드입니다. 
두 번째인 .rightSum은 매우 간단합니다. "Sum is correct"를 출력할 뿐입니다.
