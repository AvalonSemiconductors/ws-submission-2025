`default_nettype none
`timescale 1ns/1ps

module tb (
	input clk,
	
	input RDY,
	output PH1OUT,
	input IRQn,
	output VPn,
	input NMIn,
	output SYNC,
	output [15:0] A,
	output tri0 [7:0] D_out,
	input [7:0] D_in,
	output RWn,
	input AEC,
	output MLn,
	input SOn,
	output PH2OUT,
	input RESETn
);

wire [41:0] iopads;
assign iopads[8] = RDY;
assign PH1OUT = iopads[9];
assign iopads[10] = IRQn;
assign VPn = iopads[11];
assign iopads[12] = NMIn;
assign SYNC = iopads[13];
assign A[11:0] = iopads[26:15];
assign A[12] = iopads[28];
assign A[15:13] = iopads[32:30];
assign D_out[7] = iopads[33];
assign iopads[33] = RWn == 1'b1 ? D_in[7] : 1'bz;
assign D_out[6] = iopads[34];
assign iopads[34] = RWn == 1'b1 ? D_in[6] : 1'bz;
assign D_out[5] = iopads[35];
assign iopads[35] = RWn == 1'b1 ? D_in[5] : 1'bz;
assign D_out[4] = iopads[36];
assign iopads[36] = RWn == 1'b1 ? D_in[4] : 1'bz;
assign D_out[3] = iopads[37];
assign iopads[37] = RWn == 1'b1 ? D_in[3] : 1'bz;
assign D_out[2] = iopads[38];
assign iopads[38] = RWn == 1'b1 ? D_in[2] : 1'bz;
assign D_out[1] = iopads[39];
assign iopads[39] = RWn == 1'b1 ? D_in[1] : 1'bz;
assign D_out[0] = iopads[40];
assign iopads[40] = RWn == 1'b1 ? D_in[0] : 1'bz;
assign RWn = iopads[41];
assign iopads[0] = AEC;
assign MLn = iopads[1];
assign iopads[5] = SOn;
assign PH2OUT = iopads[6];
assign iopads[7] = RESETn;


`ifdef USE_POWER_PINS
tri1 vddcore;
tri0 vsscore;
`endif

tri1 design_sel_0;
tri0 design_sel_1;
tri0 design_sel_2;
tri1 design_sel_3;
tri0 design_sel_4;

wire weh = !clk;

chip_top chip_top(
`ifdef USE_POWER_PINS
	.VDD(vddcore),
	.VSS(vsscore),
`endif
	.clk_PAD(weh),
	.design_sel_PAD({design_sel_4, design_sel_3, design_sel_2, design_sel_1, design_sel_0}),
	.bidir_PAD(iopads)
);

endmodule

`default_nettype wire
