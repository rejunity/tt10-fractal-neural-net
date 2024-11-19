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

    # dut.nn_x.value = 1
    # dut.nn_w_zero.value = 0
    # dut.nn_w_sign.value = 0
    dut.ui_in.value = 0b001
    await ClockCycles(dut.clk, 2)
    assert dut.uo_out.value == 1

    # dut.nn_w_zero.value = 1
    # dut.nn_w_sign.value = 0
    dut.ui_in.value = 0b011
    await ClockCycles(dut.clk, 2)
    assert dut.uo_out.value == 0

    # dut.nn_w_zero.value = 0
    # dut.nn_w_sign.value = 1
    dut.ui_in.value = 0b101
    await ClockCycles(dut.clk, 2)
    assert dut.uo_out.value == 0b11

    # dut.nn_w_zero.value = 1
    # dut.nn_w_sign.value = 1
    dut.ui_in.value = 0b111
    await ClockCycles(dut.clk, 2)
    assert dut.uo_out.value == 0


    # dut.nn_x.value = 0
    # dut.nn_w_zero.value = 0
    # dut.nn_w_sign.value = 0
    dut.ui_in.value = 0b000
    await ClockCycles(dut.clk, 2)
    assert dut.uo_out.value == 0

    # dut.nn_w_zero.value = 1
    # dut.nn_w_sign.value = 0
    dut.ui_in.value = 0b010
    await ClockCycles(dut.clk, 2)
    assert dut.uo_out.value == 0

    # dut.nn_w_zero.value = 0
    # dut.nn_w_sign.value = 1
    dut.ui_in.value = 0b100
    await ClockCycles(dut.clk, 2)
    assert dut.uo_out.value == 0

    # dut.nn_w_zero.value = 1
    # dut.nn_w_sign.value = 1
    dut.ui_in.value = 0b110
    await ClockCycles(dut.clk, 2)
    assert dut.uo_out.value == 0
