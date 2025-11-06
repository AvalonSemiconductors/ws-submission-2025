`default_nettype none

module sid_top(
	input RWb_in,
	input CEb_in,
	input [5:0] reg_addr,
	output DAC_clk,
	output DAC_leb,
	output DAC_dat_1,
	output DAC_dat_2,
	output DAC_csb,
	output oe,
	input [7:0] bus_in,
	output [7:0] bus_out,

	output [11:0] sample_raw_1,
	output [11:0] sample_raw_2,
	
	input clk,
	input rst_n
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

//Channel 2 config
reg [15:0] freq_2 [1:0];
reg [11:0] pw_2 [1:0];
reg [7:0]  ctrl_2 [1:0];
reg [7:0]  atk_dec_2 [1:0];
reg [7:0]  sus_rel_2 [1:0];

//Channel 3 config
reg [15:0] freq_3 [1:0];
reg [11:0] pw_3 [1:0];
reg [7:0]  ctrl_3 [1:0];
reg [7:0]  atk_dec_3 [1:0];
reg [7:0]  sus_rel_3 [1:0];

//Filters config
reg [10:0] fc [1:0];
reg [7:0]  res_filt [1:0];
reg [7:0]  mode_vol [1:0];

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
	CEb <= CEb_in;
	RWb <= RWb_in;
end

reg last_we;
wire next_we = RWb || CEb;
assign oe = (!CEb) && RWb;

wire which = reg_addr[5];
reg [7:0] read_res;
always @(*) begin
	case(reg_addr[4:0])
		default: read_res = 8'h00;
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
		
		21: read_res = {5'h00, fc[which][2:0]};
		22: read_res = fc[which][10:3];
		23: read_res = res_filt[which];
		24: read_res = mode_vol[which];
		27: read_res = which ? sample_2_3[11:4] : sample_1_3[11:4];
		28: read_res = which ? ch3_2_env : ch3_1_env;
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
        
        fc[0]        <= 0;
        fc[1]        <= 0;
        res_filt[0]  <= 0;
        res_filt[1]  <= 0;
        mode_vol[0]  <= 0;
        mode_vol[1]  <= 0;
        
        last_we <= 1'b1;
    end else begin
		last_we <= next_we;
		if(last_we && !next_we) begin
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

                    21: fc[which][2:0]      <= bus_in[2:0];
                    22: fc[which][10:3]     <= bus_in;
                    23: res_filt[which]     <= bus_in;
                    24: mode_vol[which]     <= bus_in;
                endcase
		end
    end
end

/*
 * Module instantiations for channels
*/

SID_channels channels_0(
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
    
    .clk(clk),
    .rst(~rst_n),
    .sample1(sample_1_1),
    .sample2(sample_1_2),
    .sample3(sample_1_3),
    
    .ch3_env(ch3_1_env)
);

SID_channels channels_1(
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
    
    .clk(clk),
    .rst(~rst_n),
    .sample1(sample_2_1),
    .sample2(sample_2_2),
    .sample3(sample_2_3),
    
    .ch3_env(ch3_2_env)
);

wire [14:0] full_sample_1;
wire [14:0] full_sample_2;
assign sample_raw_1 = full_sample_1[14:3];
assign sample_raw_2 = full_sample_2[14:3];
wire sample_ready;
SID_filter filters_0(
    .sample_out(full_sample_1),
    .sample_1(sample_1_1),
    .sample_2(sample_1_2),
    .sample_3(sample_1_3),
    .reg_fc(fc[0]),
    .res_filt(res_filt[0]),
    .mode_vol(mode_vol[0]),
    .clk(clk),
    .rst(~rst_n),
    
    .sample_ready(sample_ready)
);

SID_filter filters_1(
    .sample_out(full_sample_2),
    .sample_1(sample_2_1),
    .sample_2(sample_2_2),
    .sample_3(sample_2_3),
    .reg_fc(fc[1]),
    .res_filt(res_filt[1]),
    .mode_vol(mode_vol[1]),
    .clk(clk),
    .rst(~rst_n),
    
    .sample_ready()
);

spi_dac_i spi_dac_i(
    .sample_in_1(sample_raw_1),
    .sample_in_2(sample_raw_2),
    .clk(clk),
    .rst(~rst_n),
    .spi_leb(DAC_leb),
    .spi_clk(DAC_clk),
    .spi_dat_1(DAC_dat_1),
    .spi_dat_2(DAC_dat_2),
    .spi_csb(DAC_csb),
    .sample_ready(sample_ready)
);

endmodule
