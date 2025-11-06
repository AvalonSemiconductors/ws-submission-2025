import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

@cocotb.test()
async def test_c64pla(dut):
	dut._log.info("start")
	c = Clock(dut.clk, 100, "ns")
	cocotb.start_soon(c.start())
	dut.pla_cen.value = 0
	dut.pla_i.value = 0
	
	await ClockCycles(dut.clk, 2)
	dut.pla_cen.value = 1
	await ClockCycles(dut.clk, 1)
	dut._log.info(dut.pla_f.value)
	assert dut.pla_f.value == "ZZZZZZZZ"
	dut.pla_cen.value = 0
	await ClockCycles(dut.clk, 1)
	dut._log.info(dut.pla_f.value)
	assert dut.pla_f.value == 0xFE

	last_val = -1
	for i in range(0, 65536):
		dut.pla_i.value = i
		await ClockCycles(dut.clk, 1)
		assert dut.matching.value == 1
		if(last_val != i >> 12 or i == 65535):
			last_val = i >> 12
			dut._log.info(f"Completed {i} cases")
