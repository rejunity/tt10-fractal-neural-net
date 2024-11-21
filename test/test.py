# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


async def set_weights(dut, weights, n=32):
    for i in range(n):
        dut.ui_in.value = (weights & 2) >> 1
        await ClockCycles(dut.clk, 1)
        dut.ui_in.value = (weights & 1)
        await ClockCycles(dut.clk, 1)

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

    # N = 32 // 8
    N = 1

    dut.uio_in.value = 1

    await set_weights(dut, 0b00)
    await ClockCycles(dut.clk, 1)    
    assert dut.uo_out.value == N

    await set_weights(dut, 0b01)
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0

    await set_weights(dut, 0b10)
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0x100-N

    await set_weights(dut, 0b11)
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0


    dut.uio_in.value = 0

    await set_weights(dut, 0b00)
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0

    await set_weights(dut, 0b01)
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0

    await set_weights(dut, 0b10)
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0

    await set_weights(dut, 0b11)
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0


    dut.uio_in.value = 0b11

    await set_weights(dut, 0b00)
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 2*N

    await set_weights(dut, 0b01)
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0

    await set_weights(dut, 0b10)
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0x100-2*N


    def set_rightmost_bits(n):
        return (1 << n) - 1 # Generate a bitmask with the N rightmost bits set
    
    K = 4
    dut.uio_in.value = set_rightmost_bits(K)

    await set_weights(dut, 0b00)
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == K*N

    await set_weights(dut, 0b01)
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0

    await set_weights(dut, 0b10)
    await ClockCycles(dut.clk, 1)
    assert dut.uo_out.value == 0x100-K*N
