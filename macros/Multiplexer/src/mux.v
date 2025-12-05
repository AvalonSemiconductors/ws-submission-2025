`default_nettype none

module multiplexer(
`ifdef USE_POWER_PINS
	inout wire VSS,
	inout wire VDD,
`endif
	input clk_i,
	
	output [41:0] io_out,
	output [41:0] io_oe,
	output [41:0] io_cs,
	output [41:0] io_sl,
	output [41:0] io_pu,
	output [41:0] io_pd,
	output [41:0] io_ie,
	
	input [41:0] io_out_6502,
	input [41:0] io_oe_6502,
	output rst_override_n_6502,
	output select_6502,
	
	input [41:0] io_out_c64pla,
	input io_oe_c64pla,
	output rst_override_n_c64pla,
	
	input [41:0] io_out_sid,
	input [2:0] io_oe_sid,
	output rst_override_n_sid,
	
	input [41:0] io_out_gpiochip,
	input [16:0] io_oe_gpiochip,
	input [15:0] io_pu_gpiochip,
	input [15:0] io_pd_gpiochip,
	output rst_override_n_gpiochip,
	
	input [41:0] io_out_dram_controller,
	output rst_override_n_dram_controller,
	
	input [11:0] io_out_ntsc,
	output rst_override_n_ntsc,
	
	input [41:0] io_out_misc,
	input [41:0] io_oe_misc,
	input [41:0] io_pu_misc,
	input [41:0] io_pd_misc,
	input [41:0] io_cs_misc,
	output rst_override_n_misc,
	
	input [41:0] io_out_65rv32,
	input [41:0] io_oe_65rv32,
	output rst_override_n_65rv32,
	
	input [41:0] io_out_fm,
	input [2:0] io_oe_fm,
	output rst_override_n_fm,
	
	input [8:0] io_out_secret_message,
	output rst_override_n_secret_message,
	
	output [4:0] const_one,
	output [6:0] const_zero,
	input [4:0] design_sel
);

assign io_sl = design_sel == 5'b00011 ? {1'b0, 9'h1F, 32'h0} : 42'h0;

assign io_ie = ~io_oe;
assign const_one = 5'h1F;
assign const_zero = 7'h00;

assign select_6502 = design_sel[0];
wire is_6502 = design_sel[4:1] == 4'hE;
wire is_misc = design_sel[4:3] == 2'b00;
wire is_65rv32 = design_sel[4:1] == 4'h4;

reg [41:0] io_out_sel;
reg [41:0] io_oe_sel;
reg [41:0] io_cs_sel;
reg [41:0] io_pd_sel;
reg [41:0] io_pu_sel;
assign io_out = io_out_sel;
assign io_oe = io_oe_sel;
assign io_cs = io_cs_sel;
assign io_pd = io_pd_sel;
assign io_pu = io_pu_sel;
always @(*) begin
	if(is_6502) begin
		io_oe_sel = io_oe_6502;
		io_out_sel = io_out_6502;
		io_cs_sel = select_6502 ? {31'h0, 1'b1, 1'b0, 2'b11, 7'h0} : {31'h0, 2'b11, 4'h0, 1'b1, 4'h0};
		io_pd_sel = 0;
		io_pu_sel = select_6502 ? {14'h0, 1'b1, 12'h0, 1'b1, 8'h0, 1'b1, 2'h1, 1'b1, 1'b0, 1'b1} : {14'h0, 1'b1, 14'h0, 1'b1, 3'h0, 2'b11, 1'b0, 1'b1, 5'h0};
	end else if(is_65rv32) begin
		io_oe_sel = io_oe_65rv32;
		io_out_sel = io_out_65rv32;
		io_cs_sel = select_6502 ? {31'h0, 1'b1, 1'b0, 2'b11, 7'h0} : {31'h0, 2'b11, 4'h0, 1'b1, 4'h0};
		io_pd_sel = 0;
		io_pu_sel = select_6502 ? {14'h0, 1'b1, 12'h0, 1'b1, 8'h0, 1'b1, 2'h1, 1'b1, 1'b0, 1'b1} : {11'h0, !io_oe_65rv32[30], 2'b0, 1'b1, 14'h0, 1'b1, 3'h0, 2'b11, 1'b0, 1'b1, 5'h0};
	end else if(is_misc) begin
		io_oe_sel = io_oe_misc;
		io_out_sel = io_out_misc;
		io_cs_sel = io_cs_misc;
		io_pd_sel = io_pd_misc;
		io_pu_sel = io_pu_misc;
	end else begin
		case(design_sel)
			default: begin
				io_oe_sel = 0;
				io_out_sel = 0;
				io_cs_sel = 0;
				io_pd_sel = 0;
				io_pu_sel = 0;
			end
			5'b11110: begin
				io_oe_sel = {5'h00, 1'b1, 1'b0, 1'b1, 2'b00, io_oe_c64pla, io_oe_c64pla, 2'b11, io_oe_c64pla, io_oe_c64pla, 1'b1, {4{io_oe_c64pla}}, 2'b0, 4'hF, 3'b0, 1'b1, 3'b0, 4'hF, 4'h0};
				io_out_sel = io_out_c64pla;
				io_cs_sel = 0;
				io_pd_sel = 0;
				io_pu_sel = {2'b0, 3'b111, 37'h0};
			end
			5'b11011: begin
				io_oe_sel = {7'h0, io_oe_sid[2:1], io_oe_sid[0], 5'h1F, 3'h0, io_oe_sid[0], 1'b1, {6{io_oe_sid[0]}}, 16'h0};
				io_out_sel = io_out_sid;
				io_cs_sel = {7'h0, 2'b11, 33'h0};
				io_pd_sel = {2'b0, 1'b1, 39'h0};
				io_pu_sel = {1'b0, 1'b1, 14'h0, 2'b11, 24'h0};
			end
			5'b11010: begin
				io_oe_sel = {1'b1, 1'b0, io_oe_gpiochip[16:1], 3'b000, {8{io_oe_gpiochip[0]}}, 6'h00, 4'hF, 1'b0, 1'b0, 1'b1};
				io_out_sel = io_out_gpiochip;
				io_cs_sel = {1'b0, 1'b1, 38'h0, 1'b1, 1'b0};
				io_pd_sel = {2'b00, io_pd_gpiochip, 24'h0};
				io_pu_sel = {1'b0, 1'b1, io_pu_gpiochip, 2'b00, 1'b1, 21'h0};
			end
			5'b11001: begin
				io_out_sel = io_out_dram_controller;
				io_oe_sel = {1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 1'b1, 6'h3F, 1'b0, 2'b11, 3'b0, 16'h0, 3'h7, 1'b0, 1'b0, 1'b1, 1'b0};
				io_cs_sel = 0;
				io_pd_sel = {13'h0, 1'b1, 24'h0, 1'b1, 2'b0, 1'b1};
				io_pu_sel = {16'h0, 3'b111, 23'h0};
			end
			5'b11000: begin
				io_out_sel = {30'h0, io_out_ntsc};
				io_oe_sel = {30'h0, 12'hFFF};
				io_cs_sel = 0;
				io_pd_sel = 42'h3FFFFFFF000;
				io_pu_sel = 0;
			end
			5'b10000: begin
				io_oe_sel = {7'h0, io_oe_fm[2:1], io_oe_fm[0], 5'h1F, 3'h0, io_oe_fm[0], 1'b1, {6{io_oe_fm[0]}}, 16'h0};
				io_out_sel = io_out_fm;
				io_cs_sel = {7'h0, 2'b11, 33'h0};
				io_pd_sel = {2'b0, 1'b1, 39'h0};
				io_pu_sel = {1'b0, 1'b1, 14'h0, 2'b11, 24'h0};
			end
			5'b10100: begin
				io_oe_sel = {32'h0, 9'h1FF, 1'b0};
				io_out_sel = {32'h0, io_out_secret_message, 1'b0};
				io_cs_sel = {41'h0, 1'b1};
				io_pd_sel = {41'h0, 1'b1};
				io_pu_sel = 0;
			end
		endcase
	end
end

assign rst_override_n_6502 = is_6502;
assign rst_override_n_65rv32 = is_65rv32;
assign rst_override_n_c64pla = design_sel == 5'b11110;
assign rst_override_n_sid = design_sel == 5'b11011;
assign rst_override_n_gpiochip = design_sel == 5'b11010;
assign rst_override_n_dram_controller = design_sel == 5'b11001;
assign rst_override_n_ntsc = design_sel == 5'b11000;
assign rst_override_n_misc = is_misc;
assign rst_override_n_fm = design_sel == 5'b10000;
assign rst_override_n_secret_message = design_sel == 5'b10100;

endmodule
