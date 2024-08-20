파트 8이자 마지막 파트에서는 어셈블리에서 비정수 숫자를 다루는 방법을 살펴보겠습니다. 부동 소수점 데이터를 처리하는 방법에는 몇 가지가 있습니다:

* FPU (부동 소수점 유닛)
* SSE (스트림 SIMD 확장)
  
먼저 부동 소수점 숫자가 메모리에 어떻게 저장되는지 살펴보겠습니다. 부동 소수점 데이터 유형에는 세 가지가 있습니다:

* 단정도 (single-precision)
* 배정도 (double-precision)
* 확장 배정도 (double-extended precision)

인텔의 64-IA-32 아키텍처 소프트웨어 개발자 매뉴얼 1권에 따르면:

```
이 데이터 유형의 데이터 형식은 IEEE 표준 754에 명시된 이진 부동 소수점 산술 형식에 직접적으로 해당됩니다.
```

단정도 부동 소수점 숫자는 메모리에 다음과 같이 저장됩니다:

* 부호 (sign) - 1 비트
* 지수 (exponent) - 8 비트
* 가수 (mantissa) - 23 비트
  
예를 들어, 다음과 같은 숫자가 있을 때:

    | sign 	| exponent | mantissa
    |-------|----------|-------------------------
    | 0  	| 00001111 | 110000000000000000000000

지수는 8 비트 부호가 있는 정수로 -128에서 127 사이이거나, 8 비트 부호가 없는 정수로 0에서 255 사이일 수 있습니다. 
부호 비트가 0이므로 양수입니다. 지수는 00001111b 또는 10진수로 15입니다. 단정도 부동 소수점에서의 편향값은 127이므로, 지수에서 127을 빼야 합니다.

즉, 15 - 127 = -112입니다. 정규화된 이진 정수 부분은 항상 1이므로 가수에는 그 소수 부분만 기록됩니다. 
즉, 가수는 1.110000000000000000000000입니다. 결과 값은 다음과 같습니다:

```
value = mantissa * 2^-112
```

배정도 숫자는 64 비트 메모리에 다음과 같이 저장됩니다:

* 부호 (sign) - 1 비트
* 지수 (exponent) - 11 비트
* 가수 (mantissa) - 52 비트

결과 숫자는 다음과 같이 계산할 수 있습니다:

```
value = (-1)^sign * (1 + mantissa / 2 ^ 52) * 2 ^ exponent - 1023)
```

확장 배정도는 80 비트 숫자이며:

* 부호 (sign) - 1 비트
* 지수 (exponent) - 15 비트
* 가수 (mantissa) - 112 비트

