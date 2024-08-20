# X86_64 어셈블리와 친해지기 [파트 4]

얼마 전 x86_64 어셈블리 프로그래밍에 관한 블로그 포스트 시리즈를 작성하기 시작했습니다. 관련 포스트는 `asm` 태그로 찾을 수 있습니다.
최근에는 바빠서 새로운 포스트가 없었지만, 오늘부터 다시 어셈블리에 대한 포스트를 작성할 예정이며, 매주 포스트를 시도할 것입니다.

오늘은 문자열과 문자열 작업에 대해 살펴보겠습니다. 여전히 NASM 어셈블러와 Linux x86_64를 사용할 것입니다.

## 문자열 뒤집기

어셈블리 프로그래밍 언어에 대해 이야기할 때 문자열 데이터 타입에 대해 논의할 수 없습니다.
실제로 우리는 바이트 배열을 다루고 있습니다. 간단한 예제를 작성해 보겠습니다.

문자열 데이터를 정의하고 이를 뒤집어 결과를 표준 출력에 작성하는 작업을 시도할 것입니다. 
이 작업은 새로운 프로그래밍 언어를 배우기 시작할 때 일반적으로 접하게 되는 간단하고 인기 있는 과제입니다. 
구현을 살펴보겠습니다.

우선, 초기화된 데이터를 정의합니다. 이는 데이터 섹션에 배치될 것입니다 (섹션에 대한 내용은 이전 포스트에서 읽어보세요):

```assembly
section .data
		SYS_WRITE equ 1
		STD_OUT   equ 1
		SYS_EXIT  equ 60
		EXIT_CODE equ 0

		NEW_LINE db 0xa
		INPUT db "Hello world!"
```

여기서 네 가지 상수를 볼 수 있습니다:

* `SYS_WRITE` - 'write' 시스템 호출 번호
* `STD_OUT` - 표준 출력 파일 디스크립터
* `SYS_EXIT` - 'exit' 시스템 호출 번호
* `EXIT_CODE` - 종료 코드

시스템 호출 목록은 여기에서 확인할 수 있습니다. 또한 다음이 정의되어 있습니다:

* `NEW_LINE` - 새 줄 (\n) 기호
* `INPUT` - 우리가 뒤집을 입력 문자열

다음으로, 문자열을 뒤집어 넣을 버퍼를 위한 bss 섹션을 정의합니다:

```assembly
section .bss
		OUTPUT resb 12
```

좋아요 이제 데이터와 결과를 넣을 버퍼를 준비했으므로, 코드를 위한 text 섹션을 정의할 수 있습니다.

_start 루틴부터 시작해 보겠습니다:

```assembly
_start:
		mov rsi, INPUT
		xor rcx, rcx
		cld
		mov rdi, $ + 15
		call calculateStrLength
		xor rax, rax
		xor rdi, rdi
		jmp reverseStr
```

여기서 새로운 부분이 있습니다. 어떻게 작동하는지 살펴보겠습니다: 
우선, 2행에서 INPUT 주소를 rsi 레지스터에 넣습니다. 표준 출력으로 쓰는 것과 마찬가지로, rcx 레지스터를 0으로 초기화합니다.

rcx는 문자열의 길이를 계산하는 카운터 역할을 합니다. 4행에서 cld 명령어를 볼 수 있습니다. 이 명령어는 df 플래그를 0으로 설정합니다. 
이는 문자열의 길이를 계산할 때 문자열의 기호를 왼쪽에서 오른쪽으로 처리하기 위해 필요합니다. 다음으로 calculateStrLength 함수를 호출합니다. 

5행의 mov rdi, $ + 15 명령어를 누락했는데, 
이에 대해 조금 이따 설명하겠습니다. 이제 calculateStrLength 구현을 살펴보겠습니다:

```assembly
calculateStrLength:
    ;; 문자열의 끝인지 확인
    cmp byte [rsi], 0
    ;; 문자열의 끝이라면 함수 종료
    je exitFromRoutine
    ;; rsi에서 바이트를 al로 로드하고 rsi를 증가
    lodsb
    ;; 심볼을 스택에 푸시
    push rax
    ;; 카운터 증가
    inc rcx
    ;; 다시 루프
    jmp calculateStrLength
```

이제 calculateStrLength 함수에서 문자열을 스택에 푸시한 후, 어떻게 _start로 돌아가는지 살펴보겠습니다.
이 작업을 수행하려면 ret 명령어를 사용할 수 있습니다.
그러나 다음과 같은 코드가 있을 경우 문제가 발생할 수 있습니다:

```assembly
exitFromRoutine:
		;; return to _start
		ret
```

이 코드가 작동하지 않는 이유는 무엇일까요? 이는 조금 복잡합니다. 
함수가 호출될 때, 함수의 매개변수는 오른쪽에서 왼쪽으로 스택에 푸시됩니다. 

