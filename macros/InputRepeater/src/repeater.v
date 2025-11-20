`default_nettype none

module repeater(
`ifdef USE_POWER_PINS
	inout wire VSS,
	inout wire VDD,
`endif
	input clk_i,
	output clk_o,
	input [41:0] io_in,
	output [41:0] io_in_buffered,
	input [4:0] design_sel,
	output [4:0] design_sel_buffered
);

assign io_in_buffered = io_in;
assign clk_o = clk_i;
assign design_sel_buffered = design_sel;

endmodule
