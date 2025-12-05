import cocotb
import struct
import os
import sys
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

@cocotb.test()
async def test_misc(dut):
	dut._log.info("start")
	dut.rst_n.value = 0
	c = Clock(dut.clk, 80, "ns")
	cocotb.start_soon(c.start())
	await ClockCycles(dut.clk, 5)
	dut.rst_n.value = 1
	await Timer(22, "ms")
