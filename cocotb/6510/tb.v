`default_nettype none
`timescale 1ns/1ps

module tb (
	input clk,
	
	input RDY,
	input IRQn,
	input NMIn,
	output SYNC,
	output [15:0] A,
	output [7:0] D_out,
	input [7:0] D_in,
	output [5:0] P_out,
	output RWn,
	input AEC,
	output PH2OUT,
	input RESETn
);

wire [41:0] iopads;
assign iopads[9] = RDY;
assign iopads[10] = IRQn;
assign iopads[11] = NMIn;
assign iopads[12] = AEC;
assign A[13:0] = iopads[26:13];
assign A[15:14] = iopads[29:28];
assign P_out[5] = iopads[30];
assign P_out[4] = iopads[31];
assign P_out[3] = iopads[32];
assign P_out[2] = iopads[33];
assign P_out[1] = iopads[34];
assign P_out[0] = iopads[35];
assign D_out[7] = iopads[36];
assign iopads[36] = RWn == 1'b1 ? D_in[7] : 1'bz;
assign D_out[6] = iopads[37];
assign iopads[37] = RWn == 1'b1 ? D_in[6] : 1'bz;
assign D_out[5] = iopads[38];
assign iopads[38] = RWn == 1'b1 ? D_in[5] : 1'bz;
assign D_out[4] = iopads[39];
assign iopads[39] = RWn == 1'b1 ? D_in[4] : 1'bz;
assign D_out[3] = iopads[40];
assign iopads[40] = RWn == 1'b1 ? D_in[3] : 1'bz;
assign D_out[2] = iopads[41];
assign iopads[41] = RWn == 1'b1 ? D_in[2] : 1'bz;
assign D_out[1] = iopads[0];
assign iopads[0] = RWn == 1'b1 ? D_in[1] : 1'bz;
assign D_out[0] = iopads[1];
assign iopads[1] = RWn == 1'b1 ? D_in[0] : 1'bz;
assign RWn = iopads[2];
assign PH2OUT = iopads[3];
assign iopads[4] = RESETn;
assign iopads[6] = 1'b1;

`ifdef USE_POWER_PINS
tri1 vddcore;
tri0 vsscore;
`endif

tri0 design_sel_0;
tri0 design_sel_1;
tri1 design_sel_2;
tri1 design_sel_3;
tri1 design_sel_4;

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
