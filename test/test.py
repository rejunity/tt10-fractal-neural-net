# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


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

    dut._log.info("Test project behavior")

    dut.uio_in.value = 1

    dut.ui_in.value = 0b00
    await ClockCycles(dut.clk, 2)
    assert dut.uo_out.value == 1

    dut.ui_in.value = 0b01
    await ClockCycles(dut.clk, 2)
    assert dut.uo_out.value == 0

    dut.ui_in.value = 0b10
    await ClockCycles(dut.clk, 2)
    assert dut.uo_out.value == -1 & 0b1111

    dut.ui_in.value = 0b11
    await ClockCycles(dut.clk, 2)
    assert dut.uo_out.value == 0


    dut.uio_in.value = 0

    dut.ui_in.value = 0b00
    await ClockCycles(dut.clk, 2)
    assert dut.uo_out.value == 0

    dut.ui_in.value = 0b01
    await ClockCycles(dut.clk, 2)
    assert dut.uo_out.value == 0

    dut.ui_in.value = 0b10
    await ClockCycles(dut.clk, 2)
    assert dut.uo_out.value == 0

    dut.ui_in.value = 0b11
    await ClockCycles(dut.clk, 2)
    assert dut.uo_out.value == 0


    # dut.uio_in.value = 0b11

    # dut.ui_in.value = 0b0000
    # await ClockCycles(dut.clk, 2)
    # assert dut.uo_out.value == 2

    # dut.ui_in.value = 0b1010
    # await ClockCycles(dut.clk, 2)
    # assert dut.uo_out.value == -2 & 0b1111

    # dut.ui_in.value = 0b0010
    # await ClockCycles(dut.clk, 2)
    # assert dut.uo_out.value == 0


