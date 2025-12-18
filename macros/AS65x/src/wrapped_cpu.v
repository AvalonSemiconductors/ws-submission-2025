`default_nettype none

//Pad assignments

//6502
//RDY - 8
//P1OUT - 9
//IRQn - 10
//NC - 11
//NMIn - 12
//SYNC - 13
//A0 - 15
//A1 - 16
//A2 - 17
//A3 - 18
//A4 - 19
//A5 - 20
//A6 - 21
//A7 - 22
//A8 - 23
//A9 - 24
//A10 - 25
//A11 - 26
//A12 - 28
//A13 - 30
//A14 - 31
//A15 - 32
//D7 - 33
//D6 - 34
//D5 - 35
//D4 - 36
//D3 - 37
//D2 - 38
//D1 - 39
//D0 - 40
//RWn - 41
//NC - 0
//NC - 1
//S0 - 5
//P2OUT - 6
//RESn - 7

//6510
//RDY - 9
//IRQn - 10
//NMIn - 11
//AEC - 12
//A0 - 13
//A1 - 14
//A2 - 15
//A3 - 16
//A4 - 17
//A5 - 18
//A6 - 19
//A7 - 20
//A8 - 21
//A9 - 22
//A10 - 23
//A11 - 24
//A12 - 25
//A13 - 26
//A14 - 28
//A15 - 29
//P5 - 30
//P4 - 31
//P3 - 32
//P2 - 33
//P1 - 34
//P0 - 35
//D7 - 36
//D6 - 37
//D5 - 38
//D4 - 39
//D3 - 40
//D2 - 41
//D1 - 0
//D0 - 1
//RWn - 2
//CLKOUT - 3
//RESn - 4

module as65x(
`ifdef USE_POWER_PINS
	inout wire VSS,
	inout wire VDD,
