
스택은 LIFO(Last In, First Out) 원칙으로 작동하는 메모리의 특별한 영역입니다.

임시 데이터 저장을 위해 16개의 범용 레지스터가 있습니다.
RAX, RBX, RCX, RDX, RDI, RSI, RBP, RSP 및 R8-R15입니다. 

이는 심각한 애플리케이션에는 너무 적습니다. 따라서 스택에 데이터를 저장할 수 있습니다. 
스택의 또 다른 용도는 다음과 같습니다: 함수를 호출할 때 반환 주소가 스택에 복사됩니다.
함수 실행이 끝난 후, 주소가 명령 카운터(RIP)에 복사되고 애플리케이션은 함수 다음 위치에서 계속 실행됩니다.

예를 들어:

```assembly
global _start

section .text

_start:
		mov rax, 1
		call incRax
		cmp rax, 2
		jne exit
		;;
		;; Do something
		;;

incRax:
		inc rax
		ret
```

여기서 애플리케이션 실행 후 rax는 1과 같습니다. 
그 다음 rax 값을 1 증가시키는 incRax 함수를 호출하므로 rax 값은 2가 되어야 합니다.
이후 실행은 8번째 줄에서 계속되며, 여기서 rax 값을 2와 비교합니다.

또한 System V AMD64 ABI에서 읽을 수 있듯이, 처음 6개의 함수 인수는 레지스터로 전달됩니다. 이들은:

* rdi - 첫 번째 인수
* rsi - 두 번째 인수
* rdx - 세 번째 인수
* rcx - 네 번째 인수
* r8 - 다섯 번째 인수
* r9 - 여섯 번째 인수

그 다음 인수들은 스택으로 전달됩니다. 따라서 다음과 같은 함수가 있다면:

```C
int foo(int a1, int a2, int a3, int a4, int a5, int a6, int a7)
{
    return (a1 + a2 - a3 - a4 + a5 - a6) * a7;
}
```

처음 6개의 인수는 레지스터로 전달되고, 7번째 인수부터는 스택으로 전달됩니다.

## 스택 포인터

앞서 말한대로 16개의 범용 레지스터가 있고, 그 중 RSP와 RBP 두 개의 흥미로운 레지스터가 있습니다.
RBP는 베이스 포인터 레지스터로, 현재 스택 프레임의 베이스를 가리킵니다. RSP는 스택 포인터로, 현재 스택 프레임의 최상단을 가리킵니다.

## 명령어

스택 작업을 위한 두 가지 명령어가 있습니다:

* `push argument` - 스택 포인터(RSP)를 증가시키고 스택 포인터가 가리키는 위치에 인수를 저장합니다.
* `pop argument` - 스택 포인터가 가리키는 위치에서 인자로 데이터를 복사합니다.

간단한 예제를 살펴보겠습니다:

```assembly
global _start

section .text

_start:
		mov rax, 1
		mov rdx, 2
		push rax
		push rdx

		mov rax, [rsp + 8]

		;;
		;; Do something
		;;
```

여기서 우리는 rax 레지스터에 1을, rdx 레지스터에 2를 넣는 것을 볼 수 있습니다.
그 후 이 레지스터들의 값을 스택에 push합니다. 스택은 LIFO(Last In First Out) 방식으로 작동합니다.
따라서 이후 우리 애플리케이션의 스택은 다음과 같은 구조를 가지게 됩니다:

![stack diagram](/content/assets/stack-diagram.png)

그 다음 우리는 rsp + 8 주소를 가진 스택에서 값을 복사합니다. 
이는 스택의 최상단 주소를 가져와 여기에 8을 더하고, 이 주소에 있는 데이터를 rax로 복사한다는 의미입니다. 이 후 rax 값은 1이 될 것입니다.

## 예제

한 가지 예를 살펴보겠습니다. 두 개의 명령줄 인수를 받는 간단한 프로그램을 작성해 보겠습니다. 이 인수의 합을 구하고 결과를 출력합니다.

