`default_nettype none

module blinker(
	input clk_i,
	output [2:0] io_out,
	input rst_n
);

reg slow_blink;
reg [22:0] counter;

assign io_out[0] = slow_blink;
assign io_out[1] = counter[2];

always @(posedge clk_i) begin
	if(!rst_n) begin
		counter <= 0;
		slow_blink <= 0;
	end else begin
		counter <= counter + 1;
		if(counter == 5000000) begin
			slow_blink <= !slow_blink;
			counter <= 0;
		end
	end
end


reg [5:0] PC;

reg [5:0] tune_ROM;
always @(*) begin
	case(PC)
	0: tune_ROM = 6'b000100;
	1: tune_ROM = 6'b011100;
	2: tune_ROM = 6'b011100;
	3: tune_ROM = 6'b011101;
	4: tune_ROM = 6'b011100;
	5: tune_ROM = 6'b011100;
	6: tune_ROM = 6'b011101;
	7: tune_ROM = 6'b011100;
	8: tune_ROM = 6'b100100;
	9: tune_ROM = 6'b010100;
	10: tune_ROM = 6'b011000;
	11: tune_ROM = 6'b011110;
	12: tune_ROM = 6'b100001;
	13: tune_ROM = 6'b100001;
	14: tune_ROM = 6'b100000;
	15: tune_ROM = 6'b011100;

	16: tune_ROM = 6'b011101;
	17: tune_ROM = 6'b100100;
	18: tune_ROM = 6'b100100;
	19: tune_ROM = 6'b100000;
	20: tune_ROM = 6'b011000;
	21: tune_ROM = 6'b010110;
	22: tune_ROM = 6'b011100;
	23: tune_ROM = 6'b100000;
	24: tune_ROM = 6'b100101;
	25: tune_ROM = 6'b100110;
	26: tune_ROM = 6'b101000;
	27: tune_ROM = 6'b101100;
	28: tune_ROM = 6'b110001;
	29: tune_ROM = 6'b110010;
	30: tune_ROM = 6'b011100;
	31: tune_ROM = 6'b100000;

	32: tune_ROM = 6'b100101;
	33: tune_ROM = 6'b100110;
	34: tune_ROM = 6'b101000;
	35: tune_ROM = 6'b100100;
	36: tune_ROM = 6'b100001;
	37: tune_ROM = 6'b100010;
	38: tune_ROM = 6'b011101;
	39: tune_ROM = 6'b100101;
	40: tune_ROM = 6'b010101;
	41: tune_ROM = 6'b011101;
	42: tune_ROM = 6'b011001;
	43: tune_ROM = 6'b100010;
	44: tune_ROM = 6'b010001;
	45: tune_ROM = 6'b010110;
	46: tune_ROM = 6'b001001;
	47: tune_ROM = 6'b010101;

	48: tune_ROM = 6'b010100;
	49: tune_ROM = 6'b011000;
	50: tune_ROM = 6'b010100;
	51: tune_ROM = 6'b010000;
	52: tune_ROM = 6'b001110;
	53: tune_ROM = 6'b011001;
	54: tune_ROM = 6'b011000;
	55: tune_ROM = 6'b011100;
	56: tune_ROM = 6'b011000;
	57: tune_ROM = 6'b010100;
	58: tune_ROM = 6'b010001;
	59: tune_ROM = 6'b001001;
	60: tune_ROM = 6'b001101;
	61: tune_ROM = 6'b011001;
	62: tune_ROM = 6'b010001;
	63: tune_ROM = 6'b010110;
	endcase
end

reg [6:0] scale_ROM;
always @(*) begin
	case(tune_ROM[5:2])
	0: scale_ROM = 7'b1111111;
	1: scale_ROM = 7'b1111111;
	2: scale_ROM = 7'b1001010;
	3: scale_ROM = 7'b0000101;
	4: scale_ROM = 7'b0100011;
	5: scale_ROM = 7'b0010010;
	6: scale_ROM = 7'b0110110;
	7: scale_ROM = 7'b1101101;
	
	8: scale_ROM = 7'b1111011;
	9: scale_ROM = 7'b0001101;
	10: scale_ROM = 7'b1011000;
	11: scale_ROM = 7'b0100101;
	12: scale_ROM = 7'b1101001;
	13: scale_ROM = 7'b1111111;
	14: scale_ROM = 7'b1111111;
	15: scale_ROM = 7'b1111111;
	endcase
end

reg [3:0] rhythm_ROM;
always @(*) begin
	case(tune_ROM[1:0])
		0: rhythm_ROM = 4'b0001;
		1: rhythm_ROM = 4'b0111;
		2: rhythm_ROM = 4'b1010;
		3: rhythm_ROM = 4'b0100;
	endcase
end

reg just_inc;
reg OP_reg;
wire OP = OP_reg & just_inc & (scale_ROM != 7'b1111111);
assign io_out[2] = OP;

reg [6:0] LFSR;
reg prev_clk_div;
reg [8:0] clock_div;
wire [8:0] next_clock_div = clock_div + 1;

reg [3:0] rhythm_LFSR;
reg [3:0] tempo_LFSR;

reg just_rst;

reg [6:0] master_clk_div;

always @(posedge clk_i) begin
	if(!rst_n) begin
		PC <= 0;
		LFSR <= 0;
		prev_clk_div <= 0;
		rhythm_LFSR <= 0;
		tempo_LFSR <= 0;
		OP_reg <= 0;
		clock_div <= 0;
		just_rst <= 1;
		just_inc <= 0;
		master_clk_div <= 0;
	end else if(master_clk_div == 92) begin
		master_clk_div <= 0;
		just_rst <= 0;
		clock_div <= next_clock_div;
		prev_clk_div <= clock_div[8];
		
		LFSR <= {LFSR[0] ^ LFSR[1], LFSR[6:1]};
		if(LFSR == 7'b1000000 || just_rst) begin
			OP_reg <= ~OP_reg;
			LFSR <= scale_ROM;
		end
		
		if((next_clock_div[8] && !prev_clk_div) || just_rst) begin
			rhythm_LFSR <= {rhythm_LFSR[0] ^ rhythm_LFSR[1], rhythm_LFSR[3:1]};
			if((rhythm_LFSR == 4'b1000) || just_rst) begin
				tempo_LFSR <= {tempo_LFSR[0] ^ tempo_LFSR[1], tempo_LFSR[3:1]};
				rhythm_LFSR <= rhythm_ROM;
				just_inc <= 1;
				if((tempo_LFSR == 4'b1000) || just_rst) begin
					tempo_LFSR <= 4'b1001;
					PC <= PC + 1;
					just_inc <= 0;
				end
			end
		end
	end else begin
		master_clk_div <= master_clk_div + 1'b1;
	end
end

endmodule
