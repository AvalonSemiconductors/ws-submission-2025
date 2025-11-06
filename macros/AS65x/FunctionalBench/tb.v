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

reg [7:0] memory [65535:0];

integer i;
initial begin
	for(i=0;i<65536;i++) begin
		memory[i] = 0;
	end
	i = 0;
	//$readmemh("../6502_functional_test.txt", memory, 'hA, 'hFFFF);
	$readmemh("../6502_decimal_test.txt", memory, 'h0400, 'hFFFF);
	memory['hFFFC] = 8'h00;
	memory['hFFFD] = 8'h04;
end
wire [7:0] D_IN = RWn_v ? memory[A] : 8'h00;
wire [7:0] N1 = memory['hA];
wire [7:0] N2 = memory['hB];
wire [7:0] DA = memory['hE];
wire [7:0] DNVZC = memory['hF];
wire [7:0] AR = memory['h10];
wire [7:0] ZF = memory['h13];

always @(posedge clk_i) begin
	i <= i + 1;
	if(!RWn_v) begin
		memory[A] <= D_OUT;
		//$display("Write to %d = %d", A, D_OUT);
		if(A == 'hFFFF) begin
			$display("Write to debug address: %d", D_OUT);
			$display("Program address is %x", cpu65.PC);
			$finish();
		end
	end
end

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

`ifdef TRACE_ON
reg tracing = 0;
always @(posedge clk_i) begin
	if(i == 3470000) begin
		if(!tracing) begin
			tracing <= 1;
			$dumpfile ("tb.vcd");
			$dumpvars (0, cpu65_tb);
			#1;
		end
	end
end
`endif

endmodule
