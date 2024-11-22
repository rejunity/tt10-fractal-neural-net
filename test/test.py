# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

N = 128
ND8 = N // 8

async def set_weights(dut, weights, n=N):
    for i in range(n):
        dut.uio_in.value = weights
        await ClockCycles(dut.clk, 1)

def get_output(dut):
    value = dut.out.value.integer
    value &= 0xFFFF  # Mask to 16 bits
    if value & 0x8000:
        value -= 0x10000
    return value

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # reset weights
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 128)

    dut._log.info("Test project behavior")

    dut.ui_in.value = 1

    await set_weights(dut, 0b00)
    await ClockCycles(dut.clk, 1)    
    assert get_output(dut) == ND8

    await set_weights(dut, 0b01)
    await ClockCycles(dut.clk, 1)
    assert get_output(dut) == 0

    await set_weights(dut, 0b10)
    await ClockCycles(dut.clk, 1)
    assert get_output(dut) == -ND8

    await set_weights(dut, 0b11)
    await ClockCycles(dut.clk, 1)
    assert get_output(dut) == 0


    dut.ui_in.value = 0

    await set_weights(dut, 0b00)
    await ClockCycles(dut.clk, 1)
    assert get_output(dut) == 0

    await set_weights(dut, 0b01)
    await ClockCycles(dut.clk, 1)
    assert get_output(dut) == 0

    await set_weights(dut, 0b10)
    await ClockCycles(dut.clk, 1)
    assert get_output(dut) == 0

    await set_weights(dut, 0b11)
    await ClockCycles(dut.clk, 1)
    assert get_output(dut) == 0


    dut.ui_in.value = 0b11

    await set_weights(dut, 0b00)
    await ClockCycles(dut.clk, 1)
    assert get_output(dut) == 2*ND8

    await set_weights(dut, 0b01)
    await ClockCycles(dut.clk, 1)
    assert get_output(dut) == 0

    await set_weights(dut, 0b10)
    await ClockCycles(dut.clk, 1)
    assert get_output(dut) == -2*ND8


    def set_rightmost_bits(n):
        return (1 << n) - 1 # Generate a bitmask with the N rightmost bits set
    
    K = 8
    dut.ui_in.value = set_rightmost_bits(K)

    await set_weights(dut, 0b00)
    await ClockCycles(dut.clk, 1)
    assert get_output(dut) == K*ND8

    await set_weights(dut, 0b01)
    await ClockCycles(dut.clk, 1)
    assert get_output(dut) == 0

    await set_weights(dut, 0b10)
    await ClockCycles(dut.clk, 1)
    assert get_output(dut) == -K*ND8
