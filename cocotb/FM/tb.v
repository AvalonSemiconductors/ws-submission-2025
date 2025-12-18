`default_nettype none
`timescale 1ns/1ps

module tb (
	input clk,
	
	input [7:0] din,
	input [5:0] addr,
	input RWn,
	input rst_n
);

wire [41:0] iopads;
assign iopads[41] = rst_n;
assign iopads[5] = RWn;
assign iopads[10] = RWn;
assign iopads[11] = addr[0];
assign iopads[12] = addr[1];
assign iopads[13] = addr[2];
assign iopads[14] = addr[3];
assign iopads[15] = addr[4];
assign iopads[39] = addr[5];
assign iopads[16] = RWn ? 1'bz : din[0];
assign iopads[17] = RWn ? 1'bz : din[1];
assign iopads[18] = RWn ? 1'bz : din[2];
assign iopads[19] = RWn ? 1'bz : din[3];
assign iopads[20] = RWn ? 1'bz : din[4];
assign iopads[21] = RWn ? 1'bz : din[5];
assign iopads[23] = RWn ? 1'bz : din[6];
assign iopads[32] = RWn ? 1'bz : din[7];

`ifdef USE_POWER_PINS
tri1 vddcore;
tri0 vsscore;
`endif

tri0 design_sel_0;
tri0 design_sel_1;
tri0 design_sel_2;
tri0 design_sel_3;
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

`default_nettype wire
