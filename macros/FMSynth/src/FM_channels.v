/*
 * Implements a single SID tone + envelope generator
 * Takes config register values as inputs, outputs sample, as well as sync + ring triggers for the next channel
 */

`define ATTACK 'b01
`define DECAY_SUSTAIN 'b10
`define RELEASE 'b11

module FM_channels #(parameter has_fm = 1) (
	input [15:0] freq1,
	input [15:0] freq2,
	input [15:0] freq3,
	input [11:0] pw1,
	input [11:0] pw2,
	input [11:0] pw3,
	input [7:0] ctrl_reg1,
	input [7:0] ctrl_reg2,
	input [7:0] ctrl_reg3,
	input [7:0] ctrl2_reg1,
	input [7:0] ctrl2_reg2,
	input [7:0] ctrl2_reg3,
	input [7:0] atk_dec1,
	input [7:0] atk_dec2,
	input [7:0] atk_dec3,
	input [7:0] sus_rel1,
	input [7:0] sus_rel2,
	input [7:0] sus_rel3,
	input [7:0] volume1,
	input [7:0] volume2,
	input [7:0] volume3,
	
	input [11:0] fm1,
	input [11:0] fm2,
	input [11:0] fm3,
	
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
reg [7:0] curr_volume;
reg [7:0] curr_ctrl2_reg;
reg [11:0] curr_fm;
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
			curr_volume = volume1;
			curr_ctrl2_reg = ctrl2_reg1;
			curr_fm = fm1;
		end
		1: begin
			curr_freq = freq2;
			curr_pw = pw2;
			curr_ctrl_reg = ctrl_reg2;
			curr_atk_dec = atk_dec2;
			curr_sus_rel = sus_rel2;
			curr_ring_in = ring_outs[0];
			curr_sync_in = sync_outs[0];
			curr_volume = volume2;
			curr_ctrl2_reg = ctrl2_reg2;
			curr_fm = fm2;
		end
		2: begin
			curr_freq = freq3;
			curr_pw = pw3;
			curr_ctrl_reg = ctrl_reg3;
			curr_atk_dec = atk_dec3;
			curr_sus_rel = sus_rel3;
			curr_ring_in = ring_outs[1];
			curr_sync_in = sync_outs[1];
			curr_volume = volume3;
			curr_ctrl2_reg = ctrl2_reg3;
			curr_fm = fm3;
		end
		3: begin
			curr_freq = 0;
			curr_pw = 0;
			curr_ctrl_reg = 0;
			curr_atk_dec = 0;
			curr_sus_rel = 0;
			curr_ring_in = 0;
			curr_sync_in = 0;
			curr_volume = 0;
			curr_ctrl2_reg = 0;
			curr_fm = 0;
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
wire sine     = curr_ctrl2_reg[0];
wire [3:0] sine_src = curr_ctrl2_reg[4:1];

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

/*
 * Calculate samples for all tone types
 * Noise is taken from the lfsr value
 * Sine is taken from a LUT
 * Pulse is high if the Accumulator surpases the configured pulse-width
 * Saw simply is a couple bits of the accumulator value, counting up until wrap-around
 * Triangle is generated similarly to saw, but conditionally inverted using an XOR op if the most-significant bit of accum is 1
 * Lastly, the ring-mod trigger from the previous channel is also applied to invert the triangle sample, through another XOR
*/
wire [7:0] noise_sample = {lfsr[curr_channel][20], lfsr[curr_channel][18], lfsr[curr_channel][14], lfsr[curr_channel][11], lfsr[curr_channel][9], lfsr[curr_channel][5], lfsr[curr_channel][2], lfsr[curr_channel][0]};
wire pulse_sample = accum[curr_channel][23:12] >= curr_pw;
wire [11:0] saw_sample = accum[curr_channel][23:12];
wire [11:0] triangle_sample = {accum[curr_channel][22:12], 1'b0} ^ {12{accum[curr_channel][23]}} ^ {12{ringm && curr_ring_in}};
reg [10:0] quarter_sine;
wire [11:0] sine_idx_sel =
	(sine_src[0] ? {12{pulse_sample}} : 12'hFFF) &
	(sine_src[1] ? saw_sample : 12'hFFF) &
	(sine_src[2] ? triangle_sample : 12'hFFF) &
	(sine_src[3] ? noise_sample : 12'hFFF);
wire [9:0] sine_idx = sine_idx_sel[10] ? 10'h3FF - sine_idx_sel[9:0] : sine_idx_sel[9:0];
wire [11:0] sine_sample = sine_idx_sel[11] ? 2048 - quarter_sine : 2048 + quarter_sine;

/*
 * Compute final sample by mixing all the enabled tones using ANDs
*/
wire [11:0] osc_sample = 
	(square ? {12{pulse_sample}} : 12'hFFF) &
	(sawtooth ? saw_sample : 12'hFFF) &
	(triangle ? triangle_sample : 12'hFFF) &
	(noise ? noise_sample : 12'hFFF) &
	(sine ? sine_sample : 12'hFFF);
	
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

`ifdef SIM
wire [19:0] mul_sample = osc_sample * env_vol[curr_channel]; 
wire [11:0] enveloped_sample = mul_sample[19:8];
wire [19:0] vol_sample = enveloped_sample * curr_volume;
`else
wire [19:0] mul_sample;
bad_multiplier mul1(
	.a(osc_sample),
	.b(env_vol[curr_channel]),
	.o(mul_sample)
);
wire [11:0] enveloped_sample = mul_sample[19:8];
wire [19:0] vol_sample;
bad_multiplier mul2(
	.a(enveloped_sample),
	.b(curr_volume),
	.o(vol_sample)
);
`endif

