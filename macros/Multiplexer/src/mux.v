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
	
	output [4:0] const_one,
	output [6:0] const_zero,
	input [4:0] design_sel
);

assign io_sl = 42'h0;

assign io_ie = ~io_oe;
assign const_one = 5'h1F;
assign const_zero = 7'h00;

assign select_6502 = design_sel[0];
wire is_6502 = design_sel[4:1] == 4'hE;

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
		io_pu_sel = select_6502 ? {14'h0, 1'b1, 12'h0, 1'b1, 8'h0, 1'b1, 2'h0, 1'b1, 1'b0, 1'b1} : {14'h0, 1'b1, 14'h0, 1'b1, 3'h0, 2'b11, 7'h0};
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
				io_pu_sel = 0;
			end
		endcase
	end
end

assign rst_override_n_6502 = is_6502;
assign rst_override_n_c64pla = design_sel == 5'b11110;
assign rst_override_n_sid = design_sel == 5'b11011;

endmodule
