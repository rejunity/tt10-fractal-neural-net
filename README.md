![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Large (128 element) ternary dot product (synaptic tree in a silicon neuron)

Goal of this project is to measure and analyse the scaling of the silicon area needed for large ternary dot product area.
This is part of a larger work to explore various architectures for Neural Networks on Chip.

For more information read the [documentation](docs/info.md).

### Ternary dot product

$$y=\sum_{i=1}^{N} {\color{Red} A_{i}}\times {\color{Green} B_{i}},
\quad
{\color{Red} A } \in -1, 0, 1
\quad
{\color{Green} B } \in 0, 1 $$

### Performance

**128** element dot-product is computed **each cycle**. At a nominal ASIC frequency of **50 MHz** this design achieves a performance of `6.4 Giga OP/s`.

### Silicon area

| Vector size | Adder tree depth | Output type | # of logic cells | Total # of cells | Wire length (um) | Dimensions (um) | Area (um<sup>2</sup>) | Tiles |
|-------------|------------------|-------------|------------------|------------------|-------------|------------|------|-------|
| 1       | - | 2-bit signed |    2|  32|  215|  18 x 11 |  198 um<sup>2</sup> | 0.9%|  
| 2       | 1 | 3-bit signed |   10|  44|  395|  45 x 8  |  360 um<sup>2</sup> | 1.6%| 
| 4       | 2 | 4-bit signed |   31|  77|  757|  60 x 11 |  660 um<sup>2</sup> | 3.8%|
||||||||
| 32      | 5 | 7-bit signed |  336| 508|  9982| 112 x 70 | 7840 um<sup>2</sup> | 36%|
| 64      | 6 | 8-bit signed |  737|1073| 23329| 160 x 86 |13760 um<sup>2</sup> | 75%|
| 128*    | 7 | 9-bit signed | 1472|2121| 59822| 112 x 200|**22400 um<sup>2</sup>** | **143%**|
| 256     | 8 |10-bit signed | 2941|4207|151707| 320 x 112|35840 um<sup>2</sup> | 269%|

*) *Version taped out with TinyTapeout 10*


### Comparison betweeen adder-tree versions

| Type                              | Tiles | Wire length (um) | Setup Worst Slack | Setup Slack (Typical) | fMax |
|-----------------------------------|-------|------------------|-------------------|---------|-|
| Naive `v[0]+v[1]+v[2]+ ...`   | 38.395 % | 12040 |	7.3ns |	13.48ns | 153 MHz |
| Adder tree                        |	38.466 % | 11425 | 7.3ns  | 13.45ns | 152 MHz |
| Logic, carry save adder           | 38.136 % | 10931 | 6.9ns  | 13.41ns | 151 MHz |
| **HA/FA cells**, carry save adder | 28.712 % | 9164  | **3.5ns** | 12.24ns | **129 MHz** |

Note that there is no significant area difference between various approaches **unless** sky130 [HA/FA cells](https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_sc_hd/cells/fa/README.html) are used!


### Physical layout for a 128 element dot product
![128synapses_1x2tiles_layout](https://github.com/user-attachments/assets/992c77d7-3006-492a-9d75-d1a13e4c0221)
_Left:_ **blue cells** - compute, **white cells** - ternary vector storage \
_Right:_ **wires** connecting cells

### Physical layout for a 32 element dot product
![32synapses_1tile_layout](https://github.com/user-attachments/assets/ecb97759-9543-4f86-af8d-4a06ad97a2fc)
**blue cells** - compute, **white cells** - ternary vector storage

# How to test?
Read the project's [documentation](docs/info.md).

# What is Tiny Tapeout?

Tiny Tapeout is an educational project that aims to make it easier and cheaper than ever to get your digital and analog designs manufactured on a real chip.

To learn more and get started, visit https://tinytapeout.com.

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