wire [17:0] freq_adjusted;
generate
	if(has_fm == 0) begin
		assign freq_adjusted = {2'b00, curr_freq};
	end else begin
		//Sample with the envelope applied
		`ifdef SIM
		wire [31:0] freq_multiplied = curr_freq * {curr_fm, 4'h0};
		`else
		wire [31:0] freq_multiplied;
		bad_multiplier_2 mul3(
			.a(curr_freq),
			.b({curr_fm, 4'h0}),
			.o(freq_multiplied)
		);
		`endif
		assign freq_adjusted = curr_freq + freq_multiplied[31:16] + freq_multiplied[31:16] + freq_multiplied[31:16];
	end
endgenerate

//Compute next lfsr state, and increment accum according to the set frequency
wire lfsr_next = (lfsr[curr_channel][22] ^ lfsr[curr_channel][17]) | test;
wire [23:0] accum_next = accum[curr_channel] + {6'h00, freq_adjusted};

wire env_top = env_counter[curr_channel] == adsr_table;

`ifdef SIM
integer wave_test = 0;
`endif

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
		`ifdef SIM
		if(curr_channel == 0) wave_test <= freq_adjusted;
		`endif
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

always @(*) begin
	case(sine_idx)
		0: quarter_sine = 12'd0;
		1: quarter_sine = 12'd3;
		2: quarter_sine = 12'd6;
		3: quarter_sine = 12'd9;
		4: quarter_sine = 12'd12;
		5: quarter_sine = 12'd15;
		6: quarter_sine = 12'd18;
		7: quarter_sine = 12'd21;
		8: quarter_sine = 12'd25;
		9: quarter_sine = 12'd28;
		10: quarter_sine = 12'd31;
		11: quarter_sine = 12'd34;
		12: quarter_sine = 12'd37;
		13: quarter_sine = 12'd40;
		14: quarter_sine = 12'd43;
		15: quarter_sine = 12'd47;
		16: quarter_sine = 12'd50;
		17: quarter_sine = 12'd53;
		18: quarter_sine = 12'd56;
		19: quarter_sine = 12'd59;
		20: quarter_sine = 12'd62;
		21: quarter_sine = 12'd65;
		22: quarter_sine = 12'd69;
		23: quarter_sine = 12'd72;
		24: quarter_sine = 12'd75;
		25: quarter_sine = 12'd78;
		26: quarter_sine = 12'd81;
		27: quarter_sine = 12'd84;
		28: quarter_sine = 12'd87;
		29: quarter_sine = 12'd91;
		30: quarter_sine = 12'd94;
		31: quarter_sine = 12'd97;
		32: quarter_sine = 12'd100;
		33: quarter_sine = 12'd103;
		34: quarter_sine = 12'd106;
		35: quarter_sine = 12'd109;
		36: quarter_sine = 12'd113;
		37: quarter_sine = 12'd116;
		38: quarter_sine = 12'd119;
		39: quarter_sine = 12'd122;
		40: quarter_sine = 12'd125;
		41: quarter_sine = 12'd128;
		42: quarter_sine = 12'd131;
		43: quarter_sine = 12'd134;
		44: quarter_sine = 12'd138;
		45: quarter_sine = 12'd141;
		46: quarter_sine = 12'd144;
		47: quarter_sine = 12'd147;
		48: quarter_sine = 12'd150;
		49: quarter_sine = 12'd153;
		50: quarter_sine = 12'd156;
		51: quarter_sine = 12'd160;
		52: quarter_sine = 12'd163;
		53: quarter_sine = 12'd166;
		54: quarter_sine = 12'd169;
		55: quarter_sine = 12'd172;
		56: quarter_sine = 12'd175;
		57: quarter_sine = 12'd178;
		58: quarter_sine = 12'd181;
		59: quarter_sine = 12'd185;
		60: quarter_sine = 12'd188;
		61: quarter_sine = 12'd191;
		62: quarter_sine = 12'd194;
		63: quarter_sine = 12'd197;
		64: quarter_sine = 12'd200;
		65: quarter_sine = 12'd203;
		66: quarter_sine = 12'd206;
		67: quarter_sine = 12'd210;
		68: quarter_sine = 12'd213;
		69: quarter_sine = 12'd216;
		70: quarter_sine = 12'd219;
		71: quarter_sine = 12'd222;
		72: quarter_sine = 12'd225;
		73: quarter_sine = 12'd228;
		74: quarter_sine = 12'd231;
		75: quarter_sine = 12'd235;
		76: quarter_sine = 12'd238;
		77: quarter_sine = 12'd241;
		78: quarter_sine = 12'd244;
		79: quarter_sine = 12'd247;
		80: quarter_sine = 12'd250;
		81: quarter_sine = 12'd253;
		82: quarter_sine = 12'd256;
		83: quarter_sine = 12'd260;
		84: quarter_sine = 12'd263;
		85: quarter_sine = 12'd266;
		86: quarter_sine = 12'd269;
		87: quarter_sine = 12'd272;
		88: quarter_sine = 12'd275;
		89: quarter_sine = 12'd278;
		90: quarter_sine = 12'd281;
		91: quarter_sine = 12'd284;
		92: quarter_sine = 12'd288;
		93: quarter_sine = 12'd291;
		94: quarter_sine = 12'd294;
		95: quarter_sine = 12'd297;
		96: quarter_sine = 12'd300;
		97: quarter_sine = 12'd303;
		98: quarter_sine = 12'd306;
		99: quarter_sine = 12'd309;
		100: quarter_sine = 12'd312;
		101: quarter_sine = 12'd316;
		102: quarter_sine = 12'd319;
		103: quarter_sine = 12'd322;
		104: quarter_sine = 12'd325;
		105: quarter_sine = 12'd328;
		106: quarter_sine = 12'd331;
		107: quarter_sine = 12'd334;
		108: quarter_sine = 12'd337;
		109: quarter_sine = 12'd340;
		110: quarter_sine = 12'd343;
		111: quarter_sine = 12'd347;
		112: quarter_sine = 12'd350;
		113: quarter_sine = 12'd353;
		114: quarter_sine = 12'd356;
		115: quarter_sine = 12'd359;
		116: quarter_sine = 12'd362;
		117: quarter_sine = 12'd365;
		118: quarter_sine = 12'd368;
		119: quarter_sine = 12'd371;
		120: quarter_sine = 12'd374;
		121: quarter_sine = 12'd377;
		122: quarter_sine = 12'd381;
		123: quarter_sine = 12'd384;
		124: quarter_sine = 12'd387;
		125: quarter_sine = 12'd390;
		126: quarter_sine = 12'd393;
		127: quarter_sine = 12'd396;
		128: quarter_sine = 12'd399;
		129: quarter_sine = 12'd402;
		130: quarter_sine = 12'd405;
		131: quarter_sine = 12'd408;
		132: quarter_sine = 12'd411;
		133: quarter_sine = 12'd414;
		134: quarter_sine = 12'd418;
		135: quarter_sine = 12'd421;
		136: quarter_sine = 12'd424;
		137: quarter_sine = 12'd427;
		138: quarter_sine = 12'd430;
		139: quarter_sine = 12'd433;
		140: quarter_sine = 12'd436;
		141: quarter_sine = 12'd439;
		142: quarter_sine = 12'd442;
		143: quarter_sine = 12'd445;
		144: quarter_sine = 12'd448;
		145: quarter_sine = 12'd451;
		146: quarter_sine = 12'd454;
		147: quarter_sine = 12'd457;
		148: quarter_sine = 12'd460;
		149: quarter_sine = 12'd464;
		150: quarter_sine = 12'd467;
		151: quarter_sine = 12'd470;
		152: quarter_sine = 12'd473;
		153: quarter_sine = 12'd476;
		154: quarter_sine = 12'd479;
		155: quarter_sine = 12'd482;
		156: quarter_sine = 12'd485;
		157: quarter_sine = 12'd488;
		158: quarter_sine = 12'd491;
		159: quarter_sine = 12'd494;
		160: quarter_sine = 12'd497;
		161: quarter_sine = 12'd500;
		162: quarter_sine = 12'd503;
		163: quarter_sine = 12'd506;
		164: quarter_sine = 12'd509;
		165: quarter_sine = 12'd512;
		166: quarter_sine = 12'd515;
		167: quarter_sine = 12'd518;
		168: quarter_sine = 12'd521;
		169: quarter_sine = 12'd525;
		170: quarter_sine = 12'd528;
		171: quarter_sine = 12'd531;
		172: quarter_sine = 12'd534;
		173: quarter_sine = 12'd537;
		174: quarter_sine = 12'd540;
		175: quarter_sine = 12'd543;
		176: quarter_sine = 12'd546;
		177: quarter_sine = 12'd549;
		178: quarter_sine = 12'd552;
		179: quarter_sine = 12'd555;
		180: quarter_sine = 12'd558;
		181: quarter_sine = 12'd561;
		182: quarter_sine = 12'd564;
		183: quarter_sine = 12'd567;
		184: quarter_sine = 12'd570;
		185: quarter_sine = 12'd573;
		186: quarter_sine = 12'd576;
		187: quarter_sine = 12'd579;
		188: quarter_sine = 12'd582;
		189: quarter_sine = 12'd585;
		190: quarter_sine = 12'd588;
		191: quarter_sine = 12'd591;
		192: quarter_sine = 12'd594;
		193: quarter_sine = 12'd597;
		194: quarter_sine = 12'd600;
		195: quarter_sine = 12'd603;
		196: quarter_sine = 12'd606;
		197: quarter_sine = 12'd609;
		198: quarter_sine = 12'd612;
		199: quarter_sine = 12'd615;
		200: quarter_sine = 12'd618;
		201: quarter_sine = 12'd621;
		202: quarter_sine = 12'd624;
		203: quarter_sine = 12'd627;
		204: quarter_sine = 12'd630;
		205: quarter_sine = 12'd633;
		206: quarter_sine = 12'd636;
		207: quarter_sine = 12'd639;
		208: quarter_sine = 12'd642;
		209: quarter_sine = 12'd645;
		210: quarter_sine = 12'd648;
		211: quarter_sine = 12'd651;
		212: quarter_sine = 12'd654;
		213: quarter_sine = 12'd657;
		214: quarter_sine = 12'd660;
		215: quarter_sine = 12'd663;
		216: quarter_sine = 12'd666;
		217: quarter_sine = 12'd669;
		218: quarter_sine = 12'd672;
		219: quarter_sine = 12'd675;
		220: quarter_sine = 12'd678;
		221: quarter_sine = 12'd681;
		222: quarter_sine = 12'd684;
		223: quarter_sine = 12'd686;
		224: quarter_sine = 12'd689;
		225: quarter_sine = 12'd692;
		226: quarter_sine = 12'd695;
		227: quarter_sine = 12'd698;
		228: quarter_sine = 12'd701;
		229: quarter_sine = 12'd704;
		230: quarter_sine = 12'd707;
		231: quarter_sine = 12'd710;
		232: quarter_sine = 12'd713;
		233: quarter_sine = 12'd716;
		234: quarter_sine = 12'd719;
		235: quarter_sine = 12'd722;
		236: quarter_sine = 12'd725;
		237: quarter_sine = 12'd728;
		238: quarter_sine = 12'd731;
		239: quarter_sine = 12'd734;
		240: quarter_sine = 12'd737;
		241: quarter_sine = 12'd739;
		242: quarter_sine = 12'd742;
		243: quarter_sine = 12'd745;
		244: quarter_sine = 12'd748;
		245: quarter_sine = 12'd751;
		246: quarter_sine = 12'd754;
		247: quarter_sine = 12'd757;
		248: quarter_sine = 12'd760;
		249: quarter_sine = 12'd763;
		250: quarter_sine = 12'd766;
		251: quarter_sine = 12'd769;
		252: quarter_sine = 12'd772;
		253: quarter_sine = 12'd775;
		254: quarter_sine = 12'd777;
		255: quarter_sine = 12'd780;
		256: quarter_sine = 12'd783;
		257: quarter_sine = 12'd786;
		258: quarter_sine = 12'd789;
		259: quarter_sine = 12'd792;
		260: quarter_sine = 12'd795;
		261: quarter_sine = 12'd798;
		262: quarter_sine = 12'd801;
		263: quarter_sine = 12'd804;
		264: quarter_sine = 12'd806;
		265: quarter_sine = 12'd809;
		266: quarter_sine = 12'd812;
		267: quarter_sine = 12'd815;
		268: quarter_sine = 12'd818;
		269: quarter_sine = 12'd821;
		270: quarter_sine = 12'd824;
		271: quarter_sine = 12'd827;
		272: quarter_sine = 12'd829;
		273: quarter_sine = 12'd832;
		274: quarter_sine = 12'd835;
		275: quarter_sine = 12'd838;
		276: quarter_sine = 12'd841;
		277: quarter_sine = 12'd844;
		278: quarter_sine = 12'd847;
		279: quarter_sine = 12'd849;
		280: quarter_sine = 12'd852;
		281: quarter_sine = 12'd855;
		282: quarter_sine = 12'd858;
		283: quarter_sine = 12'd861;
		284: quarter_sine = 12'd864;
		285: quarter_sine = 12'd867;
		286: quarter_sine = 12'd869;
		287: quarter_sine = 12'd872;
		288: quarter_sine = 12'd875;
		289: quarter_sine = 12'd878;
		290: quarter_sine = 12'd881;
		291: quarter_sine = 12'd884;
		292: quarter_sine = 12'd886;
		293: quarter_sine = 12'd889;
		294: quarter_sine = 12'd892;
		295: quarter_sine = 12'd895;
		296: quarter_sine = 12'd898;
		297: quarter_sine = 12'd901;
		298: quarter_sine = 12'd903;
		299: quarter_sine = 12'd906;
		300: quarter_sine = 12'd909;
		301: quarter_sine = 12'd912;
		302: quarter_sine = 12'd915;
		303: quarter_sine = 12'd917;
		304: quarter_sine = 12'd920;
		305: quarter_sine = 12'd923;
		306: quarter_sine = 12'd926;
		307: quarter_sine = 12'd929;
		308: quarter_sine = 12'd932;
		309: quarter_sine = 12'd934;
		310: quarter_sine = 12'd937;
		311: quarter_sine = 12'd940;
		312: quarter_sine = 12'd943;
		313: quarter_sine = 12'd945;
		314: quarter_sine = 12'd948;
		315: quarter_sine = 12'd951;
		316: quarter_sine = 12'd954;
		317: quarter_sine = 12'd957;
		318: quarter_sine = 12'd959;
		319: quarter_sine = 12'd962;
		320: quarter_sine = 12'd965;
		321: quarter_sine = 12'd968;
		322: quarter_sine = 12'd970;
		323: quarter_sine = 12'd973;
		324: quarter_sine = 12'd976;
		325: quarter_sine = 12'd979;
		326: quarter_sine = 12'd982;
		327: quarter_sine = 12'd984;
		328: quarter_sine = 12'd987;
		329: quarter_sine = 12'd990;
		330: quarter_sine = 12'd993;
		331: quarter_sine = 12'd995;
		332: quarter_sine = 12'd998;
		333: quarter_sine = 12'd1001;
		334: quarter_sine = 12'd1003;
		335: quarter_sine = 12'd1006;
		336: quarter_sine = 12'd1009;
		337: quarter_sine = 12'd1012;
		338: quarter_sine = 12'd1014;
		339: quarter_sine = 12'd1017;
		340: quarter_sine = 12'd1020;
		341: quarter_sine = 12'd1023;
		342: quarter_sine = 12'd1025;
		343: quarter_sine = 12'd1028;
		344: quarter_sine = 12'd1031;
		345: quarter_sine = 12'd1033;
		346: quarter_sine = 12'd1036;
		347: quarter_sine = 12'd1039;
		348: quarter_sine = 12'd1042;
		349: quarter_sine = 12'd1044;
		350: quarter_sine = 12'd1047;
		351: quarter_sine = 12'd1050;
		352: quarter_sine = 12'd1052;
		353: quarter_sine = 12'd1055;
		354: quarter_sine = 12'd1058;
		355: quarter_sine = 12'd1060;
		356: quarter_sine = 12'd1063;
		357: quarter_sine = 12'd1066;
		358: quarter_sine = 12'd1069;
		359: quarter_sine = 12'd1071;
		360: quarter_sine = 12'd1074;
		361: quarter_sine = 12'd1077;
		362: quarter_sine = 12'd1079;
		363: quarter_sine = 12'd1082;
		364: quarter_sine = 12'd1085;
		365: quarter_sine = 12'd1087;
		366: quarter_sine = 12'd1090;
		367: quarter_sine = 12'd1093;
		368: quarter_sine = 12'd1095;
		369: quarter_sine = 12'd1098;
		370: quarter_sine = 12'd1100;
		371: quarter_sine = 12'd1103;
		372: quarter_sine = 12'd1106;
		373: quarter_sine = 12'd1108;
		374: quarter_sine = 12'd1111;
		375: quarter_sine = 12'd1114;
		376: quarter_sine = 12'd1116;
		377: quarter_sine = 12'd1119;
		378: quarter_sine = 12'd1122;
		379: quarter_sine = 12'd1124;
		380: quarter_sine = 12'd1127;
		381: quarter_sine = 12'd1129;
		382: quarter_sine = 12'd1132;
		383: quarter_sine = 12'd1135;
		384: quarter_sine = 12'd1137;
		385: quarter_sine = 12'd1140;
		386: quarter_sine = 12'd1143;
		387: quarter_sine = 12'd1145;
		388: quarter_sine = 12'd1148;
		389: quarter_sine = 12'd1150;
		390: quarter_sine = 12'd1153;
		391: quarter_sine = 12'd1156;
		392: quarter_sine = 12'd1158;
		393: quarter_sine = 12'd1161;
		394: quarter_sine = 12'd1163;
		395: quarter_sine = 12'd1166;
		396: quarter_sine = 12'd1168;
		397: quarter_sine = 12'd1171;
		398: quarter_sine = 12'd1174;
		399: quarter_sine = 12'd1176;
		400: quarter_sine = 12'd1179;
		401: quarter_sine = 12'd1181;
		402: quarter_sine = 12'd1184;
		403: quarter_sine = 12'd1186;
		404: quarter_sine = 12'd1189;
		405: quarter_sine = 12'd1192;
		406: quarter_sine = 12'd1194;
		407: quarter_sine = 12'd1197;
		408: quarter_sine = 12'd1199;
		409: quarter_sine = 12'd1202;
		410: quarter_sine = 12'd1204;
		411: quarter_sine = 12'd1207;
		412: quarter_sine = 12'd1209;
		413: quarter_sine = 12'd1212;
		414: quarter_sine = 12'd1214;
		415: quarter_sine = 12'd1217;
		416: quarter_sine = 12'd1219;
		417: quarter_sine = 12'd1222;
		418: quarter_sine = 12'd1225;
		419: quarter_sine = 12'd1227;
		420: quarter_sine = 12'd1230;
		421: quarter_sine = 12'd1232;
		422: quarter_sine = 12'd1235;
		423: quarter_sine = 12'd1237;
		424: quarter_sine = 12'd1240;
		425: quarter_sine = 12'd1242;
		426: quarter_sine = 12'd1245;
		427: quarter_sine = 12'd1247;
		428: quarter_sine = 12'd1250;
		429: quarter_sine = 12'd1252;
		430: quarter_sine = 12'd1255;
		431: quarter_sine = 12'd1257;
		432: quarter_sine = 12'd1259;
		433: quarter_sine = 12'd1262;
		434: quarter_sine = 12'd1264;
		435: quarter_sine = 12'd1267;
		436: quarter_sine = 12'd1269;
		437: quarter_sine = 12'd1272;
		438: quarter_sine = 12'd1274;
		439: quarter_sine = 12'd1277;
		440: quarter_sine = 12'd1279;
		441: quarter_sine = 12'd1282;
		442: quarter_sine = 12'd1284;
		443: quarter_sine = 12'd1287;
		444: quarter_sine = 12'd1289;
		445: quarter_sine = 12'd1291;
		446: quarter_sine = 12'd1294;
		447: quarter_sine = 12'd1296;
		448: quarter_sine = 12'd1299;
		449: quarter_sine = 12'd1301;
		450: quarter_sine = 12'd1304;
		451: quarter_sine = 12'd1306;
		452: quarter_sine = 12'd1308;
		453: quarter_sine = 12'd1311;
		454: quarter_sine = 12'd1313;
		455: quarter_sine = 12'd1316;
		456: quarter_sine = 12'd1318;
		457: quarter_sine = 12'd1320;
		458: quarter_sine = 12'd1323;
		459: quarter_sine = 12'd1325;
		460: quarter_sine = 12'd1328;
		461: quarter_sine = 12'd1330;
		462: quarter_sine = 12'd1332;
		463: quarter_sine = 12'd1335;
		464: quarter_sine = 12'd1337;
		465: quarter_sine = 12'd1340;
		466: quarter_sine = 12'd1342;
		467: quarter_sine = 12'd1344;
		468: quarter_sine = 12'd1347;
		469: quarter_sine = 12'd1349;
		470: quarter_sine = 12'd1351;
		471: quarter_sine = 12'd1354;
		472: quarter_sine = 12'd1356;
		473: quarter_sine = 12'd1358;
		474: quarter_sine = 12'd1361;
		475: quarter_sine = 12'd1363;
		476: quarter_sine = 12'd1366;
		477: quarter_sine = 12'd1368;
		478: quarter_sine = 12'd1370;
		479: quarter_sine = 12'd1373;
		480: quarter_sine = 12'd1375;
		481: quarter_sine = 12'd1377;
		482: quarter_sine = 12'd1380;
		483: quarter_sine = 12'd1382;
		484: quarter_sine = 12'd1384;
		485: quarter_sine = 12'd1386;
		486: quarter_sine = 12'd1389;
		487: quarter_sine = 12'd1391;
		488: quarter_sine = 12'd1393;
		489: quarter_sine = 12'd1396;
		490: quarter_sine = 12'd1398;
		491: quarter_sine = 12'd1400;
		492: quarter_sine = 12'd1403;
		493: quarter_sine = 12'd1405;
		494: quarter_sine = 12'd1407;
		495: quarter_sine = 12'd1409;
		496: quarter_sine = 12'd1412;
		497: quarter_sine = 12'd1414;
		498: quarter_sine = 12'd1416;
		499: quarter_sine = 12'd1418;
		500: quarter_sine = 12'd1421;
		501: quarter_sine = 12'd1423;
		502: quarter_sine = 12'd1425;
		503: quarter_sine = 12'd1428;
		504: quarter_sine = 12'd1430;
		505: quarter_sine = 12'd1432;
		506: quarter_sine = 12'd1434;
		507: quarter_sine = 12'd1437;
		508: quarter_sine = 12'd1439;
		509: quarter_sine = 12'd1441;
		510: quarter_sine = 12'd1443;
		511: quarter_sine = 12'd1445;
		512: quarter_sine = 12'd1448;
		513: quarter_sine = 12'd1450;
		514: quarter_sine = 12'd1452;
		515: quarter_sine = 12'd1454;
		516: quarter_sine = 12'd1457;
		517: quarter_sine = 12'd1459;
		518: quarter_sine = 12'd1461;
		519: quarter_sine = 12'd1463;
		520: quarter_sine = 12'd1465;
		521: quarter_sine = 12'd1468;
		522: quarter_sine = 12'd1470;
		523: quarter_sine = 12'd1472;
		524: quarter_sine = 12'd1474;
		525: quarter_sine = 12'd1476;
		526: quarter_sine = 12'd1478;
		527: quarter_sine = 12'd1481;
		528: quarter_sine = 12'd1483;
		529: quarter_sine = 12'd1485;
		530: quarter_sine = 12'd1487;
		531: quarter_sine = 12'd1489;
		532: quarter_sine = 12'd1491;
		533: quarter_sine = 12'd1494;
		534: quarter_sine = 12'd1496;
		535: quarter_sine = 12'd1498;
		536: quarter_sine = 12'd1500;
		537: quarter_sine = 12'd1502;
		538: quarter_sine = 12'd1504;
		539: quarter_sine = 12'd1506;
		540: quarter_sine = 12'd1509;
		541: quarter_sine = 12'd1511;
		542: quarter_sine = 12'd1513;
		543: quarter_sine = 12'd1515;
		544: quarter_sine = 12'd1517;
		545: quarter_sine = 12'd1519;
		546: quarter_sine = 12'd1521;
		547: quarter_sine = 12'd1523;
		548: quarter_sine = 12'd1525;
		549: quarter_sine = 12'd1527;
		550: quarter_sine = 12'd1530;
		551: quarter_sine = 12'd1532;
		552: quarter_sine = 12'd1534;
		553: quarter_sine = 12'd1536;
		554: quarter_sine = 12'd1538;
		555: quarter_sine = 12'd1540;
		556: quarter_sine = 12'd1542;
		557: quarter_sine = 12'd1544;
		558: quarter_sine = 12'd1546;
		559: quarter_sine = 12'd1548;
		560: quarter_sine = 12'd1550;
		561: quarter_sine = 12'd1552;
		562: quarter_sine = 12'd1554;
		563: quarter_sine = 12'd1556;
		564: quarter_sine = 12'd1558;
		565: quarter_sine = 12'd1560;
		566: quarter_sine = 12'd1563;
		567: quarter_sine = 12'd1565;
		568: quarter_sine = 12'd1567;
		569: quarter_sine = 12'd1569;
		570: quarter_sine = 12'd1571;
		571: quarter_sine = 12'd1573;
		572: quarter_sine = 12'd1575;
		573: quarter_sine = 12'd1577;
		574: quarter_sine = 12'd1579;
		575: quarter_sine = 12'd1581;
		576: quarter_sine = 12'd1583;
		577: quarter_sine = 12'd1585;
		578: quarter_sine = 12'd1587;
		579: quarter_sine = 12'd1589;
		580: quarter_sine = 12'd1591;
		581: quarter_sine = 12'd1593;
		582: quarter_sine = 12'd1595;
		583: quarter_sine = 12'd1596;
		584: quarter_sine = 12'd1598;
		585: quarter_sine = 12'd1600;
		586: quarter_sine = 12'd1602;
		587: quarter_sine = 12'd1604;
		588: quarter_sine = 12'd1606;
		589: quarter_sine = 12'd1608;
		590: quarter_sine = 12'd1610;
		591: quarter_sine = 12'd1612;
		592: quarter_sine = 12'd1614;
		593: quarter_sine = 12'd1616;
		594: quarter_sine = 12'd1618;
		595: quarter_sine = 12'd1620;
		596: quarter_sine = 12'd1622;
		597: quarter_sine = 12'd1624;
		598: quarter_sine = 12'd1626;
		599: quarter_sine = 12'd1627;
		600: quarter_sine = 12'd1629;
		601: quarter_sine = 12'd1631;
		602: quarter_sine = 12'd1633;
		603: quarter_sine = 12'd1635;
		604: quarter_sine = 12'd1637;
		605: quarter_sine = 12'd1639;
		606: quarter_sine = 12'd1641;
		607: quarter_sine = 12'd1643;
		608: quarter_sine = 12'd1644;
		609: quarter_sine = 12'd1646;
		610: quarter_sine = 12'd1648;
		611: quarter_sine = 12'd1650;
		612: quarter_sine = 12'd1652;
		613: quarter_sine = 12'd1654;
		614: quarter_sine = 12'd1656;
		615: quarter_sine = 12'd1657;
		616: quarter_sine = 12'd1659;
		617: quarter_sine = 12'd1661;
		618: quarter_sine = 12'd1663;
		619: quarter_sine = 12'd1665;
		620: quarter_sine = 12'd1667;
		621: quarter_sine = 12'd1668;
		622: quarter_sine = 12'd1670;
		623: quarter_sine = 12'd1672;
		624: quarter_sine = 12'd1674;
		625: quarter_sine = 12'd1676;
		626: quarter_sine = 12'd1678;
		627: quarter_sine = 12'd1679;
		628: quarter_sine = 12'd1681;
		629: quarter_sine = 12'd1683;
		630: quarter_sine = 12'd1685;
		631: quarter_sine = 12'd1686;
		632: quarter_sine = 12'd1688;
		633: quarter_sine = 12'd1690;
		634: quarter_sine = 12'd1692;
		635: quarter_sine = 12'd1694;
		636: quarter_sine = 12'd1695;
		637: quarter_sine = 12'd1697;
		638: quarter_sine = 12'd1699;
		639: quarter_sine = 12'd1701;
		640: quarter_sine = 12'd1702;
		641: quarter_sine = 12'd1704;
		642: quarter_sine = 12'd1706;
		643: quarter_sine = 12'd1708;
		644: quarter_sine = 12'd1709;
		645: quarter_sine = 12'd1711;
		646: quarter_sine = 12'd1713;
		647: quarter_sine = 12'd1714;
		648: quarter_sine = 12'd1716;
		649: quarter_sine = 12'd1718;
		650: quarter_sine = 12'd1720;
		651: quarter_sine = 12'd1721;
		652: quarter_sine = 12'd1723;
		653: quarter_sine = 12'd1725;
		654: quarter_sine = 12'd1726;
		655: quarter_sine = 12'd1728;
		656: quarter_sine = 12'd1730;
		657: quarter_sine = 12'd1731;
		658: quarter_sine = 12'd1733;
		659: quarter_sine = 12'd1735;
		660: quarter_sine = 12'd1736;
		661: quarter_sine = 12'd1738;
		662: quarter_sine = 12'd1740;
		663: quarter_sine = 12'd1741;
		664: quarter_sine = 12'd1743;
		665: quarter_sine = 12'd1745;
		666: quarter_sine = 12'd1746;
		667: quarter_sine = 12'd1748;
		668: quarter_sine = 12'd1750;
		669: quarter_sine = 12'd1751;
		670: quarter_sine = 12'd1753;
		671: quarter_sine = 12'd1755;
		672: quarter_sine = 12'd1756;
		673: quarter_sine = 12'd1758;
		674: quarter_sine = 12'd1759;
		675: quarter_sine = 12'd1761;
		676: quarter_sine = 12'd1763;
		677: quarter_sine = 12'd1764;
		678: quarter_sine = 12'd1766;
		679: quarter_sine = 12'd1767;
		680: quarter_sine = 12'd1769;
		681: quarter_sine = 12'd1770;
		682: quarter_sine = 12'd1772;
		683: quarter_sine = 12'd1774;
		684: quarter_sine = 12'd1775;
		685: quarter_sine = 12'd1777;
		686: quarter_sine = 12'd1778;
		687: quarter_sine = 12'd1780;
		688: quarter_sine = 12'd1781;
		689: quarter_sine = 12'd1783;
		690: quarter_sine = 12'd1785;
		691: quarter_sine = 12'd1786;
		692: quarter_sine = 12'd1788;
		693: quarter_sine = 12'd1789;
		694: quarter_sine = 12'd1791;
		695: quarter_sine = 12'd1792;
		696: quarter_sine = 12'd1794;
		697: quarter_sine = 12'd1795;
		698: quarter_sine = 12'd1797;
		699: quarter_sine = 12'd1798;
		700: quarter_sine = 12'd1800;
		701: quarter_sine = 12'd1801;
		702: quarter_sine = 12'd1803;
		703: quarter_sine = 12'd1804;
		704: quarter_sine = 12'd1806;
		705: quarter_sine = 12'd1807;
		706: quarter_sine = 12'd1809;
		707: quarter_sine = 12'd1810;
		708: quarter_sine = 12'd1812;
		709: quarter_sine = 12'd1813;
		710: quarter_sine = 12'd1814;
		711: quarter_sine = 12'd1816;
		712: quarter_sine = 12'd1817;
		713: quarter_sine = 12'd1819;
		714: quarter_sine = 12'd1820;
		715: quarter_sine = 12'd1822;
		716: quarter_sine = 12'd1823;
		717: quarter_sine = 12'd1825;
		718: quarter_sine = 12'd1826;
		719: quarter_sine = 12'd1827;
		720: quarter_sine = 12'd1829;
		721: quarter_sine = 12'd1830;
		722: quarter_sine = 12'd1832;
		723: quarter_sine = 12'd1833;
		724: quarter_sine = 12'd1834;
		725: quarter_sine = 12'd1836;
		726: quarter_sine = 12'd1837;
		727: quarter_sine = 12'd1839;
		728: quarter_sine = 12'd1840;
		729: quarter_sine = 12'd1841;
		730: quarter_sine = 12'd1843;
		731: quarter_sine = 12'd1844;
		732: quarter_sine = 12'd1845;
		733: quarter_sine = 12'd1847;
		734: quarter_sine = 12'd1848;
		735: quarter_sine = 12'd1850;
		736: quarter_sine = 12'd1851;
		737: quarter_sine = 12'd1852;
		738: quarter_sine = 12'd1854;
		739: quarter_sine = 12'd1855;
		740: quarter_sine = 12'd1856;
		741: quarter_sine = 12'd1858;
		742: quarter_sine = 12'd1859;
		743: quarter_sine = 12'd1860;
		744: quarter_sine = 12'd1861;
		745: quarter_sine = 12'd1863;
		746: quarter_sine = 12'd1864;
		747: quarter_sine = 12'd1865;
		748: quarter_sine = 12'd1867;
		749: quarter_sine = 12'd1868;
		750: quarter_sine = 12'd1869;
		751: quarter_sine = 12'd1871;
		752: quarter_sine = 12'd1872;
		753: quarter_sine = 12'd1873;
		754: quarter_sine = 12'd1874;
		755: quarter_sine = 12'd1876;
		756: quarter_sine = 12'd1877;
		757: quarter_sine = 12'd1878;
		758: quarter_sine = 12'd1879;
		759: quarter_sine = 12'd1881;
		760: quarter_sine = 12'd1882;
		761: quarter_sine = 12'd1883;
		762: quarter_sine = 12'd1884;
		763: quarter_sine = 12'd1886;
		764: quarter_sine = 12'd1887;
		765: quarter_sine = 12'd1888;
		766: quarter_sine = 12'd1889;
		767: quarter_sine = 12'd1890;
		768: quarter_sine = 12'd1892;
		769: quarter_sine = 12'd1893;
		770: quarter_sine = 12'd1894;
		771: quarter_sine = 12'd1895;
		772: quarter_sine = 12'd1896;
		773: quarter_sine = 12'd1898;
		774: quarter_sine = 12'd1899;
		775: quarter_sine = 12'd1900;
		776: quarter_sine = 12'd1901;
		777: quarter_sine = 12'd1902;
		778: quarter_sine = 12'd1903;
		779: quarter_sine = 12'd1905;
		780: quarter_sine = 12'd1906;
		781: quarter_sine = 12'd1907;
		782: quarter_sine = 12'd1908;
		783: quarter_sine = 12'd1909;
		784: quarter_sine = 12'd1910;
		785: quarter_sine = 12'd1911;
		786: quarter_sine = 12'd1913;
		787: quarter_sine = 12'd1914;
		788: quarter_sine = 12'd1915;
		789: quarter_sine = 12'd1916;
		790: quarter_sine = 12'd1917;
		791: quarter_sine = 12'd1918;
		792: quarter_sine = 12'd1919;
		793: quarter_sine = 12'd1920;
		794: quarter_sine = 12'd1921;
		795: quarter_sine = 12'd1922;
		796: quarter_sine = 12'd1924;
		797: quarter_sine = 12'd1925;
		798: quarter_sine = 12'd1926;
		799: quarter_sine = 12'd1927;
		800: quarter_sine = 12'd1928;
		801: quarter_sine = 12'd1929;
		802: quarter_sine = 12'd1930;
		803: quarter_sine = 12'd1931;
		804: quarter_sine = 12'd1932;
		805: quarter_sine = 12'd1933;
		806: quarter_sine = 12'd1934;
		807: quarter_sine = 12'd1935;
		808: quarter_sine = 12'd1936;
		809: quarter_sine = 12'd1937;
		810: quarter_sine = 12'd1938;
		811: quarter_sine = 12'd1939;
		812: quarter_sine = 12'd1940;
		813: quarter_sine = 12'd1941;
		814: quarter_sine = 12'd1942;
		815: quarter_sine = 12'd1943;
		816: quarter_sine = 12'd1944;
		817: quarter_sine = 12'd1945;
		818: quarter_sine = 12'd1946;
		819: quarter_sine = 12'd1947;
		820: quarter_sine = 12'd1948;
		821: quarter_sine = 12'd1949;
		822: quarter_sine = 12'd1950;
		823: quarter_sine = 12'd1951;
		824: quarter_sine = 12'd1952;
		825: quarter_sine = 12'd1953;
		826: quarter_sine = 12'd1954;
		827: quarter_sine = 12'd1955;
		828: quarter_sine = 12'd1956;
		829: quarter_sine = 12'd1957;
		830: quarter_sine = 12'd1957;
		831: quarter_sine = 12'd1958;
		832: quarter_sine = 12'd1959;
		833: quarter_sine = 12'd1960;
		834: quarter_sine = 12'd1961;
		835: quarter_sine = 12'd1962;
		836: quarter_sine = 12'd1963;
		837: quarter_sine = 12'd1964;
		838: quarter_sine = 12'd1965;
		839: quarter_sine = 12'd1966;
		840: quarter_sine = 12'd1966;
		841: quarter_sine = 12'd1967;
		842: quarter_sine = 12'd1968;
		843: quarter_sine = 12'd1969;
		844: quarter_sine = 12'd1970;
		845: quarter_sine = 12'd1971;
		846: quarter_sine = 12'd1972;
		847: quarter_sine = 12'd1972;
		848: quarter_sine = 12'd1973;
		849: quarter_sine = 12'd1974;
		850: quarter_sine = 12'd1975;
		851: quarter_sine = 12'd1976;
		852: quarter_sine = 12'd1977;
		853: quarter_sine = 12'd1977;
		854: quarter_sine = 12'd1978;
		855: quarter_sine = 12'd1979;
		856: quarter_sine = 12'd1980;
		857: quarter_sine = 12'd1981;
		858: quarter_sine = 12'd1981;
		859: quarter_sine = 12'd1982;
		860: quarter_sine = 12'd1983;
		861: quarter_sine = 12'd1984;
		862: quarter_sine = 12'd1985;
		863: quarter_sine = 12'd1985;
		864: quarter_sine = 12'd1986;
		865: quarter_sine = 12'd1987;
		866: quarter_sine = 12'd1988;
		867: quarter_sine = 12'd1988;
		868: quarter_sine = 12'd1989;
		869: quarter_sine = 12'd1990;
		870: quarter_sine = 12'd1991;
		871: quarter_sine = 12'd1991;
		872: quarter_sine = 12'd1992;
		873: quarter_sine = 12'd1993;
		874: quarter_sine = 12'd1994;
		875: quarter_sine = 12'd1994;
		876: quarter_sine = 12'd1995;
		877: quarter_sine = 12'd1996;
		878: quarter_sine = 12'd1996;
		879: quarter_sine = 12'd1997;
		880: quarter_sine = 12'd1998;
		881: quarter_sine = 12'd1998;
		882: quarter_sine = 12'd1999;
		883: quarter_sine = 12'd2000;
		884: quarter_sine = 12'd2000;
		885: quarter_sine = 12'd2001;
		886: quarter_sine = 12'd2002;
		887: quarter_sine = 12'd2002;
		888: quarter_sine = 12'd2003;
		889: quarter_sine = 12'd2004;
		890: quarter_sine = 12'd2004;
		891: quarter_sine = 12'd2005;
		892: quarter_sine = 12'd2006;
		893: quarter_sine = 12'd2006;
		894: quarter_sine = 12'd2007;
		895: quarter_sine = 12'd2008;
		896: quarter_sine = 12'd2008;
		897: quarter_sine = 12'd2009;
		898: quarter_sine = 12'd2009;
		899: quarter_sine = 12'd2010;
		900: quarter_sine = 12'd2011;
		901: quarter_sine = 12'd2011;
		902: quarter_sine = 12'd2012;
		903: quarter_sine = 12'd2012;
		904: quarter_sine = 12'd2013;
		905: quarter_sine = 12'd2013;
		906: quarter_sine = 12'd2014;
		907: quarter_sine = 12'd2015;
		908: quarter_sine = 12'd2015;
		909: quarter_sine = 12'd2016;
		910: quarter_sine = 12'd2016;
		911: quarter_sine = 12'd2017;
		912: quarter_sine = 12'd2017;
		913: quarter_sine = 12'd2018;
		914: quarter_sine = 12'd2018;
		915: quarter_sine = 12'd2019;
		916: quarter_sine = 12'd2019;
		917: quarter_sine = 12'd2020;
		918: quarter_sine = 12'd2020;
		919: quarter_sine = 12'd2021;
		920: quarter_sine = 12'd2021;
		921: quarter_sine = 12'd2022;
		922: quarter_sine = 12'd2022;
		923: quarter_sine = 12'd2023;
		924: quarter_sine = 12'd2023;
		925: quarter_sine = 12'd2024;
		926: quarter_sine = 12'd2024;
		927: quarter_sine = 12'd2025;
		928: quarter_sine = 12'd2025;
		929: quarter_sine = 12'd2026;
		930: quarter_sine = 12'd2026;
		931: quarter_sine = 12'd2027;
		932: quarter_sine = 12'd2027;
		933: quarter_sine = 12'd2028;
		934: quarter_sine = 12'd2028;
		935: quarter_sine = 12'd2028;
		936: quarter_sine = 12'd2029;
		937: quarter_sine = 12'd2029;
		938: quarter_sine = 12'd2030;
		939: quarter_sine = 12'd2030;
		940: quarter_sine = 12'd2031;
		941: quarter_sine = 12'd2031;
		942: quarter_sine = 12'd2031;
		943: quarter_sine = 12'd2032;
		944: quarter_sine = 12'd2032;
		945: quarter_sine = 12'd2032;
		946: quarter_sine = 12'd2033;
		947: quarter_sine = 12'd2033;
		948: quarter_sine = 12'd2034;
		949: quarter_sine = 12'd2034;
		950: quarter_sine = 12'd2034;
		951: quarter_sine = 12'd2035;
		952: quarter_sine = 12'd2035;
		953: quarter_sine = 12'd2035;
		954: quarter_sine = 12'd2036;
		955: quarter_sine = 12'd2036;
		956: quarter_sine = 12'd2036;
		957: quarter_sine = 12'd2037;
		958: quarter_sine = 12'd2037;
		959: quarter_sine = 12'd2037;
		960: quarter_sine = 12'd2038;
		961: quarter_sine = 12'd2038;
		962: quarter_sine = 12'd2038;
		963: quarter_sine = 12'd2039;
		964: quarter_sine = 12'd2039;
		965: quarter_sine = 12'd2039;
		966: quarter_sine = 12'd2039;
		967: quarter_sine = 12'd2040;
		968: quarter_sine = 12'd2040;
		969: quarter_sine = 12'd2040;
		970: quarter_sine = 12'd2040;
		971: quarter_sine = 12'd2041;
		972: quarter_sine = 12'd2041;
		973: quarter_sine = 12'd2041;
		974: quarter_sine = 12'd2041;
		975: quarter_sine = 12'd2042;
		976: quarter_sine = 12'd2042;
		977: quarter_sine = 12'd2042;
		978: quarter_sine = 12'd2042;
		979: quarter_sine = 12'd2043;
		980: quarter_sine = 12'd2043;
		981: quarter_sine = 12'd2043;
		982: quarter_sine = 12'd2043;
		983: quarter_sine = 12'd2043;
		984: quarter_sine = 12'd2044;
		985: quarter_sine = 12'd2044;
		986: quarter_sine = 12'd2044;
		987: quarter_sine = 12'd2044;
		988: quarter_sine = 12'd2044;
		989: quarter_sine = 12'd2045;
		990: quarter_sine = 12'd2045;
		991: quarter_sine = 12'd2045;
		992: quarter_sine = 12'd2045;
		993: quarter_sine = 12'd2045;
		994: quarter_sine = 12'd2045;
		995: quarter_sine = 12'd2045;
		996: quarter_sine = 12'd2046;
		997: quarter_sine = 12'd2046;
		998: quarter_sine = 12'd2046;
		999: quarter_sine = 12'd2046;
		1000: quarter_sine = 12'd2046;
		1001: quarter_sine = 12'd2046;
		1002: quarter_sine = 12'd2046;
		1003: quarter_sine = 12'd2046;
		1004: quarter_sine = 12'd2047;
		1005: quarter_sine = 12'd2047;
		1006: quarter_sine = 12'd2047;
		1007: quarter_sine = 12'd2047;
		1008: quarter_sine = 12'd2047;
		1009: quarter_sine = 12'd2047;
		1010: quarter_sine = 12'd2047;
		1011: quarter_sine = 12'd2047;
		1012: quarter_sine = 12'd2047;
		1013: quarter_sine = 12'd2047;
		1014: quarter_sine = 12'd2047;
		1015: quarter_sine = 12'd2047;
		1016: quarter_sine = 12'd2047;
		1017: quarter_sine = 12'd2047;
		1018: quarter_sine = 12'd2047;
		1019: quarter_sine = 12'd2047;
		1020: quarter_sine = 12'd2047;
		1021: quarter_sine = 12'd2047;
		1022: quarter_sine = 12'd2047;
		1023: quarter_sine = 12'd2047;
	endcase
end

endmodule
