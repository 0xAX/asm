# Floating-point arithmetic

In the previous chapters, we have written a simple assembly programs which were operating with numeric and string-like data. All the numeric data that we have used was only integer numbers. This is not always practical and map the reality. Integer numbers does not allow us to represent fractional number values. In this chapter we will look how to operate with the  [floating-point numbers](https://en.wikipedia.org/wiki/Floating-point_arithmetic) in our programs.

## Floating-point representation

First of all, let's take a look how floating-point numbers are represented in memory. There are three floating point data types:

- single-precision
- double-precision
- double-extended precision

The Intel [Software Developer Manual](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html) says:

> The data formats for these data types correspond directly to formats specified in the IEEE Standard 754 for Binary Floating-Point Arithmetic.

To get all the possible details about representation of the floating-point numbers in computer memory, you should take a look at this standard.

All of these formats differ in accuracy. The single-precision and double-precision formats correspond to the [C's](https://en.wikipedia.org/wiki/C_(programming_language)) [float and double](https://cppreference.com/w/c/language/arithmetic_types.html) data types. The double-extended precision format corresponds to the C's `long double` data type.  Let's take a look at each of them.

### Single-precision format

To represent a floating-point number using the single-precision format, the number is split on the three parts:

- sign - 1 bit
- exponent - 8 bits
- mantissa - 23 bits

The sign bit provides information about the `sign` of the number. If this bit is set to `0` - the number is positive, and negative otherwise. While what is `sign` could be clear, on what is `exponent` and `mantissa` we need to stop and consider them in a more detailed way. To understand how floating-point numbers are presented in memory, we need to know how to convert the floating-point number from the [decimal](https://en.wikipedia.org/wiki/Decimal) to [binary](https://en.wikipedia.org/wiki/Binary_number) representation.

Let's take a random floating-point number, for example - `5.625`. To convert a floating-point number to a binary representation we need to split our number on integral and fractional parts. In our case it is `2` and `625`. To convert the integral part of our number to binary representation, we need to divide our number by `2` repeatably while the result will not be zero. Let's take a look:

| Division | Quotient | Remainder |
|----------|----------|-----------|
| 5 % 2    |        2 |         1 |
| 2 % 2    |        1 |         0 |
| 1 % 2    |        0 |         1 |

To get the binary representation, we just need to write down remainders. So `5` in binary is `101`.

To convert fractional part of our floating-point number, we need multiple our number by `2` while the integral part will not be equal to one. Let's try to convert the fractional part of our number:

| Multiplication | Result | Integral part | Fractional part |
|----------------|--------|---------------|-----------------|
|      0.625 * 2 |   1.25 |             1 |            0.25 |
|       0.25 * 2 |    0.5 |             0 |             0.5 |
|        0.5 * 2 |      1 |             1 |               0 |

To get the binary representation, we just need to write down integral parts that we got during calculations. So `0.625` in binary is `0.101`. As the result - our floating point number represented in binary form is `5.625 = 101.101`.

If you will start to train to convert decimal floating-point numbers to binary system, you may note one interesting pattern very soon. Not all the fractional parts can be converted to binary. For example, let's take a look at the binary representation of the fractional part of the number `5.575`:

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

We may see that starting from the step `5` (or first four bits `1001`), the pattern `0011` repeats forever. Such repeatable part we will write down in brackets. So for example, the number `5.575` we will write in binary form as `101.1001(0011)`. The interesting fact - if we will try to convert this binary number back to decimal representation, we will end up with slight different number than our original number. That's why every floating-point number in a computer is just an approximation of the original value. Because of this you may now understand the well known example - let's try to ask [Python](https://www.python.org/) to do the simple compilation:

```
>>> 0.1 + 0.2
0.30000000000000004

# Or

>>> 0.2 + 0.4
0.6000000000000001
```

After we converted both integral and fractional parts of our number to binary representation, we can go to the next step. We need to convert to [scientific notation](https://en.wikipedia.org/wiki/Scientific_notation). The first part we need to [shift right](https://en.wikipedia.org/wiki/Logical_shift) the integral part of our number so that only `1` will remain. In a case of our number `101` - we need to shift right the number 2 times. As the result our initial number `101.101` started to be represented as `1.01101 * 2^2`. After this we need to add the number of shifts we done to the special number called - `bias`. For single-precision floating-point numbers it is equal to `127`. So we will get - `2 + 127 = 129` or `0b10000001`. This will be our `exponent`. The `mantissa` is just the fractional part of the number that we got after shifting it. We just put all the number of the fractional parts to the 23 `mantissa` bits.

If we will combine all together, we may see how our number `5.625` will be represented in a computer memory:

| Sign | Exponent | Mantissa                |
|------|----------|-------------------------|
|     0| 10000001 | 01101000000000000000000 |

If the fractional part of the number is periodic as we have seen with the example of the number `5.575` - we will fill the `mantissa` bits while it is possible. So the number `5.575` will be represented in a computer memory as:

| Sign | Exponent | Mantissa                |
|------|----------|-------------------------|
|     0| 10000001 | 01100100110011001100110 |

Now we know how computer represents a floating point number with a single-precision 🎉 

### Double and double-extended precision formats

As you may guess, the representation of the floating-point numbers using the double-precision and double-extended precision formats is similar to the single-precision format and the difference is only accuracy.

The double-precision format is `64-bits` of memory with the following structure:

- sign - 1 bit
- exponent - 11 bit
- mantissa - 52 bit

The extended-double precision format is `80-bits` of memory with the following structure:

- sign - 1 bit
- exponent - 15 bit
- mantissa - 112 bit

The `bias` for the double-precision format is `1023`. The `bias` for the extended-double precision is `16383`.

## Floating-point instructions

As I mentioned in the beginning of this chapter, before this point we were writing our assembly programs which were operating only with integer numbers. We have used the `general-purpose` registers to store them and instructions like `add`, `sub`, `mul`, and so on to do basic arithmetic on them. We can not use these registers and instructions to operate with the floating-point numbers. Happily, `x86_64` CPU provides special registers and instructions to operate with such numbers. The name of these registers is `XMM` registers.

There are 16 `XMM` registers named `xmm0` through `xmm15`. These registers are `128-bits`. At this point, the question might raised in your head - if we have `32-bits` and `64-bits` floating point numbers why we have `128-bit` registers? The answer is that these registers were introduced as part of the [SIMD](https://en.wikipedia.org/wiki/Single_instruction,_multiple_data) extensions instructions set. These instructions set allows to operate on `packed` data. This allows you to execute a single instruction on four `32-bits` floating point numbers for example.

In addition to the sixteen `xmm` register, each `x86_64` CPU includes a "legacy" floating-point unit named [x87 FPU](https://en.wikipedia.org/wiki/X87). It is built as an eight-deep register stack. Each of those stack slots may hold an `80-bits` extended-precision number.

Besides the storage for data, the CPU obviously provides instructions to operate on this data. The instructions set have the same purpose as instructions for integer data:

- Data transfer instructions
- Logical instructions
- Comparison instructions
- And others, like transcendental instructions, integer/floating-point conversion instructions, and so on

In the next sections we will take a look at some of these instructions. Of course, we will not cover all the instructions supported by the modern CPUs. For more information, read the Intel [Software Developer Manual](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html).

The calling conventions for floating-point numbers is different. If a function parameter is a floating-point number - it will be passed in one of `XMM` registers - the first argument will be passed in the `xmm0` register, the second argument will be passed in `xmm1` register and so on up till `xmm7`. The rest of arguments after eights argument are passed on the [stack](./asm_3.md).

### Data transfer instructions

As we know from the [4th part](./asm_4.md) - data transfer instructions are used to move data between different locations. `x86_64` CPU provides special set of instructions for transfer of floating point data. If you are going to use the `x87 FPU` unit, one of the most common data transfer instructions are:

- `fld` - Load floating point value.
- `fst` - Store floating point value.

These instructions are used by the `x87 FPU` unit to store and load the floating-point numbers at/from the stack.

To work with `XMM` registers, the following data transfer instructions are supported by an `x86_64` CPU:

- `movss` - Move single-precision floating-point value between the `XMM` registers or between an `XMM` register and memory,
- `movsd` - Move double-precision floating-point value between the `XMM` registers or between an `XMM` register and memory.
- `movhlps` - Move two packed single-precision floating-point values from the high quadword of an `XMM` register to the low quadword of another `XMM` register.
- `movlhps` - Move two packed single-precision floating-point values from the low quadword of an `XMM` register to the high quadword of another `XMM` register.
- And others.

### Floating-point arithmetic instructions

The floating-point arithmetic instructions perform arithmetic operations such as add, subtract, multiplication, and division on single or double precision floating-point values. The following floating-point arithmetic instructions exist:

- `addss` - Add single-precision floating-point values.
- `addsd` - Add dobule-precision floating point values.
- `subss` - Subtract single-precision floating-point values.
- `subsd` - Subtract double-precision floating-point values.
- `mulss` - Multiply single-precision floating-point values.
- `mulsd` - Multiply double-precision floating-point values.
- `divss` - Divide single-precision floating-point values. 
- `divsd` - Divide double-precision floating-point values.

All of these instructions expects two operands to execute the given operation of addition, subtraction, multiplication, or division. After the operation will be executed, the result will be stored in the first operand.

### Floating-Point control instructions

As we already know, the main goal of this type of instructions is to manage the control flow of our programs. For the integer comparison we have seen the `cmp` instruction. But this instruction will not work with floating-point values. Although, the result of the comparison is controlled by the same `rflags` registers that we have seen in the [4th part](./asm_4.md#Control transfer instructions).

The general instruction to compare floating-point numbers is `cmpss`.

## Example

After we got familiar with some basics of the new topic - time to write some code.

TODO

## Conclusion

In this chapter, we have seen how to work with a floating-point data and got familiar with more assembly instructions. Of course, this small post didn't cover all the details related to this big topic.

For more information about floating-point representation and operations on such data, go to the [Intel manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html).
