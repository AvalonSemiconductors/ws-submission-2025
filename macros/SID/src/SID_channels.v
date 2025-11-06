/*
 * Implements a single SID tone + envelope generator
 * Takes config register values as inputs, outputs sample, as well as sync + ring triggers for the next channel
 */

`define ATTACK 'b01
`define DECAY_SUSTAIN 'b10
`define RELEASE 'b11

module SID_channels(
	input [15:0] freq1,
	input [15:0] freq2,
	input [15:0] freq3,
	input [11:0] pw1,
	input [11:0] pw2,
	input [11:0] pw3,
	input [7:0] ctrl_reg1,
	input [7:0] ctrl_reg2,
	input [7:0] ctrl_reg3,
	input [7:0] atk_dec1,
	input [7:0] atk_dec2,
	input [7:0] atk_dec3,
	input [7:0] sus_rel1,
	input [7:0] sus_rel2,
	input [7:0] sus_rel3,
	
	input clk,
	input rst,
	
	output [11:0] sample1,
	output [11:0] sample2,
	output [11:0] sample3,
	
	output [7:0] ch3_env
);

reg [11:0] samples [2:0];
assign sample1 = samples[0];
assign sample2 = samples[1];
assign sample3 = samples[2];

reg ring_outs [2:0];
reg sync_outs [2:0];
reg [2:0] clk_div;
wire [1:0] curr_channel = clk_div[2:1];

reg [15:0] curr_freq;
reg [11:0] curr_pw;
reg [7:0] curr_ctrl_reg;
reg [7:0] curr_atk_dec;
reg [7:0] curr_sus_rel;
reg curr_ring_in;
reg curr_sync_in;
always @(*) begin
	case(curr_channel)
		0: begin
			curr_freq = freq1;
			curr_pw = pw1;
			curr_ctrl_reg = ctrl_reg1;
			curr_atk_dec = atk_dec1;
			curr_sus_rel = sus_rel1;
			curr_ring_in = ring_outs[2];
			curr_sync_in = sync_outs[2];
		end
		1: begin
			curr_freq = freq2;
			curr_pw = pw2;
			curr_ctrl_reg = ctrl_reg2;
			curr_atk_dec = atk_dec2;
			curr_sus_rel = sus_rel2;
			curr_ring_in = ring_outs[0];
			curr_sync_in = sync_outs[0];
		end
		2: begin
			curr_freq = freq3;
			curr_pw = pw3;
			curr_ctrl_reg = ctrl_reg3;
			curr_atk_dec = atk_dec3;
			curr_sus_rel = sus_rel3;
			curr_ring_in = ring_outs[1];
			curr_sync_in = sync_outs[1];
		end
		3: begin
			curr_freq = 0;
			curr_pw = 0;
			curr_ctrl_reg = 0;
			curr_atk_dec = 0;
			curr_sus_rel = 0;
			curr_ring_in = 0;
			curr_sync_in = 0;
		end
	endcase
end

/*
 * Extract individual config options from the registers
*/
wire noise    = curr_ctrl_reg[7];
wire square   = curr_ctrl_reg[6];
wire sawtooth = curr_ctrl_reg[5];
wire triangle = curr_ctrl_reg[4];
wire test     = curr_ctrl_reg[3];
wire ringm    = curr_ctrl_reg[2];
wire sync     = curr_ctrl_reg[1];
wire gate     = curr_ctrl_reg[0];

wire [3:0] attack  = curr_atk_dec[7:4];
wire [3:0] decay   = curr_atk_dec[3:0];
wire [3:0] sustain = curr_sus_rel[7:4];
wire [3:0] releas  = curr_sus_rel[3:0];

/*
 * Tone generator registers
 * lfsr is for random noise
 * accum is the Accumulator, used to generate the periodic signals
 * sample_buff simply buffers the current sample
*/
reg [22:0] lfsr [2:0];
reg [23:0] accum [2:0];

//Compute next lfsr state, and increment accum according to the set frequency
wire lfsr_next = (lfsr[curr_channel][22] ^ lfsr[curr_channel][17]) | test;
wire [23:0] accum_next = accum[curr_channel] + {8'h00, curr_freq};

/*
 * Calculate samples for all tone types
 * Noise is taken from the lfsr value
 * Pulse is high if the Accumulator surpases the configured pulse-width
 * Saw simply is a couple bits of the accumulator value, counting up until wrap-around
 * Triangle is generated similarly to saw, but conditionally inverted using an XOR op if the most-significant bit of accum is 1
 * Lastly, the ring-mod trigger from the previous channel is also applied to invert the triangle sample, through another XOR
*/
wire [7:0] noise_sample = {lfsr[curr_channel][20], lfsr[curr_channel][18], lfsr[curr_channel][14], lfsr[curr_channel][11], lfsr[curr_channel][9], lfsr[curr_channel][5], lfsr[curr_channel][2], lfsr[curr_channel][0]};
wire pulse_sample = accum[curr_channel][23:12] >= curr_pw;
wire [11:0] saw_sample = accum[curr_channel][23:12];
wire [11:0] triangle_sample = {accum[curr_channel][22:12], 1'b0} ^ {12{accum[curr_channel][23]}} ^ {12{ringm && curr_ring_in}};

/*
 * Compute final sample by mixing all the enabled tones using ANDs
*/
wire [11:0] osc_sample = 
	(square ? {12{pulse_sample}} : 12'hFFF) &
	(sawtooth ? saw_sample : 12'hFFF) &
	(triangle ? triangle_sample : 12'hFFF) &
	(noise ? {noise_sample, 4'b0} : 12'hFFF);
	
/*
 * Envelope generator regs and signals
*/
reg [7:0] env_vol [2:0];
reg [4:0] exp_counter [2:0];
reg [14:0] env_counter [2:0];
reg [1:0] adsr_state [2:0];
assign ch3_env = env_vol[2];

wire [7:0] env_vol_curr = env_vol[curr_channel];

reg [4:0] exp_periods [2:0];
wire [4:0] exp_period = exp_periods[curr_channel];

//For the non-linear curves
wire [3:0] table_ptr = adsr_state[curr_channel] == `ATTACK ? attack : (adsr_state[curr_channel] == `DECAY_SUSTAIN ? decay : releas);
reg [14:0] adsr_table;
always @(*) begin
	case(table_ptr)
	0:  adsr_table = 8;
	1:  adsr_table = 31;
	2:  adsr_table = 62;
	3:  adsr_table = 94;
	4:  adsr_table = 148;
	5:  adsr_table = 219;
	6:  adsr_table = 266;
	7:  adsr_table = 312;
	8:  adsr_table = 391;
	9:  adsr_table = 976;
	10: adsr_table = 1953;
	11: adsr_table = 3125;
	12: adsr_table = 3906;
	13: adsr_table = 11719;
	14: adsr_table = 19531;
	15: adsr_table = 31250;
	endcase
end

//Sample with the envelope applied
wire [19:0] mul_sample = osc_sample * env_vol[curr_channel]; 

wire env_top = env_counter[curr_channel] == adsr_table;

always @(posedge clk) begin
	if(rst) begin
		lfsr[0]        <= 23'h7fffff;
		lfsr[1]        <= 23'h7fffff;
		lfsr[2]        <= 23'h7fffff;
		accum[0]       <= 24'h555555;
		accum[1]       <= 24'h555555;
		accum[2]       <= 24'h555555;
		adsr_state[0]  <= `RELEASE;
		adsr_state[1]  <= `RELEASE;
		adsr_state[2]  <= `RELEASE;
		exp_counter[0] <= 0;
		exp_counter[1] <= 0;
		exp_counter[2] <= 0;
		env_counter[0] <= 0;
		env_counter[1] <= 0;
		env_counter[2] <= 0;
		env_vol[0]     <= 0;
		env_vol[1]     <= 0;
		env_vol[2]     <= 0;
		ring_outs[0]   <= 0;
		ring_outs[1]   <= 0;
		ring_outs[2]   <= 0;
		sync_outs[0]   <= 0;
		sync_outs[1]   <= 0;
		sync_outs[2]   <= 0;
		samples[0]     <= 0;
		samples[1]     <= 0;
		samples[2]     <= 0;
		clk_div        <= 3'h0;
		exp_periods[0] <= 5'h01;
		exp_periods[1] <= 5'h01;
		exp_periods[2] <= 5'h01;
	end else begin
		clk_div <= clk_div + 1;
		if(curr_channel != 3 && clk_div[0] == 1'b0) begin
			sync_outs[curr_channel] <= !accum[curr_channel][23] && accum_next[23];
			ring_outs[curr_channel] <= accum[curr_channel][23];
			
			/*
			* Accumulator + LFSR
			*/
			samples[curr_channel] <= mul_sample[19:8];
			accum[curr_channel]  <= (sync && curr_sync_in) || test ? 0 : accum_next;
			if(!test && !accum[curr_channel][19] && accum_next[19]) begin
				lfsr[curr_channel][22:1] <= lfsr[curr_channel][21:0];
				lfsr[curr_channel][0] <= lfsr_next;
			end
			/*
			* Envelope update
			*/
			exp_counter[curr_channel] <= exp_counter[curr_channel] == exp_period ? 0 : exp_counter[curr_channel] + 1;
			if(exp_counter[curr_channel] == 0 || adsr_state[curr_channel] == `ATTACK) begin
				env_counter[curr_channel] <= env_counter[curr_channel] + 1;
			end

			if(env_top) env_counter[curr_channel] <= 0;
			if(!gate) adsr_state[curr_channel] <= `RELEASE;
			
			case(adsr_state[curr_channel])
				`ATTACK: begin
					if(env_top) env_vol[curr_channel] <= env_vol[curr_channel] + 1;
					if(env_vol[curr_channel] == 255) adsr_state[curr_channel] <= `DECAY_SUSTAIN;
				end
				
				`DECAY_SUSTAIN: begin
					if(env_top && env_vol[curr_channel] != {sustain, sustain}) env_vol[curr_channel] <= env_vol[curr_channel] - 1;
				end
				
				`RELEASE: begin
					if(env_top && env_vol[curr_channel] != 0) env_vol[curr_channel] <= env_vol[curr_channel] - 1;
					
					if(gate) begin
						adsr_state[curr_channel] <= `ATTACK;
					end
				end
			endcase
		end else if(curr_channel != 3 && clk_div[0] == 1'b1) begin
			case(env_vol[curr_channel])
				8'hFF: exp_periods[curr_channel] <= 5'h01;
				8'h5D: exp_periods[curr_channel] <= 5'h02;
				8'h36: exp_periods[curr_channel] <= 5'h04;
				8'h1A: exp_periods[curr_channel] <= 5'h08;
				8'h0E: exp_periods[curr_channel] <= 5'h10;
				8'h06: exp_periods[curr_channel] <= 5'h1E;
				8'h00: exp_periods[curr_channel] <= 5'h01;
				default: exp_periods[curr_channel] <= exp_periods[curr_channel];
			endcase
		end
	end
end

endmodule
