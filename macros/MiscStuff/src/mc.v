`default_nettype none

module mc(
	input clk_i,
	input rst_n,
	input loader_en,
	input run,
	input load,
	input preload_en,
	input [7:0] port_in,
	output reg [7:0] port_out,
	input [7:0] load_in,
	output [7:0] preload_addr,
	output preload_act_n,
	output [3:0] extra_out
);

reg [7:0] PC;
reg [7:0] A;
reg [7:0] memory [63:0];
reg [3:0] ireg;
reg [7:0] input_buffered;
assign extra_out = ireg;

wire is_branch = ireg[2:0] == 3'b101;
wire is_store = ireg == 4'h4;
wire is_out = ireg == 4'hC;
wire is_in = ireg == 4'h8;
wire should_branch = (A == 0) | ireg[3];

reg load_edge;
reg state;
reg preloading;
assign preload_act_n = !preloading;
assign preload_addr = PC;

wire [7:0] ALU_in_1 = is_branch ? PC : A;
wire [7:0] ALU_in_2 = ireg[3] || is_branch ? memory[PC] : memory[memory[PC]];
reg [7:0] ALU_out;
always @(*) begin
	case(ireg[2:0])
		0: ALU_out = ~ALU_in_1;
		1: ALU_out = ALU_in_1 - ALU_in_2;
		2: ALU_out = ALU_in_1 + ALU_in_2;
		3: ALU_out = ALU_in_1 | ALU_in_2;
		5: ALU_out = ALU_in_1 + ALU_in_2;
		6: ALU_out = ALU_in_1 & ALU_in_2;
		default: ALU_out = ALU_in_2;
	endcase
end

always @(posedge clk_i) begin
	if(!rst_n) begin
		PC <= 0;
		A <= 0;
		load_edge <= 0;
		ireg <= 0;
		state <= 0;
		preloading <= preload_en;
		input_buffered <= 0;
	end else begin
		load_edge <= load;
		if(preloading) begin
			PC <= PC + 1;
			memory[PC] <= load_in;
			if(PC == 63) begin
				PC <= 0;
				preloading <= 0;
			end
		end else if(loader_en) begin
			if(load && !load_edge) begin
				memory[PC] <= load_in;
				PC <= PC + 1;
			end
		end else if(run) begin
			PC <= PC + 1;
			state <= !state;
			if(state) begin
				if(is_branch) begin
					if(should_branch) PC <= ALU_out;
				end else if(is_store) memory[memory[PC]] <= A;
				else if(is_out) port_out <= A;
				else if(is_in) A <= input_buffered;
				else A <= ALU_out;
			end else begin
				ireg <= memory[PC][3:0];
				input_buffered <= port_in;
			end
		end
	end
end

endmodule
