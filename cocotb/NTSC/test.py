import cocotb
import struct
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

@cocotb.test()
async def test_ntsc(dut):
	dut._log.info("start")
	dut.RESETn.value = 0
	dut.color_enable.value = 0
	c = Clock(dut.clk, 69842, "ps")
	cocotb.start_soon(c.start())
	await ClockCycles(dut.clk, 3)
	dut.RESETn.value = 1
	await ClockCycles(dut.clk, 1000000)
