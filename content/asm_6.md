# Floating-point arithmetic

In the previous chapters, we wrote simple assembly programs operating with numeric and string-like data. All the numeric data that we used were only integer numbers. This is not always practical and does not always map reality, as integer numbers do not allow us to represent fractional number values. In this chapter, we will learn how to operate with the [floating-point numbers](https://en.wikipedia.org/wiki/Floating-point_arithmetic) in our programs.

## Floating-point representation

First of all, let's take a look at how floating-point numbers are represented in memory. There are three floating-point data types:

- Single-precision
- Double-precision
- Double-extended precision

The Intel [Software Developer Manual](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html) says:

> The data formats for these data types correspond directly to formats specified in the IEEE Standard 754 for Binary Floating-Point Arithmetic.

To get all the possible details about the representation of the floating-point numbers in computer memory, you should take a look at this standard.

All of these formats differ in accuracy. The single-precision and double-precision formats correspond to the [C's](https://en.wikipedia.org/wiki/C_(programming_language)) [float and double](https://cppreference.com/w/c/language/arithmetic_types.html) data types. The double-extended precision format corresponds to the C's `long double` data type.  Let's take a look at each of them.

### Single-precision format

The single-precision value occupies `32-bits` of memory with the following structure:

- Sign - 1 bit
- Exponent - 8 bits
- Mantissa - 23 bits

The sign bit indicates whether the number is positive or negative. If the bit is set to `0`, the number is positive; if it’s `1`, the number is negative. While the idea of a sign is rather straightforward, the exponent and mantissa require a bit more explanation. To understand how floating-point numbers are represented in memory, we need to know how to convert the floating-point number from [decimal](https://en.wikipedia.org/wiki/Decimal) to [binary](https://en.wikipedia.org/wiki/Binary_number) representation.

Let's take a random floating-point number, for example - `5.625`. To convert a floating-point number to a binary representation, we need to split the number into integral and fractional parts. In our case, it is `5` and `625`. To convert the integer part of a number to its binary representation, divide it by `2` repeatedly, noting down the remainders, until the quotient becomes zero. Let's take a look:

| Division      | Quotient | Remainder |
|:-------------:|----------|-----------|
| $\frac{5}{2}$ |        2 |         1 |
| $\frac{5}{2}$ |        1 |         0 |
| $\frac{1}{2}$ |        0 |         1 |

To get the binary representation, we simply write down all the remainders we got during the division process. For the number `5`, the remainders are `1`, `0`, and `1`, which gives us `101` in binary (as shown in the "Remainder" column). So, the binary representation of `5` is `0b101`. 

> [!NOTE]
> We will use the prefix `0b` for all binary numbers to not mix them with the decimal numbers.

To convert the fractional part of our floating-point number, we need to multiply our number by `2` until the integral part equals 1. Let's try to convert the fractional part of our number:

| Multiplication | Result | Integral part | Fractional part |
|----------------|--------|---------------|-----------------|
|      0.625 * 2 |   1.25 |             1 |            0.25 |
|       0.25 * 2 |    0.5 |             0 |             0.5 |
|        0.5 * 2 |      1 |             1 |               0 |

To get the binary representation, we just write down all the integral parts that we got during the calculations. Integral parts for `0.625` are `1`, `0`, and `1`, which gives us `0b0.101` in binary. As a result, a binary representation of our floating point number `5.625` is `0b101.101`.

As you practice converting decimal floating-point numbers to binary, you'll soon notice an interesting pattern: not all fractional parts can be represented in binary. For example, let's take a look at the binary representation of the fractional part of the number `5.575`:

| Multiplication | Result | Integral part | Fractional part |
|----------------|--------|---------------|-----------------|
|      0.575 * 2 |   1.15 |             1 |            0.15 |
|       0.15 * 2 |   0.30 |             0 |            0.30 |
|       0.30 * 2 |   0.60 |             0 |            0.60 |
|       0.60.* 2 |   1.20 |             1 |            0.20 |
|       0.20 * 2 |   0.40 |             0 |            0.40 |
|       0.40 * 2 |   0.80 |             0 |            0.80 |
|       0.80 * 2 |   1.60 |             1 |            0.60 |
|       0.60 * 2 |   1.20 |             1 |            0.20 |
|       0.20 * 2 |   0.40 |             0 |            0.40 |
|       0.40 * 2 |   0.80 |             0 |            0.80 |
|       0.80 * 2 |   1.60 |             1 |            0.60 |
|       0.60 * 2 |   1.20 |             1 |            0.20 |

We can see that starting from step 5 (after the first four bits `1001`), the pattern `0011` repeats forever. Such repeatable parts are written down in brackets. For example, the number `5.575` in a binary form is `0b101.1001(0011)`. 

Here’s an interesting fact: if you convert a binary floating-point number back to decimal, you might not get exactly the same number you started with. That’s because floating-point numbers in a computer are only approximations of real values. This helps to understand a well-known example - let's try to ask [Python](https://www.python.org/) to do the simple computation:

```
>>> 0.1 + 0.2
0.30000000000000004

# Or

>>> 0.2 + 0.4
0.6000000000000001
```

After we convert both integral and fractional parts of our number to binary representation, we can move a step forward and convert it to [scientific notation](https://en.wikipedia.org/wiki/Scientific_notation). 

As a first step, we need to shift right the integral part of our number so that only one digit remains before the point. In the case of `0b101`, we need to shift right two digits. Basically when we are doing each shift - we divide our number by `2`. This is done because our number has base `2`. Shifting the number twice, we divide our number by $$2^{2}$$. To keep the original value unchanged, we multiple it by $$2^{2}$$. As a result, our initial number `0b101.101` is now represented as `0b1.01101 * 2^2`.

After this, we need to add the number of shifts to the special number called `bias`. For single-precision floating-point numbers, it is equal to `127`. So we get - `2 + 127 = 129` or `0b10000001`. This is our `exponent`. The `mantissa` is just the fractional part of the number that we got after shifting it. We just put all the numbers of the fractional parts to the 23 `mantissa` bits and rest filled with zeros.

If we combine all together, we can see how our number `5.625` is represented in a computer memory:

| Sign | Exponent | Mantissa                |
|------|----------|-------------------------|
|     0| 10000001 | 01101000000000000000000 |

If the fractional part of the number is periodic, as in the example of the number `5.575`, we fill the `mantissa` bits while it is possible. So the number `5.575` is represented in a computer memory as:

| Sign | Exponent | Mantissa                |
|------|----------|-------------------------|
|     0| 10000001 | 01100100110011001100110 |

Now we know how a computer represents a floating point number with a single-precision 🎉

### Double and double-extended precision formats

As you may guess, the representation of floating-point numbers using the double-precision and double-extended precision formats is similar to the single-precision format, and the only difference is accuracy.

The double-precision value occupies `64-bits` of memory with the following structure:

- Sign - 1 bit
- Exponent - 11 bits
- Mantissa - 52 bits

The extended-double precision value occupies `80-bits` of memory with the following structure:

- Sign - 1 bit
- Exponent - 15 bits
- Mantissa - 64 bits

The `bias` for the double-precision format is `1023`. The `bias` for the extended-double precision format is `16383`.

## Floating-point instructions

As mentioned at the beginning of this chapter, before this point, we wrote assembly programs that operated only with integer numbers. We used the general-purpose registers to store them, and instructions like `add`, `sub`, `mul`, and others to perform basic arithmetic. However, we cannot use these registers and instructions to operate on floating-point numbers. Fortunately, `x86_64` CPUs provide special registers and instructions for handling such numbers. These registers are called `XMM` registers.

There are 16 `XMM` registers named from `xmm0` through `xmm15`. These registers occupy `128 bits` of memory. At this point, the question might arise in your mind - if we have `32-bit` and `64-bit` floating point numbers, why do we have `128-bit` registers? The answer is that these registers were introduced as part of the [SIMD](https://en.wikipedia.org/wiki/Single_instruction,_multiple_data) extension instruction set. This instruction set allows for operating on `packed` data. It enables you to execute a single instruction on four `32-bit` floating point numbers, for example.

In addition to the sixteen `XMM` registers, each `x86_64` CPU includes a "legacy" floating-point unit named [x87 FPU](https://en.wikipedia.org/wiki/X87). It is built as an eight-deep register stack. Each of those stack slots may hold an `80-bit` extended-precision number.

Besides the data storage, the CPU provides instructions to operate on this data. This instruction set has the same purpose as instructions for integer data, including:

- Data transfer instructions
- Logical instructions
- Comparison instructions
- And others, like transcendental instructions, integer/floating-point conversion instructions, and so on

In the next sections, we will take a look at some of these instructions. Of course, we will not cover all the instructions supported by the modern CPUs. For more information, read the Intel [Software Developer Manual](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html).

The calling convention for floating-point numbers is different. If a function parameter is a floating-point number, it is passed in one of the `XMM` registers - the first argument is passed in the `xmm0` register, the second argument in the `xmm1` register, and so on up to `xmm7`. The rest of the arguments are passed on the [stack](./asm_3.md). The value of the functions that return a floating-point value is stored in the `xmm0` register.

### Data transfer instructions

As we know from the [Data manipulation](./asm_4.md) chapter, data transfer instructions are used to move data between different locations. The `x86_64` CPU provides a special set of instructions to transfer floating-point data. If you are going to use the `x87 FPU` unit, the most common data transfer instructions are:

- `fld` - Loads a floating point value.
- `fst` - Stores a floating point value.

These instructions are used by the `x87 FPU` unit to store and load the floating-point numbers at/from the stack.

To work with the `XMM` registers, the `x86_64` CPU supports, among others, the following data transfer instructions:

- `movss` - Moves a single-precision floating-point value between the `XMM` registers or between an `XMM` register and memory.
- `movsd` - Moves double-precision floating-point value between the `XMM` registers or between an `XMM` register and memory.
- `movhlps` - Moves two-packed single-precision floating-point values from the high quadword of an `XMM` register to the low quadword of another `XMM` register.
- `movlhps` - Moves two-packed single-precision floating-point values from the low quadword of an `XMM` register to the high quadword of another `XMM` register.

### Floating-point arithmetic instructions

The floating-point arithmetic instructions perform arithmetic operations, such as addition, subtraction, multiplication, and division, on single or double-precision floating-point values. The following floating-point arithmetic instructions exist:

- `addss` - Adds a single-precision floating-point values.
- `addsd` - Adds a double-precision floating point values.
- `subss` - Subtracts a single-precision floating-point values.
- `subsd` - Subtracts a double-precision floating-point values.
- `mulss` - Multiplies a single-precision floating-point values.
- `mulsd` - Multiplies a double-precision floating-point values.
- `divss` - Divides a single-precision floating-point values.
- `divsd` - Divides a double-precision floating-point values.

All of these instructions expect two operands to execute the given operation of addition, subtraction, multiplication, or division. After the operation is executed, the result is stored in the first operand.

### Floating-Point control instructions

As we already know, the main goal of these instructions is to manage the control flow of our programs. For integer comparisons, we used the `cmp` instruction. But this instruction does not work with floating-point values, even though the result of the comparison is controlled by the same `rflags` registers that we saw in the [Data manipulation](./asm_4.md#control-transfer-instructions) chapter. The general instruction to compare floating-point numbers is `cmpss`. Instead of setting the value of the flag based on the result comparison, the instruction stores the result of the comparison in the destination register.

For example:

```assembly
;; Compare xmm0 < xmm1 and store the result in the xmm0
cmpss xmm0, xmm1, 0x1
```

The third operand of the instruction, identifies the operator:

| 3rd operand value | Meaning                                                                |
|-------------------|------------------------------------------------------------------------|
|                 0 | ==                                                                     |
|                 1 | <                                                                      |
|                 2 | <=                                                                     |
|                 3 | Check that one of operands is [Nan](https://en.wikipedia.org/wiki/NaN) |
|                 4 | !=                                                                     |
|                 5 | >=                                                                     |
|                 6 | >                                                                      |
|                 7 | Checks that both operands are [Nan](https://en.wikipedia.org/wiki/NaN) |

## Example

After we got familiar with the basics of the new topic, it's time to write some code. This time, we will try to write a program which reads the user input, builds two [vectors](https://en.wikipedia.org/wiki/Vector_(mathematics_and_physics)) of floating-point numbers based on it, and calculates the [dot product](https://en.wikipedia.org/wiki/Dot_product) of these two vectors. This operation is widely used in machine learning. It will be interesting to try to implement it using the assembly programming language.

As a reminder – a dot product is an operation on two vectors (with $$a = [a_{1}, a_{2}, \cdots, a_{n}]$$ and $$b = [b_{1}, b_{2}, \cdots, b_{n}]$$), which produces a single value defined as the sum of the products of corresponding entries from the two vectors:

$$
a \times b = \sum_{i = 1}^{n} a_{i} \times b_{i} = a_{1} \times b_{1} + a_{2} \times b_{2} + \cdots + a_{n} \times b_{n}
$$

The values of both vectors are taken from the user input. Our program will ask the user to specify the components of the first vector represented by floating-point numbers split by spaces. After that, the program will ask to specify components of the second vector in the same format. Finally, we will calculate the dot product of the given vectors and print the result.

Let's start.

### Definition of constants and variables

First of all, we will start as usual - from the definition of data that we will use during our program lifetime. Let's take a look:

```assembly
;; Definition of the .data section
section .data
        ;; Number of the `sys_read` system call.
        SYS_READ equ 0
        ;; Number of the `sys_write` system call.
        SYS_WRITE equ 1
        ;; Number of the `sys_exit` system call.
        SYS_EXIT equ 60
        ;; Number of the standard input file descriptor.
        STD_IN equ 0
        ;; Number of the standard output file descriptor.
        STD_OUT equ 1
        ;; Exit code from the program. The 0 status code is a success.
        EXIT_CODE equ 0
        ;; Maximum number of elements in a vector
        MAX_ELEMS equ 100
        ;; Buffer size that we will use to read vectors.
        BUFFER_SIZE equ 1024
        ;; Prompt for the first vector
        FIRST_INPUT_MSG: db "Input the first vector: "
        ;; Length of the prompt for the first vector
        FIRST_INPUT_MSG_LEN equ 24
        ;; Prompt for the second vector
        SECOND_INPUT_MSG: db "Input the second vector: "
        ;; Length of the prompt for the second vector
        SECOND_INPUT_MSG_LEN equ 25
        ;; Error message to print if the number of items in the vectors is not the same.
        ERROR_MSG: db "Error: the number of values in vectors should be the same", 0xA, 0
        ;; Length of the error message.
        ERROR_MSG_LEN equ 59
        ;; Format string for the result
        PRINTF_FORMAT: db "Dot product = %f", 0xA, 0
```

This is similar to what we defined in our previous programs, but with some differences. First, we will use not only the [sys_write](https://man7.org/linux/man-pages/man2/write.2.html) and [sys_exit](https://man7.org/linux/man-pages/man2/_exit.2.html) system calls, but also [sys_read](https://man7.org/linux/man-pages/man2/read.2.html). We do this because we are going to read user input to build our vectors. Besides the system call identifiers, in the `.data` section definition, we can also see:

- The prompt messages used when asking a user to input data for vectors
- The error message to print
- Parameters of the buffer used to store the user input

After defining the data that we may initialize, we need to define uninitialized variables:

```assembly
;; Definition of the .bss section
section .bss
        ;; Buffer to store double values of the first vector
        vector_1: resq MAX_ELEMS
        ;; Buffer to store double values of the second vector
        vector_2: resq MAX_ELEMS

        ;; Buffer to store input for the first vector
        buffer_1: resq BUFFER_SIZE
        ;; Pointer within the `buffer_1` which points to the current position
        ;; that we use to parse floating point numbers
        end_buffer_1: resq 1

        ;; Buffer to store input for the second vector
        buffer_2: resq BUFFER_SIZE
        ;; Pointer within the `buffer_2` which points to the current position
        ;; that we use to parse floating point numbers
        end_buffer_2: resq 1
```

In the `.bss` section, we define:

- Two buffers for the vectors
- Two buffers for the user input
- Two pointers to the current position within the buffers with the user input

The last parameter here is the most interesting. To simplify our job, we will use the functions from the [C standard library](https://en.wikipedia.org/wiki/C_standard_library). One of such functions is [strtod](https://man7.org/linux/man-pages/man3/strtod.3.html), which converts the given string to a floating point number. It takes two parameters:

- Input string which should be converted to a floating point number
- The pointer that will point to the first character after the parsed number within the string specified by the parameter above

The `end_buffer_1` and `end_buffer_2` are such pointers that will be used in the `strtod`.

### Printing a user prompt and reading the user data

After we defined the data needed to build our program, we can start with the definition of the `.text` section which will store the code of our program:

```assembly
;; Definition of the .text section
section .text
        ;; Reference to the C stdlib functions that we will use
        extern strtod, printf
        ;; Reference to the entry point of our program.
        global _start

;; Entry point of the program.
_start:
        ;; Jump to the _read_first_float_vector label
        jmp _read_first_float_vector
```

The definition of the `.text` section starts from referencing the external functions: `strtod` and `printf`. As mentioned above, these functions are part of the C standard library, and we will use them to simplify our program. After defining the entry point, we immediately jump to the `_read_first_float_vector` label. This is where our code starts.

Our main goal now is to print the prompt, which will ask a user to type some floating-point values. We will then convert these values from strings to floating-point numbers and store them in a buffer representing our first vector. Let's take a look at the code:

```assembly
;; Read the first input string with floating-point values
_read_first_float_vector:
        ;; Set the length of the prompt string to print.
        mov rdx, FIRST_INPUT_MSG_LEN
        ;; Specify the system call number (1 is `sys_write`).
        mov rax, SYS_WRITE
        ;; Set the first argument of `sys_write` to 1 (`stdout`).
        mov rdi, STD_OUT
        ;; Set the second argument of `sys_write` to the reference of the prompt string to print.
        mov rsi, FIRST_INPUT_MSG
        ;; Call the `sys_write` system call.
        syscall

        ;; Set the length of the string we want to read from the standard input.
        mov rdx, BUFFER_SIZE
        ;; Specify the system call number (0 is `sys_read`)
        mov rdi, SYS_READ
        ;; Set the first argument of `sys_read` to 0 (`stdin`)
        mov rax, STD_IN
        ;; Set the second argument of `sys_read` to the reference of the buffer where we will
        ;; read the data for the vector.
        mov rsi, buffer_1
        ;; Call the `sys_read` system call.
        syscall

        ;; Save the number of bytes we have read from the standard input in the rcx register.
        mov rcx, rax
        ;; Set the pointer to the beginning of the buffer with the input data to the rdx register.
        mov rdx, buffer_1
        ;; Move the pointer within the buffer to the end of input.
        add rdx, rcx
        ;; Fill the last byte of the input with 0.
        mov byte [rdx], 0
```

As usual, the code starts from the `sys_write` system call. We use it to write a prompt string `Input the first vector: ` to the terminal. After this line is printed, we execute the `sys_read` system call to read the user input. If we take a look at the definition of this system call, we will see that it expects three arguments:

```C
ssize_t read(int fd, void buf[.count], size_t count);
```

The parameters are:

- A file descriptor that identifies the file from which we want to read the data
- The buffer where the data that we have read will be stored
- Number of bytes that we want to read

As you can see, we specify all these parameters before calling `sys_read` according to the **calling conventions** specified in the [System V Application Binary Interface](https://refspecs.linuxbase.org/elf/x86_64-abi-0.99.pdf). If this sounds unfamiliar, read the linked document or go back to the [second chapter](./asm_2.md) of this assembler course.

After executing the code, the buffer specified by the `buffer_1` name will contain the user input. The next goal is to convert each value represented by the string from the input to floating-point values and store them in a separate buffer. But before, we need to do one more thing.

The user input contains the `newline` symbol at the end. We don't need it in our input, as we can't convert it to a floating-point number. To get rid of this symbol, we replace it with the `0` byte. To do that, we need to know the length of the user input. The good news is that we already know it. Take a look at the documentation of the `sys_read` system call:

> On success, the number of bytes read is returned

As you may remember, the return value of a system call is stored in the `rax` register. To write the zero byte into the buffer right after the user input, we just need to take the pointer to the beginning of this buffer, add an offset to it (which is equal to the length of the user input), and add the `0` byte to this address. All of these you can see in the last four lines of the code above.

Now we have a buffer with the string values suitable for converting them into floating point numbers. We will see how to do it in the next section!

### Conversion of a string to a floating-point value

At this point, we have the memory buffer `buffer_1` which contains the user input. The user input represents a string with the floating-point values separated by spaces. Now we need to take each value from the buffer, convert it to a floating-point number, and store it in the buffer that represents our vector. Let's take a look at the code:

```assembly
        ;; Reset the value of the r14 register to store the number of floating-point numbers
        ;; from the first vector.
        xor r14, r14
        ;; Set the pointer to the beginning of the buffer with the input data to the rdx register.
        mov rdi, buffer_1
;; Parse the floating-point values from the input buffer.
_parse_first_float_vector:
        ;; Initialize the rsi register with the pointer which points to the place where
        ;; the strtod(3) will finish its work.
        mov rsi, end_buffer_1
        ;; Call the strtod(3) to convert a floating-point value from the input buffer to double representation.
        call strtod
        ;; Preserve the pointer to the next floating-point value from the input buffer
        ;; in the rax register.
        mov rax, [end_buffer_1]
        ;; Check whether it is the end of the input string.
        cmp rax, rdi
        ;; Proceed with the second vector if we reached the end of the first vector.
        je _read_second_float_vector
        ;; Store the reference to the beginning of the buffer where we will store
        ;; our double values to the rdx register.
        mov rdx, vector_1
        ;; Store the number of floating-point values we already have read in the rcx register.
        mov rcx, r14
        ;; Multiply the number of floating-point values by 8.
        shl rcx, 3
        ;; Move the pointer from the beginning of the buffer with floating-point values that
        ;; we parsed from the input string to the next value.
        add rdx, rcx
        ;; Store the next floating-point value in the buffer.
        movq [rdx], xmm0
        ;; Increase the number of floating-point values that we already parsed.
        inc r14
        ;; Move the pointer within the input buffer to the next floating-point value.
        mov rdi, rax
        ;; Continue to parse floating-point values from the input string.
        jmp _parse_first_float_vector
```

The code starts by setting the `r14` register to `0`. This register contains the initial number of floating-point values from the user input. Then, we put the address of the user input buffer into the `rdi` register. This will be the first argument of the `strtod` function that will convert the first floating-point value from the buffer. Next, we prepare the second argument of the `strtod` function by storing a pointer to the first character after the parsed number in the `rsi` register. With both parameters of the `strtod` function ready, we can now call it.

After this function is executed, we need to check if we reached the end of the string. We can do it by comparing both pointers that we passed to the `strtod` function. If they are equal, we reached the end of the string, and we can move to parsing the data for the second vector. If not, we need to put the parsed floating-point number into the vector buffer.

To do this, we store in the `rdx` register the address of the next location within the vector buffer where the parsed floating-point value should be placed. Once we have this address, we can write the floating-point value into this location. The value is stored in the `xmm0` register because the `strtod` function returns the double value, and according to the calling conventions, return values of this type are placed in this register.

After writing the floating-point number to the vector buffer, we need to repeat this operation until we reach the end of the user input string.

As soon as we finish parsing the floating-point values for the first vector, we need to repeat it for the second. I will not include the code here, as it is almost identical to the snippet above, with only two differences:

- To parse data for the second vector, we will use separate buffers - `buffer_2`, `end_buffer_2`, and `vector_2`. 
- To store the number of values within the second vector, we will use the `r15` register instead of `r14`.

> [!TIP]
> For reference, you can find the whole code [here](https://github.com/0xAX/asm/blob/master/float/dot_product.asm).

### Calculation of the dot product

Now we have two buffers with floating-point numbers - `vector_1` and `vector_2`. This is all we need to calculate the dot product of two vectors. Let's do it!

```assembly
;; Prepare to calculate the dot product of the two vectors.
_calculate_dot_product:
        ;; Check if the number of items in our vectors is equal.
        test r14, r15
        ;; Print an error and exit if not.
        jle _error

        ;; Set the address of the first vector to the rdi register.
        mov rdi, vector_1
        ;; Set the address of the second vector to the rsi register.
        mov rsi, vector_2
        ;; Set the number of values within the vectors to the rdx register.
        mov rdx, r14
        ;; Calculate the dot product of the two vectors.
        call _dot_product
```

Before calculating the dot product of two vectors, we must be sure that both vectors have the same number of components. The number of components of the first vector is stored in the `r14` register, and the number of components of the second vector is stored in the `r15` register. Let’s check if these values are equal; if not, we will print an error message and exit the program. The error-printing and program exit process should already be familiar to you:

```assembly
;; Print an error and exit.
_error:
        ;; Set the length of the prompt string to print.
        mov rdx, ERROR_MSG_LEN
        ;; Specify the system call number (1 is `sys_write`).
        mov rax, SYS_WRITE
        ;; Set the first argument of `sys_write` to 1 (`stdout`).
        mov rdi, STD_OUT
        ;; Set the second argument of `sys_write` to the reference of the prompt string to print.
        mov rsi, ERROR_MSG
        ;; Call the `sys_write` system call.
        syscall
        ;; Exit from the program
        jmp _exit

;; Exit from the program.
_exit:
    ;; Specify the number of the system call (60 is `sys_exit`).
    mov rax, SYS_EXIT
    ;; Set the first argument of `sys_exit` to 0. The 0 status code is success.
    mov rdi, EXIT_CODE
    ;; Call the `sys_exit` system call.
    syscall
```

If both vectors have the same number of components, we can proceed to the calculation. To do that, we store the addresses of both vectors in the `rdi` and `rsi` registers, and put the number of components within the vectors into the `rdx` register. The `_dot_product` function does the main job. Let's take a look at the code of this function:

```assembly
;; Calculate the dot product of the two vectors.
_dot_product:
        ;; Reset the value of the rax register to 0.
        xor rax, rax
        ;; Reset the value of the xmm1 register to 0.
        pxor xmm1, xmm1
        ;; Current rdx contains the number of floating-point values within the vectors.
        ;; Multiply it by 8 using shift left operation to get the number of bytes 
        ;; occupied by these values.
        sal rdx, 3
;; Calculate the the dot product in the loop.
_loop:
        ;; Move the floating-point value from the first vector to the xmm0 register.
        movsd xmm0, [rdi + rax]
        ;; Multiply the floating-point value from the second vector by the value from the first vector
        ;; and store the result in the xmm0 register.
        mulsd xmm0, [rsi + rax]
        ;; Move to the next floating-point values in the vector buffers.
        add rax, 8
        ;; Add the result of multiplying the floating-point values from the two vectors into the xmm1 register.
        addsd xmm1, xmm0
        ;; Check if we went through all the floating-point values in the vector buffers.
        cmp rax, rdx
        ;; If not, repeat the loop.
        jne _loop
        ;; Move the result to the xmm0 register.
        movapd xmm0, xmm1
        ;; Return from the `_dot_product` back to the `_calculate_dot_product`.
        ret
```

At the beginning of the function, we prepare the `rax` and `xmm1` registers by resetting them to zero. The `rax` register will contain the offset within the vector buffers, and the `xmm1` register will accumulate the result of our program. The number of floating-point values within the vectors is stored in the `rdx` register. Since we will move the pointer within the buffers, we need to know how many bytes occupied by these values. To do this we multiple the value of the `rdx` register by `8`. To do this we use the `sal` instruction which executes [arithmetic left shift](https://en.wikipedia.org/wiki/Arithmetic_shift) on the given operand.

The dot product calculation takes place inside the loop labeled `_loop`. In the first instruction of this label, we put the current value from the first vector into the `xmm0` register. Next, we multiply this value by the current value from the second vector. The two vectors are pointed by the `rdi` and `rsi` registers, and the `rax` register stores the offset within these buffers that points to the current value we need to process. After performing the multiplication, we increase the value of the `rax` to eight bytes to move to the next values within the vector buffers. At the same time, we update our accumulator with the intermediate result of the dot product.

At this point, the `xmm1` register stores the multiplication result of the first components of our vectors. Now we must check if we reached the end of vectors; if not, we repeat the loop for the second component, third, and so on. As soon as we reach the end of the vectors, we put the result into the `xmm0` register and return from the `_dot_product` function.

Our result is ready 🎉 🎉 🎉 The last thing to do is to print it. We will do it using the [printf](https://man7.org/linux/man-pages/man3/printf.3.html) function to simplify our program:

```assembly
        ;; Specify a reference to the format string for the printf(3) in the rdi register.
        mov rdi, PRINTF_FORMAT
        ;; Number of the floating-point registers passed to printf(3). 
        ;; We specify `1` because we need to pass only `xmm0` with the result of the program.
        mov rax, 1
        ;; Call the printf(3) function that will print the result.
        call printf

        ;; Exit from the program.
        jmp _exit
```

Now, let's build our program with the usual commands:

```bash
$ nasm -g -f elf64 -o dot_product.o dot_product.asm
$ ld -dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc dot_product.o -o dot_product
```

Then, let's run it:

```
$ ./dot_product 
Input the first vector: 2.5 3.17
Input the second vector: 4.22 100.1
Dot product = 327.867000
```

Works as expected 🎉🎉🎉

## Conclusion

In this chapter, we have seen how to work with floating-point data and got familiar with more assembly instructions. Of course, this post didn't cover all the details related to this topic.

For more information about floating-point representation and operations on such data, go to the [Intel manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html).
