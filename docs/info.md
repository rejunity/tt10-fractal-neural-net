<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This is an experimental ASIC that computes dot-product between ternary `{-1,0,1}` and a binary `{0,1}` vectors with a length of 128 elements in 1 cycle!

Note this experiment is intended mainly to measure silicon area for a dot-product rather than for a practical use, therefore binary vector A is formed by repeating the same values multiple times.

```y = sum(A[i] * B[i])```

Binary vector `A` is not stored internally, but is formed by repeating values on the INPUT bus: `{ui_in[7], ui_in[6], ui_in[5], ui_in[4], ui_in[3], ui_in[2], ui_in[1], ui_in[0], ui_in[7] ... ui_in[0]}`

Ternary vector `B` is stored internally in a shift register and values are uploaded in a serial fashion via pins `uio_in[1]` and `uio_in[0]` on a BIDIRECTIONAL bus. Every cycle 2 bits are set and register is shifted by 2 bits.

| DEC representation | BIT representation | Ternary value |
|-----------|--------------|---------------|
| 0         |     00       |       1       |
| 1         |     01       |       0       |
| 2         |     10       |      -1       |
| 3         |     11       |       0       |

## How to test

128 element dot-product is computed every cycle.
1 element of the ternary vector B is uploaded every cycle.
Values of vector B are not stored in the register thus will change immediately.

Examples:
1) Set `ui_in = 0b1111_1111` and `uio_in = 0`. Wait for 128 cycles to update the whole ternary vector. On the next cycle expected value of `uo_out` is 128 * 1 = 0b1000_0000

2) Set `ui_in = 0b0000_1111` and `uio_in = 0`. Wait for 128 cycles to update the whole ternary vector. On the next cycle expected value of `uo_out` is 64 *  1 = 0b0100_0000

3) Set `ui_in = 0b0000_1111` and `uio_in = 2`. Wait for 128 cycles to update the whole ternary vector. On the next cycle expected value of `uo_out` is 64 * -1 = 0b1100_0000


## External hardware

No additional hardware needed.
