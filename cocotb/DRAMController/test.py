import cocotb
import struct
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

@cocotb.test()
async def test_dram_controller(dut):
	dut._log.info("start")
	dut.RESETn.value = 0
	dut.RWn.value = 1
	c = Clock(dut.clk, 100, "ns")
	cocotb.start_soon(c.start())
	await ClockCycles(dut.clk, 3)
	dut.RESETn.value = 1
	await ClockCycles(dut.clk, 2)
	delay_setup = 2
	delay_hold = 2
	delay_ras = 4
	delay_cas = 7
	delay_ras_to_cas = 5
	delay_ras_precharge = 6
	delay_cas_precharge = 2
	initvals = [
		0, # refresh_interval[7:0]
		1, # refresh_interval[15:8]
		0x67, # do_data_setup = 1, page_mode_en = 1, column_bits = 8
		delay_setup - 1, # delay_setup
		delay_hold - 1, # delay_hold
		delay_ras - 1, # delay_ras
		delay_cas - 1, # delay_cas
		delay_ras_to_cas - 1, # delay_ras_to_cas
		delay_ras_precharge - 1, # delay_ras_precharge
		delay_cas_precharge - 1, # delay_cas_precharge
		1, # Disable configure
	]
	for i in range(0, 11):
		dut.addr.value = initvals[i]
		dut.CSn.value = 0
		dut.CONFn.value = 0
		await ClockCycles(dut.clk, 1)
		dut.CSn.value = 1
		dut.CONFn.value = 1
		await ClockCycles(dut.clk, 1)
	assert dut.RDY.value == 1
	await ClockCycles(dut.clk, 10)
	assert dut.RDY.value == 1
	dut.addr.value = 0x2A39
	dut.RWn.value = 0
	dut.CSn.value = 0
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	dut.RWn.value = 1
	dut.CSn.value = 1
	assert dut.RDY.value == 0
	assert dut.WLE.value == 1
	assert dut.DA.value == 0x2A
	assert dut.RASn.value == 1
	assert dut.BEn.value == 0
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.WLE.value == 0
	assert dut.RASn.value == 0
	assert dut.DWn.value == 0
	await ClockCycles(dut.clk, delay_ras_to_cas-1)
	await Timer(5, "ns")
	assert dut.CASn.value == 1
	assert dut.DA.value == 0x39
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.CASn.value == 0
	assert dut.DA.value == 0x39
	assert dut.BEn.value == 0
	await ClockCycles(dut.clk, delay_cas-1)
	await Timer(5, "ns")
	assert dut.CASn.value == 0
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.CASn.value == 1
	assert dut.BEn.value == 1
	assert dut.RDY.value == 1
	assert dut.DWn.value == 1
	await ClockCycles(dut.clk, 16)
	await Timer(5, "ns")
	assert dut.RASn.value == 0
	assert dut.RDY.value == 1
	
	dut.addr.value = 0x2A00;
	dut.RWn.value = 0
	dut.CSn.value = 0
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	dut.RWn.value = 1
	dut.CSn.value = 1
	assert dut.RDY.value == 0
	assert dut.WLE.value == 1
	assert dut.RASn.value == 0
	assert dut.DA.value == 0x00
	assert dut.DWn.value == 0
	await ClockCycles(dut.clk, delay_setup)
	await Timer(5, "ns")
	assert dut.CASn.value == 0
	await ClockCycles(dut.clk, delay_cas-1)
	await Timer(5, "ns")
	assert dut.CASn.value == 0
	assert dut.BEn.value == 0
	assert dut.RDY.value == 0
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.CASn.value == 1
	assert dut.BEn.value == 1
	assert dut.RDY.value == 1
	await ClockCycles(dut.clk, 16)
	await Timer(5, "ns")
	assert dut.RASn.value == 0
	assert dut.RDY.value == 1
	assert dut.DWn.value == 1
	
	dut.RWn.value = 1
	dut.CSn.value = 0
	dut.addr.value = 0x3349
	assert dut.RDY.value == 1
	await Timer(15, "ns")
	assert dut.RDY.value == 0
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.WLE.value == 0
	assert dut.DA.value == 0x33
	assert dut.RDY.value == 0
	assert dut.BEn.value == 1
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.RASn.value == 1
	await ClockCycles(dut.clk, delay_ras_precharge-1)
	await Timer(5, "ns")
	assert dut.RASn.value == 1
	assert dut.RDY.value == 0
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.RASn.value == 0
	assert dut.DWn.value == 1
	await ClockCycles(dut.clk, delay_ras_to_cas)
	await Timer(5, "ns")
	assert dut.CASn.value == 0
	assert dut.BEn.value == 1
	await ClockCycles(dut.clk, delay_cas)
	await Timer(5, "ns")
	assert dut.CASn.value == 1
	assert dut.RLE.value == 1
	assert dut.RDY.value == 1
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.RLE.value == 0
	assert dut.RDY.value == 1
	dut.CSn.value = 1
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.RDY.value == 1
	
	# Wait for refresh
	counter = 0
	while(dut.RASn.value == 0):
		await ClockCycles(dut.clk, 1)
		await Timer(5, "ns")
		counter = counter + 1
	dut._log.info(counter)
	dut._log.info(dut.counter.value)
	dut._log.info(counter + dut.counter.value)
	assert dut.counter.value > 256 and dut.counter.value < 300
	await ClockCycles(dut.clk, delay_ras_precharge-1)
	await Timer(5, "ns")
	assert dut.RASn.value == 1
	assert dut.DA.value == 0x00
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.RASn.value == 0
	assert dut.DA.value == 0x00
	await ClockCycles(dut.clk, delay_ras-1)
	await Timer(5, "ns")
	assert dut.RASn.value == 0
	assert dut.DA.value == 0x00
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.RASn.value == 1
	assert dut.DA.value == 0x33
	await ClockCycles(dut.clk, delay_ras_precharge)
	await Timer(5, "ns")
	assert dut.RASn.value == 1
	
	# Wait for another refresh
	counter = 0
	while(dut.RASn.value != 0):
		await ClockCycles(dut.clk, 1)
		await Timer(5, "ns")
		counter = counter + 1
	dut._log.info(counter)
	dut._log.info(dut.counter.value)
	dut._log.info(counter + dut.counter.value)
	assert counter > 250 and counter < 258
	dut.CSn.value = 0
	dut.addr.value = 0xAB67
	assert dut.DA.value == 0x01
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.RDY.value == 0
	assert dut.RASn.value == 0
	await ClockCycles(dut.clk, delay_ras-1)
	await Timer(5, "ns")
	assert dut.RDY.value == 0
	assert dut.RASn.value == 1
	assert dut.DA.value == 0xAB
	await ClockCycles(dut.clk, delay_ras_precharge)
	await Timer(5, "ns")
	assert dut.RASn.value == 0
	await ClockCycles(dut.clk, delay_ras_to_cas)
	await Timer(5, "ns")
	assert dut.RASn.value == 0
	assert dut.CASn.value == 0
	assert dut.DA.value == 0x67
	dut.CSn.value = 1
	await ClockCycles(dut.clk, delay_cas)
	await Timer(5, "ns")
	assert dut.CASn.value == 1
	assert dut.RLE.value == 1
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.RLE.value == 0
	
	await ClockCycles(dut.clk, 238)
	await Timer(5, "ns")
	assert dut.RASn.value == 0
	assert dut.RDY.value == 1
	assert dut.BEn.value == 1
	# Memory request coincident with refresh starting
	dut.CSn.value = 0
	dut.RWn.value = 0
	dut.addr.value = 0xFE01
	assert dut.WLE.value == 0
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	dut.CSn.value = 1
	dut.RWn.value = 1
	assert dut.RDY.value == 0
	assert dut.BEn.value == 0
	assert dut.RASn.value == 0
	assert dut.WLE.value == 1
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.RASn.value == 1
	await ClockCycles(dut.clk, delay_ras_precharge-1)
	await Timer(5, "ns")
	assert dut.DWn.value == 1
	assert dut.DA.value == 0x02
	assert dut.RASn.value == 1
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.RASn.value == 0
	assert dut.DA.value == 0x02
	await ClockCycles(dut.clk, delay_ras)
	await Timer(5, "ns")
	assert dut.RASn.value == 1
	assert dut.DA.value == 0xFE
	assert dut.RDY.value == 0
	assert dut.DWn.value == 1
	await ClockCycles(dut.clk, delay_ras_precharge)
	await Timer(5, "ns")
	assert dut.BEn.value == 0
	assert dut.RASn.value == 0
	assert dut.DA.value == 0x01
	assert dut.DWn.value == 0
	await ClockCycles(dut.clk, delay_ras_to_cas-1)
	await Timer(5, "ns")
	assert dut.CASn.value == 1
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.CASn.value == 0
	assert dut.DA.value == 0x01
	assert dut.DWn.value == 0
	assert dut.BEn.value == 0
	await ClockCycles(dut.clk, delay_cas)
	await Timer(5, "ns")
	assert dut.DWn.value == 1
	assert dut.BEn.value == 1
	assert dut.CASn.value == 1
	
	# Wait for another refresh
	counter = 0
	while(dut.RASn.value == 0):
		await ClockCycles(dut.clk, 1)
		await Timer(5, "ns")
		counter = counter + 1
	dut._log.info(counter)
	dut._log.info(dut.counter.value)
	dut._log.info(counter + dut.counter.value)
	await ClockCycles(dut.clk, delay_ras_precharge)
	await Timer(5, "ns")
	assert dut.RASn.value == 0
	assert dut.DA.value == 0x03
	await ClockCycles(dut.clk, delay_ras-1)
	await Timer(5, "ns")
	assert dut.RASn.value == 0
	# Memory request coincident with refresh ending
	dut.CSn.value = 0
	dut.RWn.value = 0
	dut.addr.value = 0x2AC3
	assert dut.RDY.value == 1
	assert dut.BEn.value == 1
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	dut.CSn.value = 1
	dut.RWn.value = 1
	assert dut.RDY.value == 0
	assert dut.BEn.value == 0
	await ClockCycles(dut.clk, delay_ras_precharge-1)
	await Timer(5, "ns")
	assert dut.RASn.value == 1
	assert dut.DA.value == 0x2A
	assert dut.DWn.value == 1
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.RASn.value == 0
	assert dut.DWn.value == 0
	await ClockCycles(dut.clk, delay_ras_to_cas-1)
	await Timer(5, "ns")
	assert dut.RASn.value == 0
	assert dut.CASn.value == 1
	assert dut.DA.value == 0xC3
	assert dut.DWn.value == 0
	await ClockCycles(dut.clk, 1)
	await Timer(5, "ns")
	assert dut.RASn.value == 0
	assert dut.CASn.value == 0
	assert dut.DA.value == 0xC3
	assert dut.DWn.value == 0
	assert dut.BEn.value == 0
	await ClockCycles(dut.clk, delay_cas)
	await Timer(5, "ns")
	assert dut.CASn.value == 1
	assert dut.DWn.value == 1
	assert dut.BEn.value == 1
	await ClockCycles(dut.clk, 16)
	await Timer(5, "ns")
	
	dut._log.info(dut.counter.value)
