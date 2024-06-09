# Assembly programming

[![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa] [![Check Links](https://github.com/0xAX/asm/actions/workflows/link-check.yaml/badge.svg)](https://github.com/0xAX/asm/actions/workflows/link-check.yaml) [![star this repo](https://badgen.net/github/stars/0xAX/asm)](https://github.com/0xAX/asm) [![fork this repo](https://badgen.net/github/forks/0xAX/asm)](https://github.com/0xAX/asm/fork) [![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/0xAX/asm/issues)  [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://makeapullrequest.com) 

This repository contains blog posts that introduce the [assembly](https://en.wikipedia.org/wiki/Assembly_language) programming language. For this moment, all the content and examples cover only the [x86_64](https://en.wikipedia.org/wiki/X86-64) processors and the GNU Linux operating system. In the future, I plan to post learning materials for the [ARM64](https://en.wikipedia.org/wiki/AArch64) architecture.

Whether you are an experienced programmer or not, these posts are intended for everyone to learn assembly programming language. The series of the posts presents following topics:

- Basic description of the [x86_64](https://en.wikipedia.org/wiki/X86-64)
- How to write, build and run a simple program written in assembly programming language
- The main parts of which a program for Linux consists
- Basics of memory allocation, what is stack and heap
- What is system call and how your program interracts with an operating system
- How floating point numbers are represented in a computer memory
- How to call assembly code from a C program
- And many more...

Have a fun!

![Magic](./content/assets/asm-introduction.png)

The links to the each post:

  * [Say hello to x86_64 Assembly part 1](https://0xax.github.io/asm_1/)
  * [Say hello to x86_64 Assembly part 2](https://0xax.github.io/asm_2/)
  * [Say hello to x86_64 Assembly part 3](https://0xax.github.io/asm_3/)
  * [Say hello to x86_64 Assembly part 4](https://0xax.github.io/asm_4/)
  * [Say hello to x86_64 Assembly part 5](https://0xax.github.io/asm_5/)
  * [Say hello to x86_64 Assembly part 6](https://0xax.github.io/asm_6/)
  * [Say hello to x86_64 Assembly part 7](https://0xax.github.io/asm_7/)
  * [Say hello to x86_64 Assembly part 8](https://0xax.github.io/asm_8/)

## Requirements

To run code examples you will need following tools:

- [64-bit distribution of Linux](https://en.wikipedia.org/wiki/Linux_distribution)
- [make](https://www.gnu.org/software/make/)
- [NASM](https://nasm.us/)
- [binutils](https://www.gnu.org/software/binutils/)

## Translations

Thanks to the volunteers the posts about assembly programming are translated into different languages.

### Chinese translation:

  * [译文: Say hello to x64 Assembly [part 1]](https://github.com/time-river/vvl.me/blob/master/source/_posts/translation-Say-hello-to-x64-Assembly-part-1.md)
  * [译文: Say hello to x64 Assembly [part 2]](https://github.com/time-river/vvl.me/blob/master/source/_posts/translation-Say-hello-to-x64-Assembly-part-2.md)
  * [译文: Say hello to x64 Assembly [part 3]](https://github.com/time-river/vvl.me/blob/master/source/_posts/translation-Say-hello-to-x64-Assembly-part-3.md)
  * [译文: Say hello to x64 Assembly [part 4]](https://github.com/time-river/vvl.me/blob/master/source/_posts/translation-Say-hello-to-x64-Assembly-part-4.md)
  * [译文: Say hello to x64 Assembly [part 5]](https://github.com/time-river/vvl.me/blob/master/source/_posts/translation-Say-hello-to-x64-Assembly-part-5.md)
  * [译文: Say hello to x64 Assembly [part 6]](https://github.com/time-river/vvl.me/blob/master/source/_posts/translation-Say-hello-to-x64-Assembly-part-6.md)
  * [译文: Say hello to x64 Assembly [part 7]](https://github.com/time-river/vvl.me/blob/master/source/_posts/translation-Say-hello-to-x64-Assembly-part-7.md)
  * [译文: Say hello to x64 Assembly [part 8]](https://github.com/time-river/vvl.me/blob/master/source/_posts/translation-Say-hello-to-x64-Assembly-part-8.md)

### Turkish translation:

  * [X86_64 Assembly'a merhaba deyin bölüm 1](https://github.com/furkanonder/asm/blob/master/bolumler/1.md)
  * [X86_64 Assembly'a merhaba deyin bölüm 2](https://github.com/furkanonder/asm/blob/master/bolumler/2.md)
  * [X86_64 Assembly'a merhaba deyin bölüm 3](https://github.com/furkanonder/asm/blob/master/bolumler/3.md)
  * [X86_64 Assembly'a merhaba deyin bölüm 4](https://github.com/furkanonder/asm/blob/master/bolumler/4.md)
  * [X86_64 Assembly'a merhaba deyin bölüm 5](https://github.com/furkanonder/asm/blob/master/bolumler/5.md)
  * [X86_64 Assembly'a merhaba deyin bölüm 6](https://github.com/furkanonder/asm/blob/master/bolumler/6.md)
  * [X86_64 Assembly'a merhaba deyin bölüm 7](https://github.com/furkanonder/asm/blob/master/bolumler/7.md)
  * [X86_64 Assembly'a merhaba deyin bölüm 8](https://github.com/furkanonder/asm/blob/master/bolumler/8.md)

## License

Each the markdown file included in the repository is licensed under the
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: https://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg

## Author

The technical content is written by [@0xAX](https://x.com/0xAX).

Additional big thanks to [@klaudiagrz](https://github.com/klaudiagrz) for text improvements.
