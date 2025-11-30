`default_nettype none

module fm_top(
	input RWb_in,
	input CEb_in,
	input [5:0] reg_addr,
	output oe,
	input [7:0] bus_in,
	output [7:0] bus_out,

	output reg [11:0] sample_raw_1,
	output reg [11:0] sample_raw_2,
	output reg [11:0] sample_raw_3,
	
	input clk,
	input rst_n,
	
	input pot_x_in,
	input pot_y_in,
	output pot_x_oe,
	output pot_y_oe
);

/*
 * SID REGISTERS
 */
//Channel 1 config
reg [15:0] freq_1 [1:0];
reg [11:0] pw_1 [1:0];
reg [7:0]  ctrl_1 [1:0];
reg [7:0]  atk_dec_1 [1:0];
reg [7:0]  sus_rel_1 [1:0];
reg [7:0]  volume_1 [1:0];
reg [7:0]  ctrl2_1 [1:0];

//Channel 2 config
reg [15:0] freq_2 [1:0];
reg [11:0] pw_2 [1:0];
reg [7:0]  ctrl_2 [1:0];
reg [7:0]  atk_dec_2 [1:0];
reg [7:0]  sus_rel_2 [1:0];
reg [7:0]  volume_2 [1:0];
reg [7:0]  ctrl2_2 [1:0];

//Channel 3 config
reg [15:0] freq_3 [1:0];
reg [11:0] pw_3 [1:0];
reg [7:0]  ctrl_3 [1:0];
reg [7:0]  atk_dec_3 [1:0];
reg [7:0]  sus_rel_3 [1:0];
reg [7:0]  volume_3 [1:0];
reg [7:0]  ctrl2_3 [1:0];

//Potentiometer inputs
wire [7:0] measurement_x;
wire [7:0] measurement_y;

//Global FM configuration
reg [2:0] fm_enables;
reg [2:0] fm_inverts;
reg [7:0] message_select;
reg [7:0] message_char;

/*
 * Channel sample outputs
 */
wire [11:0] sample_1_1;
wire [11:0] sample_1_2;
wire [11:0] sample_1_3;
wire [11:0] sample_2_1;
wire [11:0] sample_2_2;
wire [11:0] sample_2_3;
wire [7:0] ch3_1_env;
wire [7:0] ch3_2_env;

reg CEb;
reg RWb;
always @(posedge clk) begin
	CEb <= rst_n ? CEb_in : 1'b1;
	RWb <= rst_n ? RWb_in : 1'b1;
end

reg last_we;
wire next_we = RWb || CEb;
assign oe = (!CEb) && RWb;

wire we_cond = last_we && !next_we;

wire which = reg_addr[5];
reg [7:0] read_res;
always @(*) begin
	case(reg_addr[4:0])
		default: read_res = 8'hxx;
		0: read_res = freq_1[which][7:0];
		1: read_res = freq_1[which][15:8];
		2: read_res = pw_1[which][7:0];
		3: read_res = {4'h0, pw_1[which][11:8]};
		4: read_res = ctrl_1[which];
		5: read_res = atk_dec_1[which];
		6: read_res = sus_rel_1[which];
		
		7: read_res = freq_2[which][7:0];
		8: read_res = freq_2[which][15:8];
		9: read_res = pw_2[which][7:0];
		10: read_res = {4'h0, pw_2[which][11:8]};
		11: read_res = ctrl_2[which];
		12: read_res = atk_dec_2[which];
		13: read_res = sus_rel_2[which];
		
		14: read_res = freq_3[which][7:0];
		15: read_res = freq_3[which][15:8];
		16: read_res = pw_3[which][7:0];
		17: read_res = {4'h0, pw_3[which][11:8]};
		18: read_res = ctrl_3[which];
		19: read_res = atk_dec_3[which];
		20: read_res = sus_rel_3[which];
		
		21: read_res = volume_1[which];
		22: read_res = volume_2[which];
		23: read_res = volume_3[which];
		24: read_res = {1'b0, fm_inverts, 1'b0, fm_enables};
		
		25: read_res = message_char;
		26: read_res = measurement_y;
		
		27: read_res = which ? sample_2_3[11:4] : sample_1_3[11:4];
		28: read_res = which ? ch3_2_env : ch3_1_env;
		29: read_res = ctrl2_1[which];
		30: read_res = ctrl2_2[which];
		31: read_res = ctrl2_3[which];
		//TODO: secret message
	endcase
end
assign bus_out = read_res;

always @(posedge clk) begin
	if(!rst_n) begin
		freq_1[0]    <= 0;
		freq_1[1]    <= 0;
		pw_1[0]      <= 0;
		pw_1[1]      <= 0;
		ctrl_1[0]    <= 0;
		ctrl_1[1]    <= 0;
		atk_dec_1[0] <= 0;
		atk_dec_1[1] <= 0;
		sus_rel_1[0] <= 0;
		sus_rel_1[1] <= 0;
		volume_1[0]  <= 8'hFF;
		volume_1[1]  <= 8'hFF;
		ctrl2_1[0]   <= 0;
		ctrl2_1[1]   <= 0;
		
		freq_2[0]    <= 0;
		freq_2[1]    <= 0;
		pw_2[0]      <= 0;
		pw_2[1]      <= 0;
		ctrl_2[0]    <= 0;
		ctrl_2[1]    <= 0;
		atk_dec_2[0] <= 0;
		atk_dec_2[1] <= 0;
		sus_rel_2[0] <= 0;
		sus_rel_2[1] <= 0;
		volume_2[0]  <= 8'hFF;
		volume_2[1]  <= 8'hFF;
		ctrl2_2[0]   <= 0;
		ctrl2_2[1]   <= 0;
		
		freq_3[0]    <= 0;
		freq_3[1]    <= 0;
		pw_3[0]      <= 0;
		pw_3[1]      <= 0;
		ctrl_3[0]    <= 0;
		ctrl_3[1]    <= 0;
		atk_dec_3[0] <= 0;
		atk_dec_3[1] <= 0;
		sus_rel_3[0] <= 0;
		sus_rel_3[1] <= 0;
		volume_3[0]  <= 8'hFF;
		volume_3[1]  <= 8'hFF;
		ctrl2_3[0]   <= 0;
		ctrl2_3[1]   <= 0;
		
		fm_enables   <= 0;
		fm_inverts   <= 0;
		message_select <= 0;
		
		last_we <= 1'b1;
	end else begin
		last_we <= next_we;
		if(we_cond) begin
			/*
			* SID Register Write
			*/
			case(reg_addr[4:0])
				0:  freq_1[which][7:0]  <= bus_in;
				1:  freq_1[which][15:8] <= bus_in;
				2:  pw_1[which][7:0]    <= bus_in;
				3:  pw_1[which][11:8]   <= bus_in[3:0];
				4:  ctrl_1[which]       <= bus_in;
				5:  atk_dec_1[which]    <= bus_in;
				6:  sus_rel_1[which]    <= bus_in;
				
				7:  freq_2[which][7:0]  <= bus_in;
				8:  freq_2[which][15:8] <= bus_in;
				9:  pw_2[which][7:0]    <= bus_in;
				10: pw_2[which][11:8]   <= bus_in[3:0];
				11: ctrl_2[which]       <= bus_in;
				12: atk_dec_2[which]    <= bus_in;
				13: sus_rel_2[which]    <= bus_in;
				
				14: freq_3[which][7:0]  <= bus_in;
				15: freq_3[which][15:8] <= bus_in;
				16: pw_3[which][7:0]    <= bus_in;
				17: pw_3[which][11:8]   <= bus_in[3:0];
				18: ctrl_3[which]       <= bus_in;
				19: atk_dec_3[which]    <= bus_in;
				20: sus_rel_3[which]    <= bus_in;
				
				21: volume_1[which]     <= bus_in;
				22: volume_2[which]     <= bus_in;
				23: volume_3[which]     <= bus_in;
				24: begin
					fm_enables          <= bus_in[2:0];
					fm_inverts          <= bus_in[6:4];
				end
				25: message_select      <= bus_in;
				29: ctrl2_1[which]      <= bus_in;
				30: ctrl2_2[which]      <= bus_in;
				31: ctrl2_3[which]      <= bus_in;
			endcase
		end
	end
end

/*
 * Module instantiations for channels
*/

FM_channels #(.has_fm(0)) channels_0(
	.freq1(freq_1[0]),
	.freq2(freq_2[0]),
	.freq3(freq_3[0]),
	.pw1(pw_1[0]),
	.pw2(pw_2[0]),
	.pw3(pw_3[0]),
	.ctrl_reg1(ctrl_1[0]),
	.ctrl_reg2(ctrl_2[0]),
	.ctrl_reg3(ctrl_3[0]),
	.atk_dec1(atk_dec_1[0]),
	.atk_dec2(atk_dec_2[0]),
	.atk_dec3(atk_dec_3[0]),
	.sus_rel1(sus_rel_1[0]),
	.sus_rel2(sus_rel_2[0]),
	.sus_rel3(sus_rel_3[0]),
	.volume1(volume_1[0]),
	.volume2(volume_2[0]),
	.volume3(volume_3[0]),
	.ctrl2_reg1(ctrl2_1[0]),
	.ctrl2_reg2(ctrl2_2[0]),
	.ctrl2_reg3(ctrl2_3[0]),
	
	.fm1(12'h000),
	.fm2(12'h000),
	.fm3(12'h000),
	
	.clk(clk),
	.rst(~rst_n),
	.sample1(sample_1_1),
	.sample2(sample_1_2),
	.sample3(sample_1_3),
	
	.ch3_env(ch3_1_env)
);

wire [11:0] sample_1_1_adj = fm_inverts[0] ? 12'hFFF - sample_1_1 : sample_1_1;
wire [11:0] sample_1_2_adj = fm_inverts[1] ? 12'hFFF - sample_1_2 : sample_1_2;
wire [11:0] sample_1_3_adj = fm_inverts[2] ? 12'hFFF - sample_1_3 : sample_1_3;

FM_channels #(.has_fm(1)) channels_1(
	.freq1(freq_1[1]),
	.freq2(freq_2[1]),
	.freq3(freq_3[1]),
	.pw1(pw_1[1]),
	.pw2(pw_2[1]),
	.pw3(pw_3[1]),
	.ctrl_reg1(ctrl_1[1]),
	.ctrl_reg2(ctrl_2[1]),
	.ctrl_reg3(ctrl_3[1]),
	.atk_dec1(atk_dec_1[1]),
	.atk_dec2(atk_dec_2[1]),
	.atk_dec3(atk_dec_3[1]),
	.sus_rel1(sus_rel_1[1]),
	.sus_rel2(sus_rel_2[1]),
	.sus_rel3(sus_rel_3[1]),
	.volume1(volume_1[1]),
	.volume2(volume_2[1]),
	.volume3(volume_3[1]),
	.ctrl2_reg1(ctrl2_1[1]),
	.ctrl2_reg2(ctrl2_2[1]),
	.ctrl2_reg3(ctrl2_3[1]),
	
	.fm1(fm_enables[0] ? sample_1_1_adj : 12'h000),
	.fm2(fm_enables[1] ? sample_1_2_adj : 12'h000),
	.fm3(fm_enables[2] ? sample_1_3_adj : 12'h000),
	
	.clk(clk),
	.rst(~rst_n),
	.sample1(sample_2_1),
	.sample2(sample_2_2),
	.sample3(sample_2_3),
	
	.ch3_env(ch3_2_env)
);

always @(posedge clk) begin
	if(rst_n) begin
		sample_raw_1 <= fm_enables[0] ? sample_2_1 : sample_1_1_adj[11:1] + sample_2_1[11:1];
		sample_raw_2 <= fm_enables[1] ? sample_2_2 : sample_1_2_adj[11:1] + sample_2_2[11:1];
		sample_raw_3 <= fm_enables[2] ? sample_2_3 : sample_1_3_adj[11:1] + sample_2_3[11:1];
	end
end

sid_adc sid_adc_x(
    .rst_n(rst_n),
    .clk(clk),
    .pot_in(pot_x_in),
    .pot_oe(pot_x_oe),
    .measurement(measurement_x)
);

sid_adc sid_adc_y(
    .rst_n(rst_n),
    .clk(clk),
    .pot_in(pot_y_in),
    .pot_oe(pot_y_oe),
    .measurement(measurement_y)
);

always @(*) begin
	case(message_select)
		default: message_char = 8'hxx;
		0: message_char = measurement_x;
		1: message_char = 8'h46;
		2: message_char = 8'h6F;
		3: message_char = 8'h72;
		4: message_char = 8'h20;
		5: message_char = 8'h4C;
		6: message_char = 8'h69;
		7: message_char = 8'h6C;
		8: message_char = 8'h69;
		9: message_char = 8'h74;
		10: message_char = 8'h68;
		11: message_char = 8'h2F;
		12: message_char = 8'h4C;
		13: message_char = 8'h69;
		14: message_char = 8'h6C;
		15: message_char = 8'h6C;
		16: message_char = 8'h79;
		17: message_char = 8'h21;
		18: message_char = 8'h20;
		19: message_char = 8'h3C;
		20: message_char = 8'h33;
		21: message_char = 8'h00;
	endcase
end

endmodule
