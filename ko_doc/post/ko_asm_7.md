# X86_64 어셈블리와 친해지기 [파트 7]

x64 어셈블리 소개 - x64 어셈블리와 친해지기 [파트 7] 입니다. 이번에는 C와 어셈블러를 함께 사용하는 방법을 살펴보겠습니다.

실제로 우리는 이를 함께 사용할 수 있는 3가지 방법이 있습니다:

* C 코드에서 어셈블리 루틴 호출하기
* 어셈블리 코드에서 C 루틴 호출하기
* C 코드에서 인라인 어셈블리 사용하기

어셈블리와 C를 함께 사용하는 방법을 보여주는 3개의 간단한 Hello world 프로그램을 작성해 봅시다.

## C에서 어셈블리 호출하기

먼저 다음과 같은 간단한 C 프로그램을 작성해 봅시다:

```C
#include <string.h>

int main() {
    char* str = "Hello World\n";
    int len = strlen(str);
    printHelloWorld(str, len);
    return 0;
}
```

여기서 우리는 두 개의 변수를 정의하는 C 코드를 볼 수 있습니다
stdout에 쓸 Hello world 문자열과 이 문자열의 길이입니다. 다음으로 이 2개의 변수를 매개변수로 하여 printHelloWorld 어셈블리 함수를 호출합니다. 

우리는 x86_64 Linux를 사용하므로, x86_64 linux 호출 규약을 알아야 합니다. 
그래야 printHelloWorld 함수를 어떻게 작성하고, 들어오는 매개변수를 어떻게 가져오는지 등을 알 수 있습니다...

함수를 호출할 때 처음 여섯 개의 매개변수는 rdi, rsi, rdx, rcx, r8, r9 범용 레지스터를 통해 전달되며, 그 외의 모든 매개변수는 스택을 통해 전달됩니다.
따라서 우리는 첫 번째와 두 번째 매개변수를 rdi와 rsi 레지스터에서 가져와 write 시스템 콜을 호출한 다음 ret 명령어로 함수에서 반환할 수 있습니다:

```assembly
global printHelloWorld

section .text
printHelloWorld:
		;; 1 arg
		mov r10, rdi
		;; 2 arg
		mov r11, rsi
		;; call write syscall
		mov rax, 1
		mov rdi, 1
		mov rsi, r10
		mov rdx, r11
		syscall
		ret
```

이제 다음과 같이 빌드할 수 있습니다:

```
build:
	nasm -f elf64 -o casm.o casm.asm
	gcc casm.o casm.c -o casm
```

## 인라인 어셈블리
다음 방법은 C 코드 직접 어셈블리 코드를 작성하는 것입니다. 
이를 위한 특별한 구문이 있습니다. 일반적인 형태는 다음과 같습니다:

```
asm [volatile] ("assembly code" : output operand : input operand : clobbers);
```

gcc 문서에서 읽을 수 있듯이 volatile 키워드는 다음을 의미합니다:

```
Extended asm 문의 일반적인 사용은 입력 값을 조작하여 출력 값을 생성하는 것입니다. 그러나 asm 문이 부작용을 일으킬 수도 있습니다. 그런 경우, volatile 한정자를 사용하여 특정 최적화를 비활성화해야 할 수 있습니다.
```

각 피연산자는 괄호 안에 C 표현식이 뒤따르는 제약 문자열로 설명됩니다. 여러 가지 제약 조건이 있습니다:

* `r` - 범용 레지스터에 변수 값 유지
* `g` - 범용 레지스터가 아닌 레지스터를 제외하고, 모든 레지스터, 메모리 또는 즉시 정수 피연산자가 허용됩니다.
* `f` - 부동 소수점 레지스터
* `m` - 메모리 피연산자가 허용되며, 기계가 일반적으로 지원하는 모든 종류의 주소를 사용할 수 있습니다.
기타 등등...

따라서 우리의 hello world는 다음과 같을 것입니다:

```C
#include <string.h>

int main() {
	char* str = "Hello World\n";
	long len = strlen(str);
	int ret = 0;

	__asm__("movq $1, %%rax \n\t"
		"movq $1, %%rdi \n\t"
		"movq %1, %%rsi \n\t"
		"movl %2, %%edx \n\t"
		"syscall"
		: "=g"(ret)
		: "g"(str), "g" (len));

	return 0;
}
```

여기서 우리는 이전 예제와 같은 2개의 변수와 인라인 어셈블리 정의를 볼 수 있습니다. 
먼저 우리는 rax와 rdi 레지스터에 1을 넣습니다(write 시스템 콜 번호와 stdout)는 것은 일반 어셈블리 hello world에서 했던 것과 같습니다.

다음으로 rsi와 rdi 레지스터에 대해 유사한 작업을 수행하지만 첫 번째 피연산자는 $ 대신 % 기호로 시작합니다.
이는 str이 %1로 참조되는 출력 피연산자이고 len이 %2로 참조되는 두 번째 출력 피연산자임을 의미합니다.

따라서 우리는 %n 표기법을 사용하여 str과 len의 값을 rsi와 rdi에 넣습니다. 여기서 n은 출력 피연산자의 번호입니다.
또한 레지스터 이름 앞에 %%가 붙습니다.

```
이는 GCC가 피연산자와 레지스터를 구분하는 데 도움이 됩니다. 피연산자는 접두사로 단일 %를 가집니다.
```

다음과 같이 빌드할 수 있습니다:

```
build:
	gcc casm.c -o casm
```

## 어셈블리에서 C 호출하기

그리고 마지막 방법은 어셈블리 코드에서 C 함수를 호출하는 것입니다.
예를 들어, 단순히 Hello world를 출력하는 하나의 함수가 있는 다음과 같은 간단한 C 코드가 있습니다:

```C
#include <stdio.h>

extern int print();

int print() {
	printf("Hello World\n");
	return 0;
}
```

이제 우리는 이 함수를 어셈블리 코드에서 extern으로 정의하고 이전 게시물에서 여러 번 했던 것처럼 call 명령어로 호출할 수 있습니다:

```asssembly
global _start

extern print

section .text

_start:
		call print

		mov rax, 60
		mov rdi, 0
		syscall
```

다음과 같이 빌드합니다:

```
build:
	gcc  -c casm.c -o c.o
	nasm -f elf64 casm.asm -o casm.o
	ld   -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc casm.o c.o -o casm
```

이제 우리의 세 번째 hello world를 실행할 수 있습니다.
