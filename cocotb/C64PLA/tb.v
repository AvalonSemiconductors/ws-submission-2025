//This testbench works by comparing the behavior of the PLA in the chip to a known-good implementation (currently neatPLA)
//All 65536 possible inputs to the 16 i-lines are iterated over, and the outputs on the f-lines compared between both implementations
//As neatPLA has seen use in real C64s, this should be a good approach to ensuring compatibility!

`default_nettype none
`timescale 1ns/1ps

`include "./neatPLA/hdl/dodgypla_core.v"

module tb (
	input clk,
	input [15:0] pla_i,
	output [7:0] pla_f,
	input pla_cen,
	output matching
);

initial begin
	$display("weh!");
	#1;
end

wire [41:0] iopads;
assign iopads[0] = pla_i[11];
assign iopads[1] = pla_i[10];
assign iopads[2] = pla_i[9];
assign iopads[3] = pla_i[8];
assign iopads[8] = pla_i[7];
assign iopads[9] = pla_i[6];
assign iopads[10] = pla_i[5];
assign iopads[12] = pla_i[4];
assign iopads[13] = pla_i[3];
assign iopads[14] = pla_i[2];
assign iopads[19] = pla_i[1];
assign iopads[20] = pla_i[0];
assign pla_f[7] = iopads[21];
assign pla_f[6] = iopads[22];
assign pla_f[5] = iopads[23];
assign pla_f[4] = iopads[24];
assign pla_f[3] = iopads[26];
assign pla_f[2] = iopads[27];
assign pla_f[1] = iopads[30];
assign pla_f[0] = iopads[31];
assign iopads[32] = pla_cen;
assign iopads[33] = pla_i[15];
assign iopads[35] = pla_i[14];
assign iopads[40] = pla_i[13];
assign iopads[41] = pla_i[12];

`ifdef USE_POWER_PINS
tri1 vddcore;
tri0 vsscore;
`endif

tri0 design_sel_0;
tri1 design_sel_1;
tri1 design_sel_2;
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

wire [7:0] dodgy_f;
dodgypla_core dodgypla_core(
	.i0(pla_i[0]),
	.i1(pla_i[1]),
	.i2(pla_i[2]),
	.i3(pla_i[3]),
	.i4(pla_i[4]),
	.i5(pla_i[5]),
	.i6(pla_i[6]),
	.i7(pla_i[7]),
	.i8(pla_i[8]),
	.i9(pla_i[9]),
	.i10(pla_i[10]),
	.i11(pla_i[11]),
	.i12(pla_i[12]),
	.i13(pla_i[13]),
	.i14(pla_i[14]),
	.i15(pla_i[15]),
	.f0(dodgy_f[0]),
	.f1(dodgy_f[1]),
	.f2(dodgy_f[2]),
	.f3(dodgy_f[3]),
	.f4(dodgy_f[4]),
	.f5(dodgy_f[5]),
	.f6(dodgy_f[6]),
	.f7(dodgy_f[7])
);
assign matching = dodgy_f == pla_f;

endmodule
