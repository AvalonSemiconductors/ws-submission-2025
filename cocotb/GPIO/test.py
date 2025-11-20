import cocotb
import struct
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

async def write_reg(dut, addr, value):
	dut.CEb.value = 0
	dut.WEb.value = 0
	dut.addr.value = addr
	dut.D_in.value = value
	await ClockCycles(dut.clk, 1)
	dut.CEb.value = 1
	dut.WEb.value = 1
	await ClockCycles(dut.clk, 1)

async def read_reg(dut, addr):
	dut.CEb.value = 0
	dut.OEb.value = 0
	dut.addr.value = addr
	await ClockCycles(dut.clk, 1)
	res = dut.D_out.value
	dut.CEb.value = 1
	dut.OEb.value = 1
	return res

@cocotb.test()
async def test_gpio(dut):
	dut._log.info("start")
	dut.RESETn.value = 0
	dut.D_in.value = 0
	dut.RXD.value = 1
	dut.SDI.value = 0
	dut.WEb.value = 1
	dut.OEb.value = 1
	c = Clock(dut.clk, 100, "ns")
	cocotb.start_soon(c.start())
	await ClockCycles(dut.clk, 3)
	dut.RESETn.value = 1
	await ClockCycles(dut.clk, 1)
	await write_reg(dut, 0, 255)
	await write_reg(dut, 1, 0)
	await write_reg(dut, 2, 0)
	await write_reg(dut, 3, 0)
	assert dut.PORTA.value == 0
	await write_reg(dut, 2, 38)
	assert dut.PORTA.value == 38
	await write_reg(dut, 44, 0x55)
	await write_reg(dut, 46, 0xAA)
	assert await read_reg(dut, 5) == 0x55
	dut.PORTB.value = 122
	assert await read_reg(dut, 5) == 122
	await write_reg(dut, 63, 1)
	await write_reg(dut, 62, 2)
	await write_reg(dut, 61, 3)
	await write_reg(dut, 60, 99)
	assert await read_reg(dut, 63) == 1
	assert await read_reg(dut, 62) == 2
	assert await read_reg(dut, 61) == 3
	assert await read_reg(dut, 60) == 99
	await write_reg(dut, 9, 0)
	await write_reg(dut, 8, 3)
	await write_reg(dut, 6, 1)
	await write_reg(dut, 10, 0x55)
	await ClockCycles(dut.clk, 4)
	assert dut.TXD.value == 0
	for i in range(0, 4):
		await ClockCycles(dut.clk, 4)
		assert dut.TXD.value == 1
		await ClockCycles(dut.clk, 4)
		assert dut.TXD.value == 0
	await ClockCycles(dut.clk, 4)
	assert dut.TXD.value == 1
	await ClockCycles(dut.clk, 4)
	assert dut.TXD.value == 1
	await ClockCycles(dut.clk, 4)
	assert dut.TXD.value == 1
