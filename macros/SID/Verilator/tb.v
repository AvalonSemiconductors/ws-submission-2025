`default_nettype none
`timescale 1ns/100ps

module tb(
	input WEb,
	input [5:0] address,
	input [7:0] data,

	input clk,
	input rst_n
);

`ifdef TRACE_ON
	initial begin
		$dumpfile("tb.vcd");
		$dumpvars(0, tb);
		#1;
	end
`endif

wire [41:0] io_in;
assign io_in[41] = rst_n;
assign io_in[5] = WEb;
assign io_in[10] = 1'b0;
assign io_in[39] = address[5];
assign io_in[15] = address[4];
assign io_in[14] = address[3];
assign io_in[13] = address[2];
assign io_in[12] = address[1];
assign io_in[11] = address[0];
assign io_in[32] = data[7] & !io_oe[0];
assign io_in[23] = data[6] & !io_oe[0];
assign io_in[21:16] = data[5:0] & {6{!io_oe[0]}};
assign io_in[40] = 1'b1;
assign io_in[25:24] = 2'b11;

wire [41:0] io_out;
wire [2:0] io_oe;

wire DAC_clk = io_out[27];
wire DAC_dat_1 = io_out[28];
wire DAC_le_b = io_out[30];
wire DAC_dat_2 = io_out[29];
wire DAC_cs_b = io_out[31];

wire [11:0] sample_raw_1;
wire [11:0] sample_raw_2;

sid wrapped_sid(
	.clk_i(clk),
	.rst_override_n(1'b1),
	.io_in_buffered(io_in),
	.io_out(io_out),
	.io_oe(io_oe),
	.gpiochip_sample_1(12'hFFF),
	.gpiochip_sample_2(12'hFFF),
	.gpiochip_sample_3(12'hFFF),
	.sample_raw_1(sample_raw_1),
	.sample_raw_2(sample_raw_2),
	.sample_raw_3()
);

reg sample_clock;
always #18.14 sample_clock <= (sample_clock === 1'b0);
integer sample_count;
integer fhandle;
initial begin
	sample_clock = 1'b0;
`ifndef IVERILOG
	fhandle = $fopen("samples.bin", "w");
	$fwrite(fhandle, "bbbb");
	$fflush();
	$fclose(fhandle);
`endif
	sample_count = 0;
end

always @(posedge sample_clock) begin
`ifndef IVERILOG
	fhandle = $fopen("samples.bin", "a+b");
	$fwrite(fhandle, "%u", 12'hFFF - sample_raw_1);
	//$fwrite(fhandle, "%u", 12'hFFF - sample_raw_2);
	$fflush();
	$fclose(fhandle);
`endif
	sample_count <= sample_count + 1;
end

/*MCP4921 MCP4921(
	.clk(DAC_clk),
	.dat1(DAC_dat_1),
	.dat2(DAC_dat_2),
	.ldac_b(DAC_le_b),
	.cs_b(DAC_cs_b),
	.rst_b(rst_n)
);*/

endmodule
