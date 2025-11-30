`default_nettype none

module fm(
`ifdef USE_POWER_PINS
	inout VDD,
	inout VSS,
`endif
	input clk_i,
	input rst_override_n,
	input [41:0] io_in_buffered,
	output [41:0] io_out,
	output [2:0] io_oe,
	
	output [11:0] sample_raw_1,
	output [11:0] sample_raw_2,
	output [11:0] sample_raw_3
);

wire [7:0] bus_out;
wire rst_n = rst_override_n && io_in_buffered[41];
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

assign io_out[33] = 1'b0;
assign io_out[34] = 1'b0;

assign io_out[27] = 1'b0;
assign io_out[28] = 1'b0;
assign io_out[29] = 1'b0;
assign io_out[30] = 1'b0;
assign io_out[31] = 1'b0;
assign io_out[41:35] = 0;

wire [11:0] sample1;
wire [11:0] sample2;
wire [11:0] sample3;
assign sample_raw_1 = 12'hFFF - (rst_override_n ? sample1 : 12'hFFF);
assign sample_raw_2 = 12'hFFF - (rst_override_n ? sample2 : 12'hFFF);
assign sample_raw_3 = 12'hFFF - (rst_override_n ? sample3 : 12'hFFF);

fm_top fm_top(
	.clk(clk_i),
	.rst_n(rst_n),
	.RWb_in(io_in_buffered[5]),
	.CEb_in(io_in_buffered[10]),
	.reg_addr({io_in_buffered[39], io_in_buffered[15], io_in_buffered[14], io_in_buffered[13], io_in_buffered[12], io_in_buffered[11]}),
	.oe(io_oe[0]),
	.bus_in({io_in_buffered[32], io_in_buffered[23], io_in_buffered[21:16]}),
	.bus_out(bus_out),
	.sample_raw_1(sample1),
	.sample_raw_2(sample2),
	.sample_raw_3(sample3),
	.pot_x_in(io_in_buffered[34]),
	.pot_y_in(io_in_buffered[33]),
	.pot_x_oe(io_oe[2]),
	.pot_y_oe(io_oe[1])
);

endmodule
