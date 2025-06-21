# Floating-point arithmetic

In the previous chapters, we have written a simple assembly programs which were oprating with numeric and string-like data. All the numeric data that we have used was only integer numbers. This is not always practical and map the reality. Integer numbers does not allow us to represent fractional number values. In this chapter we will look how to operate with the  [floating-point numbers](https://en.wikipedia.org/wiki/Floating-point_arithmetic) in our programs.

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

After we converted both integral and fractional parts of our number to binary representation, we can go to the next step. We need to convert to [scientific notation](https://en.wikipedia.org/wiki/Scientific_notation).
