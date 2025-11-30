`default_nettype none
`timescale 1ns/1ps

module tb (
	input clk,
	input RESETn,
	input color_enable,
	output [11:0] ntsc_out
);

wire [41:0] iopads;
assign iopads[41] = RESETn;
assign iopads[40:37] = 6;
assign iopads[36] = color_enable;
assign ntsc_out = iopads[11:0];
assign iopads[35] = 1'b0;

`ifdef USE_POWER_PINS
tri1 vddcore;
tri0 vsscore;
`endif

tri0 design_sel_0;
tri0 design_sel_1;
tri0 design_sel_2;
tri1 design_sel_3;
tri1 design_sel_4;

chip_top chip_top(
`ifdef USE_POWER_PINS
	.VDD(vddcore),
	.VSS(vsscore),
`endif
	.clk_PAD(clk),
	.design_sel_PAD({design_sel_4, design_sel_3, design_sel_2, design_sel_1, design_sel_0}),
	.bidir_PAD(iopads)
);

endmodule
