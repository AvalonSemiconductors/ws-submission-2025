/*
 * Implements the SID filters, but using purely digital logic
 * Takes in the sample of each voice, and the values of the config registers
 * Only has one output: the mixed and (possibly) filtered sample
*/

module SID_filter(
	output [14:0] sample_out,
	
	input [11:0] sample_1,
	input [11:0] sample_2,
	input [11:0] sample_3,
	input [10:0] reg_fc,
	input [7:0] res_filt,
	input [7:0] mode_vol,

	input clk,
	input rst,
	
	output sample_ready
);

wire [16:0] cutoff_lut = {reg_fc, 6'h20};

reg [10:0] res_lut;
always @(*) begin
	case(res_filt[7:4])
		0: res_lut = 1448;
		1: res_lut = 1328;
		2: res_lut = 1218;
		3: res_lut = 1117;
		4: res_lut = 1024;
		5: res_lut = 939;
		6: res_lut = 861;
		7: res_lut = 789;
		8: res_lut = 724;
		9: res_lut = 663;
		10: res_lut = 608;
		11: res_lut = 558;
		12: res_lut = 512;
		13: res_lut = 470;
		14: res_lut = 431;
		15: res_lut = 395;
	endcase
end

//Extract options from config registers
wire filt_1 = res_filt[0];
wire filt_2 = res_filt[1];
wire filt_3 = res_filt[2];

wire three_off = mode_vol[7];
wire hp = mode_vol[6];
wire bp = mode_vol[5];
wire lp = mode_vol[4];
wire [3:0] vol = mode_vol[3:0];

//Sample buffer
reg [14:0] sample_buff;

//Sample with volume setting applied
assign sample_out = sample_buff;

//Sum of all non-filtered samples
//wire [15:0] out_raw = (filt_1 ? 0 : sample_1) + (filt_2 ? 0 : sample_2) + (filt_3 || three_off ? 0 : sample_3) | 32768;

//Sum of all samples selected for filtering - input to the filters
wire [14:0] filt_in_add = (filt_1 ? {3'b000, sample_1} : 15'h0000) + (filt_2 ? {3'b000, sample_2} : 15'h0000) + (filt_3 ? {3'b000, sample_3} : 15'h0000);
wire [15:0] filt_in = {filt_in_add, 1'b0};

//Store state of the filters using 32-bit signed numbers
reg signed [31:0] high;
reg signed [31:0] band;
reg signed [31:0] low;

reg [2:0] filter_step;

/*
 * Here is where the new filter values are computed. This is using fixed-point arithmatic,
 * since that is pretty much the best that can be done here
 * Remember that this gets turned into hardware, so these few lines easily take up most of the die space used
 * in each SID macro, not counting the LUTs
*/
wire signed [31:0] temp1 = (filter_step == 0 ? {6'h00, res_lut} : cutoff_lut) * (filter_step == 1 ? high : band);
wire signed [31:0] temp2 = temp1 >>> 20;
wire signed [31:0] band_next = band - temp2;
wire signed [31:0] low_next = low + temp2;

wire signed [31:0] temp4 = temp1 >>> 10;
wire signed [31:0] high_next = {16'h0000, filt_in} + temp4 + low;

reg signed [31:0] sample_filtered;
wire signed [31:0] sample_filtered_next = sample_filtered + (filter_step == 1 ? -high : (filter_step == 2 ? -band : low));
wire signed [31:0] sample_filtered_adj = sample_filtered >>> 1;

assign sample_ready = filter_step == 0;
wire [14:0] sample_buff_next = sample_buff + (filter_step == 1 ? sample_1 : (filter_step == 2 ? sample_2 : (filter_step == 7 ? sample_filtered_adj : sample_3)));

always @(posedge clk) begin
	if(rst) begin
		high        <= 0;
		band        <= 0;
		low         <= 0;
		sample_buff <= 0;
		filter_step <= 0;
	end else begin
		filter_step <= filter_step + 1;
		case(filter_step)
			0: begin
				high <= high_next;
				sample_filtered <= 0;
				sample_buff <= 16384;
			end
			1: begin
				band <= band_next;
				if(hp) sample_filtered <= sample_filtered_next;
				if(!filt_1) sample_buff <= sample_buff_next;
			end
			2: begin
				low <= low_next;
				if(bp) sample_filtered <= sample_filtered_next;
				if(!filt_2) sample_buff <= sample_buff_next;
			end
			3: begin
				if(lp) sample_filtered <= sample_filtered_next;
				if(!filt_3 && !three_off) sample_buff <= sample_buff_next;
			end
			4: begin
			end
			5: begin
			end
			6: begin
			end
			7: begin
				sample_buff <= sample_buff_next;
			end
		endcase
	end
end

endmodule
