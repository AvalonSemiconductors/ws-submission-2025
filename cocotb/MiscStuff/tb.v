`default_nettype none
`timescale 1ns/1ps

module tb (
	input clk,
	input rst_n,
	output vsync,
	output hsync
);

wire [41:0] iopads;
assign iopads[0] = rst_n;
assign vsync = iopads[29];
assign hsync = iopads[33];

`ifdef USE_POWER_PINS
tri1 vddcore;
tri0 vsscore;
`endif

tri1 design_sel_0;
tri0 design_sel_1;
tri0 design_sel_2;
tri0 design_sel_3;
tri0 design_sel_4;

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

`default_nettype wire