`endif
	input clk_i,
	input rst_override_n,
	
	input [41:0] io_in,
	output [41:0] io_out,
	output [41:0] io_oe,
	
	input select_6502
);

reg [7:0] DDR;
reg [7:0] PORT;

wire PH1OUT;
wire PH2OUT;
wire SYNC;
wire RWn;
wire RWn_oe;
wire [15:0] A_o;
wire A_oe;
wire MLn;
wire VPn;
wire [7:0] D_o;
wire D_oe;
wire bonus_output;

wire [7:0] D_i_6502 = {
	io_in[33],
	io_in[34],
	io_in[35],
	io_in[36],
	io_in[37],
	io_in[38],
	io_in[39],
	io_in[40]
};

wire [7:0] PORT_read = (DDR & PORT) | ((~DDR) & {
	1'b0,
	1'b0,
	io_in[30],
	io_in[31],
	io_in[32],
	io_in[33],
	io_in[34],
	io_in[35]
});
wire [7:0] D_i_6510 = A_o == 0 ? DDR : (A_o == 1 ? PORT_read : {
	io_in[36],
	io_in[37],
	io_in[38],
	io_in[39],
	io_in[40],
	io_in[41],
	io_in[0],
	io_in[1]
});

wire [41:0] io_out_6502 = {
	RWn,
	D_o[0],
	D_o[1],
	D_o[2],
	D_o[3],
	D_o[4],
	D_o[5],
	D_o[6],
	D_o[7],
	A_o[15],
	A_o[14],
	A_o[13],
	bonus_output,
	A_o[12],
	1'b0,
	A_o[11],
	A_o[10],
	A_o[9],
	A_o[8],
	A_o[7],
	A_o[6],
	A_o[5],
	A_o[4],
	A_o[3],
	A_o[2],
	A_o[1],
	A_o[0],
	1'b0,
	SYNC,
	1'b1, //NMIn
	VPn,
	1'b1, //IRQn
	PH1OUT,
	1'b1, //RDY
	1'b1, //RESn
	PH2OUT,
	1'b1, //SOb
	1'b0,
	1'b0,
	1'b0,
	MLn,
	1'b1 //AEC
};

wire [41:0] oe_6502 = {
	RWn_oe,
	{8{D_oe}},
	A_oe,
	A_oe,
	A_oe,
	1'b1,
	A_oe,
	1'b0,
	{12{A_oe}},
	1'b0,
	1'b1, //SYNC
	1'b0, //NMIn
	1'b1, //VPn
	1'b0, //IRQn
	1'b1, //PH1OUT
	1'b0, //RDY
	1'b0, //RESn
	1'b1, //PH2OUT
	1'b0, //SOb
	1'b0,
	1'b0,
	1'b0,
	1'b1, //MLn
	1'b0 //AEC
};

wire [41:0] io_out_6510 = {
	D_o[2],
	D_o[3],
	D_o[4],
	D_o[5],
	D_o[6],
	D_o[7],
	PORT[0],
	PORT[1],
	PORT[2],
	PORT[3],
	PORT[4],
	PORT[5],
	A_o[15],
	A_o[14],
	1'b0,
	A_o[13],
	A_o[12],
	A_o[11],
	A_o[10],
	A_o[9],
	A_o[8],
	A_o[7],
	A_o[6],
	A_o[5],
	A_o[4],
	A_o[3],
	A_o[2],
	A_o[1],
	A_o[0],
	1'b1, //AEC
	1'b1, //NMIn
	1'b1, //IRQn
	1'b1, //RDY
	1'b0,
	1'b0,
	1'b0,
	1'b0,
	1'b1, //RESn
	PH1OUT,
	RWn,
	D_o[0],
	D_o[1]
};

wire [41:0] oe_6510 = {
	{6{D_oe}},
	DDR[0],
	DDR[1],
	DDR[2],
	DDR[3],
	DDR[4],
	DDR[5],
	A_oe,
	A_oe,
	1'b0,
	{14{A_oe}},
	1'b0, //AEC
	1'b0, //NMIn
	1'b0, //IRQn
	1'b0, //RDY
	1'b0,
	1'b0,
	1'b0,
	1'b0, //RESn
	1'b0,
	1'b1, //PH1OUT
	RWn_oe,
	D_oe,
	D_oe
};

assign io_out = select_6502 ? io_out_6502 : io_out_6510;
assign io_oe = select_6502 ? oe_6502 : oe_6510;

wire rst_n = rst_override_n && (select_6502 ? io_in[7] : io_in[4]);

cpu65 cpu(
	.PH0IN(clk_i),
	.PH1OUT(PH1OUT),
	.PH2OUT(PH2OUT),
	.rst_n(rst_n),
	.RDY(select_6502 ? io_in[8] : io_in[9]),
	.AEC(select_6502 ? io_in[0] : io_in[12]),
	.IRQn(io_in[10]),
	.NMIn(select_6502 ? io_in[12] : io_in[11]),
	.SOn(io_in[5] || !select_6502),
	.SYNC(SYNC),
	.RWn(RWn),
	.RWn_oe(RWn_oe),
	.A_o(A_o),
	.A_oe(A_oe),
	.MLn(MLn),
	.VPn(VPn),
	.D_o(D_o),
	.D_i(select_6502 ? D_i_6502 : D_i_6510),
	.D_oe(D_oe),
	.sync_irqs(!(select_6502 ? io_in[14] : io_in[8])), //Turned ON by bonding to ground
	.sync_rdy(io_in[27]), //Turned OFF by bonding to ground
	.rdy_writes(!(select_6502 ? io_in[2] : io_in[7])), //Turned ON by bonding to ground
	.do_latency(select_6502 ? io_in[3] : io_in[5]), //Turned OFF by bonding to ground
	.bonus_output(bonus_output)
);

always @(negedge clk_i) begin
	if(!rst_n) begin
		//If 6510 is selected and pad 6 is NOT bonded to ground,
		//pre-load DDR and PORT with correct values for a C64
		if(!select_6502 && io_in[6]) begin
			DDR <= 8'b00101111;
			PORT <= 8'b00100111;
		end else begin
			DDR <= 8'h00;
			PORT <= 8'h00;
		end
	end else if(!RWn) begin
		if(A_o == 0) DDR <= D_o;
		if(A_o == 1) PORT <= D_o;
	end
end

generate
for (genvar i=0; i<42; i++) begin
	(* keep *)
	gf180mcu_fd_sc_mcu7t5v0__antenna input_tie (
		`ifdef USE_POWER_PINS
		.VNW    (VDD),
		.VPW    (VSS),
		.VDD    (VDD),
		.VSS    (VSS),
		`endif
		.I(io_in[i])
	);
end
endgenerate

endmodule
