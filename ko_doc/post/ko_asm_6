
이 글은 x86_64 어셈블리의 여섯 번째 파트로 AT&T 어셈블리 문법을 다룹니다. 
이전에는 NASM 어셈블러를 사용했지만, AT&T 문법을 사용하는 GNU 어셈블러(gas)와 그 문법의 차이를 살펴보겠습니다.

GCC는 GNU 어셈블러를 사용하므로, 간단한 "Hello World" 프로그램의 어셈블리 출력은 다음과 같습니다:


```C
#include <unistd.h>

int main(void) {
	write(1, "Hello World\n", 15);
	return 0;
}
```

다음과 같은 출력이 나옵니다:

```assembly
	.file	"test.c"
	.section	.rodata
.LC0:
	.string	"Hello World\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$15, %edx
	movl	$.LC0, %esi
	movl	$1, %edi
	call	write
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 4.9.1-16ubuntu6) 4.9.1"
	.section	.note.GNU-stack,"",@progbits
```

위의 출력은 NASM의 "Hello World"와 다르게 보입니다. 차이점을 살펴보겠습니다.

## AT&T 문법

### 섹션

```assembly
.data
    //
    // 초기화된 데이터 정의
    //
.text
    .global _start

_start:
    //
    // 주요 루틴
    //
```

다음 두 가지 차이점이 있습니다:

* 섹션 정의는 . 기호로 시작합니다.
* 메인 루틴은 global 대신 .globl로 정의합니다.

GNU 어셈블러(gas)는 데이터 정의를 위해 다음과 같은 지시어를 사용합니다:

```assembly
.section .data
    // 1 바이트
    var1: .byte 10
    // 2 바이트
    var2: .word 10
    // 4 바이트
    var3: .int 10
    // 8 바이트
    var4: .quad 10
    // 16 바이트
    var5: .octa 10

    // 자동 종료 바이트 없이 연속적인 주소로 문자열을 조립
    str1: .asci "Hello world"
    // 자동 종료 바이트가 있는 문자열
    str2: .asciz "Hello world"
    // 문자열을 오브젝트 파일에 복사
    str3: .string "Hello world"
```

피연산자 순서
NASM에서 데이터 조작을 위한 일반 문법은 다음과 같습니다:

```assembly
mov destination, source
```

GNU 어셈블러에서는 피연산자 순서가 반대입니다:

```assembly
mov source, destination
```

예를 들어:

```assembly
;;
;; nasm 문법
;;
mov rax, rcx

//
// GNU(gas) 문법
//
mov %rcx, %rax
```

또한, GNU 어셈블러에서는 레지스터가 % 기호로 시작합니다. 직접 오퍼랜드를 사용할 때는 `$` 기호를 사용해야 합니다:

```assembly
movb $10, %rax
```

## 피연산자 크기 및 연산 문법

메모리의 일부, 예를 들어 64비트 레지스터의 첫 바이트를 가져와야 할 때, NASM에서는 다음과 같은 문법을 사용합니다:

```assembly
mov ax, word [rsi]
```

GNU 어셈블러에서는 피연산자의 크기를 명시하지 않고, 명령어에서 직접 정의합니다:

```assembly
movw (%rsi), %ax
```

GNU 어셈블러는 연산을 위한 6가지 접미사를 지원합니다:

* `b` - 1 바이트 피연산자
* `w` - 2 바이트 피연산자
* `l` - 4 바이트 피연산자
* `q` - 8 바이트 피연산자
* `t` - 10 바이트 피연산자
* `o` - 16 바이트 피연산자

이 규칙은 mov 명령어뿐만 아니라 addl, xorb, cmpw 등 다른 명령어에도 적용됩니다.

## 메모리 접근

이전 예제에서 () 괄호 대신 []를 사용했음을 주목할 수 있습니다. 
괄호 안의 값을 역참조할 때는 GAS에서는 다음과 같이 사용합니다: (%rax). 예를 들어:

```assembly
movq -8(%rbp),%rdi
movq 8(%rbp),%rdi
```

## 점프

GNU 어셈블러는 다음과 같은 연산자를 지원합니다:

```assembly
lcall $section, $offset
```

Far jump는 현재 코드 세그먼트와 다른 세그먼트에 있는 명령어로 점프하는 것입니다. 때로는 인터세그먼트 점프라고도 합니다.

## 주석

GNU 어셈블러는 다음과 같은 3가지 유형의 주석을 지원합니다:

```
    # - 한 줄 주석
    // - 한 줄 주석
    /* */ - 여러 줄 주석
```
