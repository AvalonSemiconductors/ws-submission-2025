import cocotb
import struct
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles
from PIL import Image

@cocotb.test()
async def test_ntsc(dut):
	dut._log.info("start")
	dut.RESETn.value = 0
	dut.color_enable.value = 0
	c = Clock(dut.clk, 69842, "ps")
	cocotb.start_soon(c.start())
	await ClockCycles(dut.clk, 3)
	dut.RESETn.value = 1

	im = Image.new('L', (752, 248*2), 0)

	curr_line = 999
	curr_pixel = 0
	while True:
		await ClockCycles(dut.clk, 1)
		await Timer(15, "ns")
		if(curr_line < 248 and curr_pixel < 752 and dut.ntsc_out.value != 0 and curr_line != 999):
			color = dut.ntsc_out.value.to_unsigned() / 4095.0
			color = color - 0.3
			color = color / 0.7
			color = color * 255
			color = int(color)
			im.putpixel((curr_pixel, curr_line*2), color)
			im.putpixel((curr_pixel, curr_line*2+1), color)
		curr_pixel = curr_pixel + 1
		if(dut.ntsc_out.value == 0):
			await RisingEdge(dut.clk)
			await Timer(4.7, "us")
			if(dut.ntsc_out.value == 0):
				dut._log.info("vsync")
				break
			else:
				if(curr_line == 999):
					curr_line = 0
				else:
					curr_line = curr_line + 1
				curr_pixel = 0
				dut._log.info(f"hsync {curr_line}")
				await Timer(4.7, "us")
	dut._log.info(curr_line)
	im.save('frame.png')
