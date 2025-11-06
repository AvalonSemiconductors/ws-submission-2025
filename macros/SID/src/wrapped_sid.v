`default_nettype none

module sid(
`ifdef USE_POWER_PINS
	inout VDD,
	inout VSS,
`endif
	input clk_i,
	input rst_override_n,
	input [41:0] io_in,
	output [41:0] io_out,
	output [2:0] io_oe,
	
	output [11:0] sample_raw_1,
	output [11:0] sample_raw_2
);

wire [7:0] bus_out;
wire DAC_clk;
wire DAC_dat_1;
wire DAC_dat_2;
wire DAC_leb;
wire DAC_csb;
wire rst_n = rst_override_n && io_in[41];
assign io_out[15:0] = 0;
assign io_out[16] = bus_out[0];
assign io_out[17] = bus_out[1];
assign io_out[18] = bus_out[2];
assign io_out[19] = bus_out[3];
assign io_out[20] = bus_out[4];
assign io_out[21] = bus_out[5];
assign io_out[22] = 1'b1;
assign io_out[23] = bus_out[6];
assign io_out[26:24] = 0;
assign io_out[32] = bus_out[7];

assign io_out[33] = 1'b0; //POT Y
assign io_oe[1] = 1'b0;
assign io_out[34] = 1'b0; //POT X
assign io_oe[2] = 1'b0;

assign io_out[27] = DAC_clk;
assign io_out[28] = DAC_dat_1;
assign io_out[29] = DAC_dat_2;
assign io_out[30] = DAC_leb;
assign io_out[31] = DAC_csb;
assign io_out[41:35] = 0;

sid_top sid_top(
	.clk(clk_i),
	.rst_n(rst_n),
	.RWb_in(io_in[5]),
	.CEb_in(io_in[10]),
	.reg_addr({io_in[39], io_in[15], io_in[14], io_in[13], io_in[12], io_in[11]}),
	.DAC_clk(DAC_clk),
	.DAC_dat_1(DAC_dat_1),
	.DAC_dat_2(DAC_dat_2),
	.DAC_leb(DAC_leb),
	.DAC_csb(DAC_csb),
	.oe(io_oe[0]),
	.bus_in({io_in[32], io_in[23], io_in[21:16]}),
	.bus_out(bus_out),
	.sample_raw_1(sample_raw_1),
	.sample_raw_2(sample_raw_2)
);

endmodule
