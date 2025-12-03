import cocotb
import struct
import os
import sys
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

@cocotb.test()
async def test_65rv32(dut):
	dut._log.info("start")
	dut.RESETn.value = 0
	dut.RDY.value = 1
	dut.IRQn.value = 1
	dut.NMIn.value = 1
	dut.AEC.value = 1
	dut.SOn.value = 1
	dut.D_in.value = 0
	c = Clock(dut.clk, 100, "ns")
	cocotb.start_soon(c.start())
	await ClockCycles(dut.clk, 5)
	dut.AEC.value = 0
	await ClockCycles(dut.clk, 1)
	assert dut.RWn.value == "Z"
	assert dut.A.value == "ZZZZZZZZZZZZZZZZ"
	assert dut.D_out.value == "XXXXXXXX"
	dut.AEC.value = 1
	await ClockCycles(dut.clk, 1)
	dut.RESETn.value = 1
	
	max_cycles = 240000
	curr_cycle = 0
	memory = [0] * 65536
	no_rep = False
	fsize = os.path.getsize("C/baremetal.bin")
	with open("C/baremetal.bin", mode="rb") as file:
		aaaa = file.read()
		for i in range(0, fsize):
			memory[i] = struct.unpack("B", aaaa[i:i+1])[0]
	while curr_cycle < max_cycles:
		await Timer(25, "ns")
		if(dut.RWn.value == 0):
			dut.D_in.value = 0
			await FallingEdge(dut.clk)
			await Timer(25, "ns")
			memory[dut.A.value] = dut.D_out.value
			if(dut.A.value == 65535):
				#dut._log.info(f"Wrote a {dut.D_out.value} to debug address")
				if(dut.D_out.value == 0):
					break
				else:
					c = chr(dut.D_out.value.to_unsigned())
					sys.stdout.write(c)
					sys.stdout.flush()
					if(c == '3'):
						dut.NMIn.value = 0
					else:
						dut.NMIn.value = 1
					if(no_rep and c == '\n'):
						no_rep = False
					elif(c == '\n' and no_rep == False):
						dut.IRQn.value = 0
						no_rep = True
					else:
						dut.IRQn.value = 1
			await RisingEdge(dut.clk)
		else:
			memval = memory[dut.A.value]
			dut.D_in.value = memval
			await ClockCycles(dut.clk, 1)
		curr_cycle = curr_cycle + 1
