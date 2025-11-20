`default_nettype none
`timescale 1ns/1ps

module tb (
	input clk,
	input RESETn,
	input [5:0] addr,
	input CEb,
	input OEb,
	input WEb,
	input [7:0] D_in,
	output [7:0] D_out,
	output [7:0] PORTA,
	input [7:0] PORTB,
	input RXD,
	output TXD,
	input SDI,
	output SDO,
	output SCK,
	output irupt,
	output tmr0_o,
	output tmr1_o
);

wire [41:0] iopads;
assign iopads[2] = RESETn;
assign iopads[12:7] = addr;
assign iopads[13] = OEb ? D_in[0] : 1'bz;
assign D_out[0] = iopads[13];
assign iopads[14] = OEb ? D_in[1] : 1'bz;
assign D_out[1] = iopads[14];
assign iopads[15] = OEb ? D_in[2] : 1'bz;
assign D_out[2] = iopads[15];
assign iopads[16] = OEb ? D_in[3] : 1'bz;
assign D_out[3] = iopads[16];
assign iopads[17] = OEb ? D_in[4] : 1'bz;
assign D_out[4] = iopads[17];
assign iopads[18] = OEb ? D_in[5] : 1'bz;
assign D_out[5] = iopads[18];
assign iopads[19] = OEb ? D_in[6] : 1'bz;
assign D_out[6] = iopads[19];
assign iopads[20] = OEb ? D_in[7] : 1'bz;
assign D_out[7] = iopads[20];
assign iopads[21] = CEb;
assign iopads[22] = OEb;
assign iopads[23] = WEb;
assign PORTA = iopads[31:24];
assign iopads[39:32] = PORTB;
assign iopads[40] = RXD;
assign TXD = iopads[41];
assign iopads[1] = SDI;
assign SDO = iopads[3];
assign SCK = iopads[4];
assign irupt = iopads[0];
assign tmr0_o = iopads[5];
assign tmr1_o = iopads[6];

`ifdef USE_POWER_PINS
tri1 vddcore;
tri0 vsscore;
`endif

tri0 design_sel_0;
tri1 design_sel_1;
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
