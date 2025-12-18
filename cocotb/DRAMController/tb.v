`default_nettype none
`timescale 1ns/1ps

module tb (
	input clk,
	input RESETn,
	input [15:0] addr,
	input CSn,
	input RWn,
	input CONFn,
	output [7:0] DA,
	output RASn,
	output CASn,
	output DWn,
	output RDY,
	output BEn,
	output RLE,
	output WLE,
	output integer counter = 0
);

always @(posedge clk) counter = RESETn ? counter + 1 : 0;

wire [41:0] iopads;
assign RDY = iopads[1];
assign iopads[2] = RESETn;
assign iopads[22:7] = addr;
assign iopads[23] = CSn;
assign iopads[24] = RWn;
assign iopads[25] = CONFn;
assign DA[1:0] = iopads[27:26];
assign DA[7:2] = iopads[34:29];
assign RASn = iopads[35];
assign CASn = iopads[36];
assign DWn = iopads[37];
assign BEn = iopads[39];
assign RLE = iopads[40];
assign WLE = iopads[41];

`ifdef USE_POWER_PINS
tri1 vddcore;
tri0 vsscore;
`endif

tri1 design_sel_0;
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

`default_nettype wire
