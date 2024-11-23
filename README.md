![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Large ternary dot product (synaptic tree in a silicon neuron)

Goal of this project is to measure and analyse the scaling of the silicon area needed for large ternary dot product area.
This is part of a larger work to explore various architectures for Neural Networks on Chip.

For more information read the [documentation](docs/info.md).

### Ternary dot product

$$y=\sum_{i=1}^{N} {\color{Red} A_{i}}\times {\color{Green} B_{i}},
\quad
{\color{Red} A } \in -1, 0, 1
\quad
{\color{Green} B } \in 0, 1 $$

**128** element dot-product is computed **each cycle**. At a nominal frequency of **50 MHz** this design achieves a performance of `6.4 Giga OP/s`.


### Silicon area

| Vector size | Adder tree depth | Output type | # of logic cells | Wire length | Dimensions | Area | Tiles |
|-------------|------------------|-------------|------------------|-------------|------------|------|-------|
| 1       | - | 2-bit signed |    2|   215 um|  ~ 18 x 11 um |  198 um<sup>2</sup> | 0.9%|  
| 2       | 1 | 3-bit signed |   10|   395 um|  ~ 45 x 8 um  |  360 um<sup>2</sup> | 1.6%| 
| 4       | 2 | 4-bit signed |   31|   757 um|  ~ 60 x 11 um |  660 um<sup>2</sup> | 3.8%|
||||||||
| 32      | 5 | 7-bit signed |  336|  9982 um| ~ 112 x 70 um | 7840 um<sup>2</sup> | 36%|
| 64      | 6 | 8-bit signed |  737| 23329 um| ~ 160 x 86 um |13760 um<sup>2</sup> | 75%|
| 128*    | 7 | 9-bit signed | 1472| 59822 um| ~ 112 x 200 um|22400 um<sup>2</sup> | **143%**|
| 256     | 8 |10-bit signed | 2941|151707 um| ~ 320 x 112 um|35840 um<sup>2</sup> | 269%|

*) *Version taped out with TinyTapeout 10*

# How to test?
Read the project's [documentation](docs/info.md).

# What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and cheaper than ever to get your digital and analog designs manufactured on a real chip.

To learn more and get started, visit https://tinytapeout.com.

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
