`default_nettype none

//Enables the implementation for an addition instruction. This will change the opcodes of RTS and RSE to make it fit (RTS = 8'hB6, RSE = 8'hB7)
//`define ADDITION

module nano(
	input clk,			//Clock input
	output [10:0] PA,	//Program Address
	//inout [6:0] DC,		//Direct Control I/O
	output [6:0] DC_out,
	input [6:0] DC_in,
	output INT_ENA,	//Interrupt Enabled
	input INT_REQ,		//Interrupt Request
	output reg INT_ACK,		//Interrupt acknowledge
	output RW,		//I/O READ/WRITE
	output [3:0] DS,	//Device Select
	//inout [7:0] D,		//Data Bus
	input [7:0] D_in,
	output [7:0] D_out,
	output D_oe,
	output PSG,
	input rst		//Reset
);

reg [7:0] ACC;
reg E;
reg [7:0] R [15:0];
reg [10:0] PC;
reg [10:0] SSR;
reg [10:0] ISR;
reg [7:0] DC_latch;
assign DC_out = DC_latch[6:0];

assign PA = PC;
assign INT_ENA = DC_latch[7];

reg cycle;
reg [7:0] instr;

reg [8:0] logic_o;
always @(*) begin
	case(instr[2:0])
		0: logic_o = {ACC == 8'hFF, ACC + 1'b1};
		1: logic_o = {ACC == 8'h00, ACC - 1'b1};
`ifndef NO_BCD
		2: logic_o = {ACC == 8'b10011001, ACC[3:0] == 4'b1001 ? (ACC[7:4] == 4'b1001 ? 4'h0 : ACC[7:4] + 1'b1) : ACC[7:4], ACC[3:0] == 4'b1001 ? 4'h0 : ACC[3:0] + 1'b1};
		3: logic_o = {ACC == 0, ACC[3:0] == 4'h0 ? (ACC[7:4] == 4'h0 ? 4'b1001 : ACC[7:4] - 1'b1) : ACC[7:4], ACC[3:0] == 4'h0 ? 4'b1001 : ACC[3:0] - 1'b1};
`else
		default: logic_o = {E, ACC};
