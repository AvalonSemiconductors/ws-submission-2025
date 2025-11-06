`default_nettype none
`timescale 1ns/1ps
`define SIM

module cpu65_tb(
	input clk_i,
	input rst_n,
	input RDY,
	input AEC,
	input IRQn,
	input NMIn,
	input SOn,
	output SYNC,
	inout RWn,
	inout [15:0] A,
	output MLn,
	output VPn,
	input [7:0] D_IN,
	output [7:0] D_OUT,
	output [7:0] flags,
	output [7:0] reg_A,
	output [7:0] reg_X,
	output [7:0] reg_Y,
	output [7:0] reg_SP
);

wire RWn_v;
wire RWn_oe;
assign RWn = RWn_oe ? RWn_v : 1'bz;
wire [15:0] A_o;
wire A_oe;
assign A = A_oe ? A_o : 16'hzzzz;
wire [7:0] D_o;
wire D_oe;
assign D_OUT = D_oe ? D_o : 8'hFF;

cpu65 cpu65(
	.PH0IN(clk_i),
	.PH1OUT(),
	.PH2OUT(),
	.rst_n(rst_n),
	.RDY(RDY),
	.AEC(AEC),
	.IRQn(IRQn),
	.NMIn(NMIn),
	.SOn(SOn),
	.SYNC(SYNC),
	.RWn(RWn_v),
	.RWn_oe(RWn_oe),
	.A_o(A_o),
	.A_oe(A_oe),
	.MLn(MLn),
	.VPn(VPn),
	.D_o(D_o),
	.D_i(D_IN & {8{!D_oe}}),
	.D_oe(D_oe),
	.sync_irqs(1'b0),
	.sync_rdy(1'b1),
	.rdy_writes(1'b0),
	.dbg_flags(flags),
	.dbg_A(reg_A),
	.dbg_X(reg_X),
	.dbg_Y(reg_Y),
	.dbg_SP(reg_SP)
);

initial begin
	$dumpfile ("tb.vcd");
	$dumpvars (0, cpu65_tb);
	#1;
end

endmodule