자세한 내용은 [여기](https://en.wikipedia.org/wiki/Extended_precision)에서 확인할 수 있습니다.
이제 간단한 예제를 살펴보겠습니다.

## x87 FPU

x87 부동 소수점 유닛(FPU)은 고성능 부동 소수점 처리를 제공합니다. 
부동 소수점, 정수 및 패킹된 BCD 정수 데이터 유형과 부동 소수점 처리 알고리즘을 지원합니다.

x87은 다음과 같은 명령어 세트를 제공합니다:

* 데이터 전송 명령어
* 기본 산술 명령어
* 비교 명령어
* 초월적 명령어
* 상수 로드 명령어
* x87 FPU 제어 명령어
  
물론 여기서 x87이 제공하는 모든 명령어를 살펴보지는 않겠지만,
추가 정보는 64-IA-32 아키텍처 소프트웨어 개발자 매뉴얼 1권의 8장을 참조하세요. 몇 가지 데이터 전송 명령어는 다음과 같습니다:

* `FDL` - 부동 소수점 로드
* `FST` - 부동 소수점 저장 (ST(0) 레지스터에)
* `FSTP` - 부동 소수점 저장 및 팝 (ST(0) 레지스터에)
  
산술 명령어:

* `FADD` - 부동 소수점 덧셈
* `FIADD` - 정수를 부동 소수점에 추가
* `FSUB` - 부동 소수점 뺄셈
* `FISUB` - 부동 소수점에서 정수 뺄셈
* `FABS` - 절대값 가져오기
* `FIMUL` - 정수와 부동 소수점 곱셈
* `FIDIV` - 정수와 부동 소수점 나눗셈

x87에는 10바이트 레지스터 8개가 링 스택 형태로 조직되어 있습니다. 스택의 맨 위는 ST(0) 레지스터이며, 나머지 레지스터는 ST(1), ST(2), ..., ST(7)입니다. 일반적으로 부동 소수점 데이터를 다룰 때 사용됩니다.

예를 들어:

```assembly
section .data
    x dw 1.0

fld dword [x]
```

이는 x의 값을 스택에 푸시합니다. 연산자는 32비트, 64비트 또는 80비트일 수 있습니다. 
일반 스택처럼 작동하며, fld로 다른 값을 푸시하면 x 값은 ST(1)에 있고, 새로운 값이 ST(0)에 위치하게 됩니다.
FPU 명령어는 이러한 레지스터를 사용할 수 있습니다. 

예를 들어:

```assembly
;;
;; st0 값을 st3에 더하고 결과를 st0에 저장합니다
;;
fadd st0, st3

;;
;; x와 y를 더하고 결과를 st0에 저장합니다
;;
fld dword [x]
fld dword [y]
fadd
```

간단한 예제를 살펴보겠습니다.
원의 반지름을 가지고 원의 면적을 계산하고 출력하는 예제입니다:

```assembly
extern printResult

section .data
		radius    dq  1.7
		result    dq  0

		SYS_EXIT  equ 60
		EXIT_CODE equ 0

global _start
section .text

_start:
		fld qword [radius]
		fld qword [radius]
		fmul

		fldpi
		fmul
		fstp qword [result]

		mov rax, 0
		movq xmm0, [result]
		call printResult

		mov rax, SYS_EXIT
		mov rdi, EXIT_CODE
		syscall
```

이 예제의 동작을 이해해 보겠습니다: 
우선 데이터 섹션에는 반지름 데이터와 결과를 저장할 변수들이 정의되어 있습니다.
그 후 시스템 호출 종료를 위한 두 상수가 정의되어 있습니다. 프로그램의 진입점인 _start에서 fld 명령어로 ST(0)과 ST(1) 레지스터에 반지름 값을 저장하고, fmul 명령어로 두 값을 곱합니다.

이 연산 후에는 ST(0) 레지스터에 반지름의 제곱이 저장됩니다.
이후 fldpi 명령어로 π 값을 ST(0) 레지스터에 로드하고, fmul로 ST(0) (π)과 ST(1) (반지름의 제곱)을 곱하여 결과를 ST(0) 레지스터에 저장합니다. 
이제 ST(0) 레지스터에 원의 면적이 있으므로 fstp 명령어로 결과를 저장소에 추출합니다. 다음으로, 결과를 C 함수에 전달하고 호출합니다.

어셈블리 코드에서 C 함수를 호출할 때 x86_64 호출 규약을 알아야 합니다.
일반적으로 함수 매개변수는 레지스터 rdi (arg1), rsi (arg2) 등을 통해 전달되지만, 부동 소수점 데이터의 경우에는 특별한 레지스터 xmm0 - xmm15가 사용됩니다.
우선 xmmN 레지스터의 번호를 rax 레지스터에 넣고 (우리의 경우 0), 결과를 xmm0 레지스터에 넣습니다. 이제 C 함수 printResult를 호출할 수 있습니다:

```C
#include <stdio.h>

extern int printResult(double result);

int printResult(double result) {
	printf("Circle radius is - %f\n", result);
	return 0;
}
```

이 코드는 다음과 같이 빌드할 수 있습니다:

```
build:
	gcc  -g -c circle_fpu_87c.c -o c.o
	nasm -f elf64 circle_fpu_87.asm -o circle_fpu_87.o
	ld   -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc circle_fpu_87.o  c.o -o testFloat1

clean:
	rm -rf *.o
	rm -rf testFloat1
```

그리고 실행하면:

![result](/content/assets/result_asm_8.png)