```assembly
section .data
		SYS_WRITE equ 1
		STD_IN    equ 1
		SYS_EXIT  equ 60
		EXIT_CODE equ 0

		NEW_LINE   db 0xa
		WRONG_ARGC db "Must be two command line argument", 0xa
```

먼저 몇 가지 값으로 `.data` 섹션을 정의합니다. 
여기에는 리눅스 시스템 호출에 대한 네 가지 상수, sys_write, sys_exit 등이 있습니다. 
그리고 두 개의 문자열도 있습니다: 첫 번째는 새 줄 기호이고 두 번째는 오류 메시지입니다.

.text 섹션을 살펴보겠습니다. 이 섹션은 프로그램의 코드로 구성되어 있습니다:

```assembly
section .text
        global _start

_start:
		pop rcx
		cmp rcx, 3
		jne argcError

		add rsp, 8
		pop rsi
		call str_to_int

		mov r10, rax
		pop rsi
		call str_to_int
		mov r11, rax

		add r10, r11
```

여기서 무슨 일이 일어나는지 이해해 봅시다:
_start 레이블 이후 첫 번째 명령어는 스택에서 첫 번째 값을 가져와 rcx 레지스터에 넣습니다. 
명령줄 인수와 함께 애플리케이션을 실행하면 실행 후 모든 인수가 다음 순서로 스택에 있게 됩니다:

```
    [rsp] - 스택의 맨 위에는 인수 개수가 포함됩니다.
    [rsp + 8] - argv[0]이 포함됩니다.
    [rsp + 16] - argv[1]이 포함됩니다.
    계속 이런 식으로...
```

따라서 우리는 명령줄 인수 개수를 가져와 rcx에 넣습니다.
그 후 rcx를 3과 비교합니다. 만약 같지 않다면 argcError 레이블로 점프합니다. 
이 레이블은 단순히 오류 메시지를 출력합니다:

```assembly
argcError:
    ;; sys_write 시스템 콜
    mov     rax, 1
    ;; 파일 디스크립터, 표준 출력
    mov     rdi, 1
    ;; 메시지 주소
    mov     rsi, WRONG_ARGC
    ;; 메시지 길이
    mov     rdx, 34
    ;; write 시스템 콜 호출
    syscall
    ;; 프로그램 종료
    jmp exit
```

여기서 우리는 명령줄 인수의 합을 rax 레지스터에 넣고, r12를 0으로 설정한 후 int_to_str로 점프합니다.
이제 우리 프로그램의 기본 구조가 완성되었습니다. 
우리는 이미 문자열을 출력하는 방법을 알고 있고 출력할 내용도 있습니다. 
str_to_int와 int_to_str의 구현을 살펴보겠습니다.

```assembly
str_to_int:
            xor rax, rax
            mov rcx,  10
next:
	    cmp [rsi], byte 0
	    je return_str
	    mov bl, [rsi]
            sub bl, 48
	    mul rcx
	    add rax, rbx
	    inc rsi
	    jmp next

return_str:
	    ret
```

str_to_int의 시작에서 우리는 rax를 0으로, rcx를 10으로 설정합니다.
그 다음 next 레이블로 갑니다. 위의 예시에서 볼 수 있듯이(str_to_int의 첫 번째 호출 전 첫 줄) 우리는 스택에서 argv[1]을 rsi에 넣습니다. 
이제 rsi의 첫 번째 바이트를 0과 비교합니다. 모든 문자열은 NULL 심볼로 끝나기 때문이며, 만약 0이라면 반환합니다. 

0이 아니라면 그 값을 1바이트 bl 레지스터에 복사하고 48을 뺍니다.
왜 48인가요? 0부터 9까지의 모든 숫자는 ASCII 테이블에서 48부터 57까지의 코드를 가집니다. 

따라서 숫자 심볼에서 48을 빼면(예를 들어 57에서) 우리는 숫자를 얻게 됩니다. 그 다음 rax를 rcx(값은 10)와 곱합니다. 이후 rsi를 증가시켜 다음 바이트를 얻고 다시 루프합니다. 
알고리즘은 간단합니다. 예를 들어 rsi가 '5' '7' '6' '\000' 시퀀스를 가리킨다면 다음과 같은 단계를 거칩니다:

