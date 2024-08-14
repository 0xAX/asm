# 어셈블리 프로그래밍

[![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa] [![Check Links](https://github.com/0xAX/asm/actions/workflows/link-check.yaml/badge.svg)](https://github.com/0xAX/asm/actions/workflows/link-check.yaml) [![star this repo](https://badgen.net/github/stars/0xAX/asm)](https://github.com/0xAX/asm) [![이 저장소 포크하기](https://badgen.net/github/forks/0xAX/asm)](https://github.com/0xAX/asm/fork) [![기여 환영](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/0xAX/asm/issues)  [![PR 환영](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://makeapullrequest.com) 

이 저장소는 [assembly](https://en.wikipedia.org/wiki/Assembly_language) 프로그래밍 언어를 소개하는 블로그 포스트들을 포함하고 있습니다. 현재 모든 내용과 예제는 [x86_64](https://en.wikipedia.org/wiki/X86-64) 프로세서와 GNU Linux 운영 체제만을 다루고 있습니다. 향후에는 [ARM64](https://en.wikipedia.org/wiki/AArch64) 아키텍처에 대한 학습 자료도 게시할 계획입니다.

경험 많은 프로그래머이든 아니든, 이 포스트들은 모든 사람이 어셈블리 프로그래밍 언어를 배울 수 있도록 의도되었습니다. 포스트들은 다음 주제들을 다룹니다:

- x86_64 프로세서 아키텍처의 기본 설명
- 어셈블리 프로그래밍 언어로 간단한 프로그램을 작성, 빌드 및 실행하는 방법
- Linux용 프로그램의 주요 구성 요소
- 메모리 할당의 기초, 스택과 힙이란 무엇인가
- 시스템 콜이란 무엇이며 프로그램이 운영 체제와 어떻게 상호 작용하는가
- 부동 소수점 숫자가 컴퓨터 메모리에서 어떻게 표현되는가
- C 프로그램에서 어셈블리 코드를 호출하는 방법
- 그 외 다양한 주제...

즐겁게 배우세요!

![Magic](./content/assets/asm-introduction.png)

각 포스트에 대한 링크는 다음과 같습니다:

  * [Say hello to x86_64 Assembly part 1](https://github.com/0xAX/asm/blob/master/content/asm_1.md)
  * [Say hello to x86_64 Assembly part 2](https://github.com/0xAX/asm/blob/master/content/asm_2.md)
  * [Say hello to x86_64 Assembly part 3](https://github.com/0xAX/asm/blob/master/content/asm_3.md)
  * [Say hello to x86_64 Assembly part 4](https://github.com/0xAX/asm/blob/master/content/asm_4.md)
  * [Say hello to x86_64 Assembly part 5](https://github.com/0xAX/asm/blob/master/content/asm_5.md)
  * [Say hello to x86_64 Assembly part 6](https://github.com/0xAX/asm/blob/master/content/asm_6.md)
  * [Say hello to x86_64 Assembly part 7](https://github.com/0xAX/asm/blob/master/content/asm_7.md)
  * [Say hello to x86_64 Assembly part 8](https://github.com/0xAX/asm/blob/master/content/asm_8.md)

## 요구 사항

코드 예제를 실행하려면 다음 도구가 필요합니다:

- [64bit Linux 배포판](https://en.wikipedia.org/wiki/Linux_distribution)
- [make](https://www.gnu.org/software/make/)
- [NASM](https://nasm.us/)
- [binutils](https://www.gnu.org/software/binutils/)

## 번역

기여자분들 덕분에 어셈블리 프로그래밍에 대한 포스트들이 다양한 언어로 번역되었습니다.

> [!Note] 
> 번역은 원본 내용과 다를 수 있습니다.

### 중국어

  * [译文: Say hello to x64 Assembly [part 1]](https://github.com/time-river/vvl.me/blob/master/source/_posts/translation-Say-hello-to-x64-Assembly-part-1.md)
  * [译文: Say hello to x64 Assembly [part 2]](https://github.com/time-river/vvl.me/blob/master/source/_posts/translation-Say-hello-to-x64-Assembly-part-2.md)
  * [译文: Say hello to x64 Assembly [part 3]](https://github.com/time-river/vvl.me/blob/master/source/_posts/translation-Say-hello-to-x64-Assembly-part-3.md)
  * [译文: Say hello to x64 Assembly [part 4]](https://github.com/time-river/vvl.me/blob/master/source/_posts/translation-Say-hello-to-x64-Assembly-part-4.md)
  * [译文: Say hello to x64 Assembly [part 5]](https://github.com/time-river/vvl.me/blob/master/source/_posts/translation-Say-hello-to-x64-Assembly-part-5.md)
  * [译文: Say hello to x64 Assembly [part 6]](https://github.com/time-river/vvl.me/blob/master/source/_posts/translation-Say-hello-to-x64-Assembly-part-6.md)
  * [译文: Say hello to x64 Assembly [part 7]](https://github.com/time-river/vvl.me/blob/master/source/_posts/translation-Say-hello-to-x64-Assembly-part-7.md)
  * [译文: Say hello to x64 Assembly [part 8]](https://github.com/time-river/vvl.me/blob/master/source/_posts/translation-Say-hello-to-x64-Assembly-part-8.md)

### 튀르키예어

  * [X86_64 Assembly'a merhaba deyin bölüm 1](https://github.com/furkanonder/asm/blob/master/bolumler/1.md)
  * [X86_64 Assembly'a merhaba deyin bölüm 2](https://github.com/furkanonder/asm/blob/master/bolumler/2.md)
  * [X86_64 Assembly'a merhaba deyin bölüm 3](https://github.com/furkanonder/asm/blob/master/bolumler/3.md)
  * [X86_64 Assembly'a merhaba deyin bölüm 4](https://github.com/furkanonder/asm/blob/master/bolumler/4.md)
  * [X86_64 Assembly'a merhaba deyin bölüm 5](https://github.com/furkanonder/asm/blob/master/bolumler/5.md)
  * [X86_64 Assembly'a merhaba deyin bölüm 6](https://github.com/furkanonder/asm/blob/master/bolumler/6.md)
  * [X86_64 Assembly'a merhaba deyin bölüm 7](https://github.com/furkanonder/asm/blob/master/bolumler/7.md)
  * [X86_64 Assembly'a merhaba deyin bölüm 8](https://github.com/furkanonder/asm/blob/master/bolumler/8.md)

## 기여 

프로젝트에 기여하는 방법은 [기여 가이드](./CONTRIBUTING.md)를 읽어보세요. 기여할 때는 [행동 강령](./CODE_OF_CONDUCT.md)을 따라주세요.

## 라이선스

저장소의 각 Markdown 파일은
[크리에이티브 커먼즈 저작자표시-비영리-동일조건변경허락 4.0 국제 라이선스][cc-by-nc-sa]에 따라 라이선스가 부여됩니다.

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: https://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg

## 저자

기술 내용은 [@0xAX](https://x.com/0xAX)가 작성했습니다.

텍스트 개선에 큰 도움을 준 [@klaudiagrz](https://github.com/klaudiagrz)에게도 감사드립니다.