`endif
		4: logic_o = {E, 8'h00};
		5: logic_o = {E, ~ACC};
		6: logic_o = {E, 1'b0, ACC[7:1]};
		7: logic_o = {E, ACC[6:0], 1'b0};
	endcase
end

wire [7:0] mask = {instr[2:0] == 7, instr[2:0] == 6, instr[2:0] == 5, instr[2:0] == 4, instr[2:0] == 3, instr[2:0] == 2, instr[2:0] == 1, instr[2:0] == 0};
wire [7:0] inv_mask = ~mask;
wire [7:0] R0 = R[0];
wire [3:0] index = instr[3:0] | R0[3:0];

wire is_NOP = instr == 8'h5F;
wire is_INA = instr[7:4] == 4'b0100;
wire is_OTA = instr[7:4] == 4'b0101 && !is_NOP;
wire is_LDR = instr == 8'hCF;
wire is_OTR = instr[7:4] == 4'b1100 && !is_LDR;
wire io_op = is_OTR || is_INA || is_OTA;
wire io_out = is_OTA || is_OTR;

assign DS = cycle && io_op ? instr[3:0] : 4'hF;
assign RW = cycle && io_op ? io_out : 1'b0;
assign D_out = ACC;
assign D_oe = cycle && is_OTA;
assign PSG = (~(cycle && (is_INA || is_OTA))) & !clk;

wire mag_comp = instr[7:3] == 5'b00001;
wire is_skip = mag_comp || instr[7:4] == 4'b0001 || instr[7:4] == 4'b0011;

wire GT = ACC > R0;
wire LT = ACC < R0;
wire EQ = ACC == R0;
wire ZERO = ACC == 8'h00;
reg skip_cond_0;
always @(*) begin
	case(instr[2:0])
		0: skip_cond_0 = GT;
		1: skip_cond_0 = LT;
		2: skip_cond_0 = EQ;
		3: skip_cond_0 = ZERO;
		4: skip_cond_0 = LT || EQ;
		5: skip_cond_0 = GT || EQ;
		6: skip_cond_0 = !EQ;
		7: skip_cond_0 = !ZERO;
	endcase
end

wire is_SES = instr == 8'h1F;
wire is_SEZ = instr == 8'h3F;
wire should_skip =
	(mag_comp && skip_cond_0) ||
	(is_SES && E) ||
	(is_SEZ && !E) ||
	(instr[7:3] == 5'b00010 && !is_SES && (ACC & mask)) ||
	(instr[7:3] == 5'b00110 && !is_SES && !(ACC & mask)) ||
	(instr[7:3] == 5'b00011 && !is_SEZ && ({INT_ENA, DC_in} & mask)) ||
	(instr[7:3] == 5'b00111 && !is_SEZ && !({INT_ENA, DC_in} & mask));

`ifdef ADDITION
wire [8:0] add_res = {1'b0, ACC} + {1'b0, R[{1'b0, instr[2:0]}]} + {8'h00, E};
`endif

always @(posedge clk) begin
	INT_ACK <= 1'b0;
	if(rst) begin
		ACC <= 8'h00;
		PC <= 11'h000;
		E <= 1'b0;
		SSR <= 11'h000;
		ISR <= 11'h000;
		cycle <= 1'b0;
		DC_latch <= 8'h7F;
		instr <= 8'h04;
	end else begin
		cycle <= !cycle;
		if(cycle) begin
			if(instr[7:3] == 5'b00000) begin //Logic op
				ACC <= logic_o[7:0];
				E <= logic_o[8];
			end
			if(instr[6:3] == 4'b0100) begin //Clear bit, Set bit
				ACC <= instr[7] ? (ACC & inv_mask) : (ACC | mask);
			end
			if(instr[7:4] == 4'b0110) begin //LDA
				ACC <= R[instr[3:0]];
			end
			if(instr[7:4] == 4'b0111) begin //STA
				R[instr[3:0]] <= ACC;
			end
			if(instr[7:4] == 4'b1110) begin //LDI
				ACC <= R[index];
			end
			if(instr[7:4] == 4'b1111) begin //STI
				R[index] <= ACC;
			end
			if(instr[7:4] == 4'b1101) begin //Store constant, STR
				R[instr[3:0]] <= D_in;
				PC <= PC + 1;
			end
			if(is_LDR) begin //Constant to accumulator, LDR
				ACC <= D_in;
				PC <= PC + 1;
			end else if(is_OTR || is_LDR) begin //Output constant, OTR
				PC <= PC + 1; //No need to do anything more. The ROM is already outputting the correct data to the bus
			end
			if(is_OTA) begin
				//Nothing more to do here, actually
			end
			if(is_INA) begin //IO Read, INA
				ACC <= D_in;
			end
			if(instr[6:3] == 4'b0101) begin //Direct IOs, STC & CLC, Interrupt Enable
				DC_latch <= instr[7] ? (DC_latch & inv_mask) : (DC_latch | mask);
			end
			if(instr == 8'h90) begin //RTI
				PC <= ISR;
			end
`ifndef EVEN_MORE_MINIMAL
			if(instr == 8'hB0) begin //RTE
				PC <= ISR;
				DC_latch[7] <= 1'b1;
			end
`endif
`ifdef ADDITION
			if(instr == 8'hB6) begin
`else
`ifdef EVEN_MORE_MINIMAL
			if(instr[7:3] == 5'b10111) begin
`else
			if(instr == 8'hB8) begin //RTS
`endif
`endif
				PC <= SSR;
			end
`ifndef EVEN_MORE_MINIMAL
`ifdef ADDITION
			if(instr == 8'hB7) begin
`else
			if(instr == 8'hB9) begin //RSE
`endif
				PC <= SSR;
				DC_latch[7] <= 1'b1;
			end
`endif
`ifdef ADDITION
			if(instr[7:1] == 7'h5A) begin
`else
			if(instr[7:2] == 6'h2D) begin //STE, CLE
`endif
				E <= ~instr[0];
			end
			if(instr[7:4] == 4'b1000) begin //JMP, JSB
				PC <= {instr[2:0], D_in};
				if(instr[3]) SSR <= PC + 1;
			end
`ifndef EVEN_MORE_MINIMAL
			if(instr[7:4] == 4'b1001 && instr != 8'h90) begin //JAI, JAS
				PC <= {index[2:0], ACC};
				if(index[3]) SSR <= PC + 1;
			end
`endif
`ifdef ADDITION
			if(instr[7:3] == 5'b10111) begin
				ACC <= add_res[7:0];
				E <= add_res[8];
			end
`endif
			if(is_skip && should_skip) begin
				PC <= PC + 2;
			end
			if(!INT_REQ) begin
				INT_ACK <= 1'b1;
			end
		end else begin
			if(INT_ACK) begin
				cycle <= 1'b0;
				DC_latch[7] <= 1'b0;
				ISR <= PC;
				PC <= {3'b000, D_in};
			end else begin
				instr <= D_in;
				PC <= PC + 1;
			end
		end
	end
end

endmodule