```
    rax = 0
    첫 번째 바이트 5를 가져와 rbx에 넣음
    rax * 10 --> rax = 0 * 10
    rax = rax + rbx = 0 + 5
    두 번째 바이트 7을 가져와 rbx에 넣음
    rax * 10 --> rax = 5 * 10 = 50
    rax = rax + rbx = 50 + 7 = 57
    rsi가 \000이 될 때까지 반복
```

str_to_int 후에는 rax에 숫자가 들어있게 됩니다. 이제 int_to_str을 살펴보겠습니다:

```assembly
int_to_str:
		mov rdx, 0
		mov rbx, 10
		div rbx
		add rdx, 48
		add rdx, 0x0
		push rdx
		inc r12
		cmp rax, 0x0
		jne int_to_str
		jmp print
```

여기서 우리는 rdx에 0을, rbx에 10을 넣습니다. 
그 다음 div rbx를 실행합니다. str_to_int 호출 전의 코드를 보면, rax에는 두 명령줄 인수의 합인 정수가 들어있습니다.
이 명령어로 rax 값을 rbx 값으로 나누고 나머지를 rdx에, 몫을 rax에 얻습니다.

다음으로 rdx에 48과 0x0을 더합니다. 48을 더하면 이 숫자의 ASCII 심볼을 얻게 되고, 모든 문자열은 0x0으로 끝나야 합니다. 

이후 심볼을 스택에 저장하고, r12를 증가시킵니다(첫 반복에서는 0입니다, _start에서 0으로 설정했습니다). 그리고 rax를 0과 비교합니다.
0이면 정수를 문자열로 변환이 끝났다는 뜻입니다. 알고리즘을 단계별로 살펴보겠습니다. 예를 들어 숫자 23이 있다면:

```
    123 / 10. rax = 12; rdx = 3
    rdx + 48 = "3"
    "3"을 스택에 push
    rax를 0과 비교, 아니면 다시 반복
    12 / 10. rax = 1; rdx = 2
    rdx + 48 = "2"
    "2"를 스택에 push
    rax를 0과 비교, 맞으면 함수 실행을 종료하고 스택에 "2" "3" ... 이 있게 됩니다
```

우리는 정수를 문자열로, 그리고 그 반대로 변환하는 두 가지 유용한 함수 `int_to_str`과 `str_to_int`를 구현했습니다. 
이제 우리는 문자열로 변환되어 스택에 저장된 두 정수의 합을 가지고 있습니다. 이제 결과를 출력할 수 있습니다.

```assembly
print:
   ;;;; 숫자 길이 계산
   mov rax, 1
   mul r12
   mov r12, 8
   mul r12
   mov rdx, rax
   ;;;; 합 출력
   mov rax, SYS_WRITE
   mov rdi, STD_IN
   mov rsi, rsp
   ;; sys_write 호출
   syscall
   jmp exit
```
우리는 이미 `sys_write` 시스템 콜로 문자열을 출력하는 방법을 알고 있지만, 여기에 한 가지 흥미로운 부분이 있습니다.
우리는 문자열의 길이를 계산해야 합니다. `int_to_str`을 보면, 매 반복마다 r12 레지스터를 증가시키는 것을 볼 수 있습니다.

따라서 r12에는 우리 숫자의 자릿수가 들어있습니다. 우리는 이를 8로 곱해야 합니다(각 심볼을 스택에 push했기 때문에), 그러면 출력해야 할 문자열의 길이가 됩니다. 
이후 항상 그랬듯이 rax에 1(sys_write 번호), rdi에 1(stdin), rdx에 문자열 길이, rsi에 스택의 최상단 포인터(문자열의 시작)를 넣습니다. 

그리고 프로그램을 종료합니다:

```assembly
exit:
	mov rax, SYS_EXIT
	종료 코드
	mov rdi, EXIT_CODE
	syscall
```

이것으로 "x64 어셈블리 소개 - x64 어셈블리와 친해지기 [파트 3]를 마칩니다.