그런 다음, 반환 주소가 스택에 푸시되어 함수가 끝난 후 어디로 돌아가야 하는지 알 수 있습니다. 
그러나 calculateStrLength 함수에서 문자열의 각 문자를 스택에 푸시하였고, 이제 스택의 최상단에 반환 주소가 없기 때문에 함수가 어디로 돌아가야 하는지 알 수 없습니다.

```assembly
    mov rdi, $ + 15
```

이 문제를 해결하기 위해, 코드에서 다음과 같은 명령어를 살펴보겠습니다:

여기서:

* `$` - 현재 위치를 반환합니다.
* `$$` - 현재 섹션의 시작 위치를 반환합니다.

mov rdi, $ + 15는 현재 위치에서 15바이트를 더한 위치를 반환합니다.
이는 calculateStrLength 호출 이후에 실행될 코드의 주소를 저장하기 위함입니다.

구체적으로, mov rdi, $ + 15 명령어는 calculateStrLength 호출 이후의 주소를 rdi 레지스터에 저장합니다.

이제 objdump 유틸리티를 사용하여 reverse 파일을 열어보겠습니다:

```assembly
objdump -D reverse

reverse:     file format elf64-x86-64

Disassembly of section .text:

00000000004000b0 <_start>:
  4000b0:	48 be 41 01 60 00 00 	movabs $0x600141,%rsi
  4000b7:	00 00 00
  4000ba:	48 31 c9             	xor    %rcx,%rcx
  4000bd:	fc                   	cld
  4000be:	48 bf cd 00 40 00 00 	movabs $0x4000cd,%rdi
  4000c5:	00 00 00
  4000c8:	e8 08 00 00 00       	callq  4000d5 <calculateStrLength>
  4000cd:	48 31 c0             	xor    %rax,%rax
  4000d0:	48 31 ff             	xor    %rdi,%rdi
  4000d3:	eb 0e                	jmp    4000e3 <reverseStr>
```

우리는 이제 반환 주소가 스택에 올바르게 푸시되고 함수가 반환되는 방법을 이해했습니다. 
이렇게 하면 _start로 정확하게 돌아올 수 있습니다. calculateStrLength 함수 호출 후, rax와 rdi를 0으로 초기화하고 reverseStr 레이블로 점프합니다.

이제 reverseStr 레이블의 구현을 살펴보겠습니다:

```assembly
exitFromRoutine:
    ;; 반환 주소를 스택에 다시 푸시
    push rdi
    ;; _start로 반환
    ret
```

이제 우리는 _start로 돌아옵니다. calculateStrLength를 호출한 후, rax와 rdi에 0을 저장하고 reverseStr 레이블로 점프합니다. 

reverseStr의 구현은 다음과 같습니다:

```assembly
reverseStr:
		cmp rcx, 0
		je printResult
		pop rax
		mov [OUTPUT + rdi], rax
		dec rcx
		inc rdi
		jmp reverseStr
```

여기서는 문자열의 길이를 나타내는 카운터를 확인하고, 카운터가 0이 되면 모든 기호를 버퍼에 썼으므로 이를 출력할 수 있습니다.
카운터를 확인한 후, 스택에서 rax 레지스터로 첫 번째 기호를 팝하여 OUTPUT 버퍼에 씁니다. 

rdi를 추가하여 기호가 버퍼의 첫 번째 바이트에 쓰이지 않도록 합니다. 그 후 rdi를 증가시켜 OUTPUT 버퍼의 다음 위치로 이동하고, 
길이 카운터를 감소시킨 후 레이블의 시작으로 점프합니다.

reverseStr가 실행된 후에는 OUTPUT 버퍼에 문자열이 역순으로 저장되어 있으며, 새 줄을 추가하여 결과를 stdout에 쓸 수 있습니다.

```assembly
printResult:
		mov rdx, rdi
		mov rax, 1
		mov rdi, 1
		mov rsi, OUTPUT
                syscall
		jmp printNewLine

printNewLine:
		mov rax, SYS_WRITE
		mov rdi, STD_OUT
		mov rsi, NEW_LINE
		mov rdx, 1
		syscall
		jmp exit
```

그리고 프로그램을 종료합니다:

```assembly
exit:
		mov rax, SYS_EXIT
		mov rdi, EXIT_CODE
		syscall
```

이제 모든 것이 완료되었습니다. 프로그램을 다음 명령어로 컴파일할 수 있습니다:

```assembly
all:
	nasm -g -f elf64 -o reverse.o reverse.asm
	ld -o reverse reverse.o

clean:
	rm reverse reverse.o
```

실행 결과:

![result](/content/assets/result_asm_4.png)

## 문자열 작업

물론 문자열 및 바이트 조작을 위한 많은 다른 명령어가 있습니다:

* `REP` - RCX가 0이 아닌 동안 반복합니다.
* `MOVSB` - 바이트 문자열을 복사합니다 (MOVSW, MOVSD 등도 사용 가능합니다..)
* `CMPSB` - 바이트 문자열 비교
* `SCASB` - 바이트 문자열 스캔
* `STOSB` - 문자열에 바이트를 기록합니다
