`default_nettype none

module misc(
`ifdef USE_POWER_PINS
	inout VDD,
	inout VSS,
`endif
	input clk_i,
	input rst_override_n,
	input [41:0] io_in_buffered,
	output [41:0] io_out,
	output [41:0] io_oe,
	output [41:0] io_pu,
	output [41:0] io_pd,
	output [41:0] io_cs,

	output [11:0] sample_raw_1,
	output [11:0] sample_raw_2,
	output [11:0] sample_raw_3,
	
	input [2:0] design_sel_buffered
);

wire [41:0] io_in = io_in_buffered;

wire [7:0] vga0_out;
tt_um_rejunity_vga_logo vga0(
	.ui_in(8'h00),
	.uo_out(vga0_out),
	.uio_in(8'h00),
	.uio_out(),
	.uio_oe(),
	.ena(1'b1),
	.clk(clk_i),
	.rst_n(design_sel_buffered == 1 && rst_override_n && io_in[0])
);

wire [7:0] vga1_out;
tt_um_waferspace_vga_screensaver vga1(
	.ui_in(io_in[41:34]),
	.uo_out(vga1_out),
	.uio_in(8'h00),
	.uio_out(),
	.uio_oe(),
	.ena(1'b1),
	.clk(clk_i),
	.rst_n(design_sel_buffered == 2 && rst_override_n && io_in[0])
);

wire io_out_hellorld;
hellorld hellorld(
	.wb_clk_i(clk_i),
	.rst_n(design_sel_buffered == 3 && rst_override_n && io_in[0]),
	.io_out(io_out_hellorld),
	.custom_settings(1040)
);

wire [8:0] io_out_diceroll;
diceroll diceroll(
	.wb_clk_i(clk_i),
	.rst_n(design_sel_buffered == 3 && rst_override_n && io_in[0]),
	.io_in(io_in[41]),
	.io_out(io_out_diceroll)
);

wire [2:0] io_out_blinker;
blinker blinker(
	.clk_i(clk_i),
	.io_out(io_out_blinker),
	.rst_n(design_sel_buffered == 3 && rst_override_n && io_in[0])
);

wire [31:0] vga_demo_rgb;
wire [1:0] vga_demo_io_out;
vga_demo vga_demo(
	.clk(clk_i),
	.rst_n(design_sel_buffered == 5 && rst_override_n && io_in[0]),
	.argb(vga_demo_rgb),
	.hsync(vga_demo_io_out[0]),
	.vsync(vga_demo_io_out[1])
);

wire [10:0] nano_PA;
wire [6:0] nano_DC;
wire nano_int_ena;
wire nano_int_ack;
wire nano_RW;
wire [3:0] nano_DS;
wire nano_PSG;
wire [7:0] nano_DO;
wire nano_oe;

nano nano(
	.clk(clk_i),
	.PA(nano_PA),
	.DC_out(nano_DC),
	.DC_in(io_in[13:7]),
	.INT_ENA(nano_int_ena),
	.INT_REQ(io_in[14]),
	.INT_ACK(nano_int_ack),
	.RW(nano_RW),
	.DS(nano_DS),
	.D_in(io_in[30:23]),
	.D_out(nano_DO),
	.D_oe(nano_oe),
	.PSG(nano_PSG),
	.rst(design_sel_buffered != 4 || !rst_override_n || !io_in[0])
);

wire [16:0] mc_io_out;
mc mc(
	.clk_i(clk_i),
	.rst_n(design_sel_buffered == 6 && rst_override_n && io_in[0]),
	.loader_en(io_in[0]),
	.run(io_in[9]),
	.load(io_in[10]),
	.preload_en(io_in[11]),
	.port_in(io_in[27:20]),
	.port_out(mc_io_out[7:0]),
	.load_in(io_in[19:12]),
	.preload_addr(mc_io_out[15:8]),
	.preload_act_n(mc_io_out[16])
);

reg [7:0] vga_col_sel_r;
reg [7:0] vga_col_sel_g;
reg [7:0] vga_col_sel_b;
always @(*) begin
	case(design_sel_buffered)
		default: begin
			vga_col_sel_r = 0;
			vga_col_sel_g = 0;
			vga_col_sel_b = 0;
		end
		1: begin
			vga_col_sel_r = {4{vga0_out[0], vga0_out[4]}};
			vga_col_sel_g = {4{vga0_out[1], vga0_out[5]}};
			vga_col_sel_b = {4{vga0_out[2], vga0_out[6]}};
		end
		2: begin
			vga_col_sel_r = {4{vga1_out[0], vga1_out[4]}};
			vga_col_sel_g = {4{vga1_out[1], vga1_out[5]}};
			vga_col_sel_b = {4{vga1_out[2], vga1_out[6]}};
		end
		5: begin
			vga_col_sel_r = vga_demo_rgb[7:0];
			vga_col_sel_g = vga_demo_rgb[15:8];
			vga_col_sel_b = vga_demo_rgb[23:16];
		end
	endcase
end
wire [7:0] vga_col_r_inv = 8'hFF - vga_col_sel_r;
wire [7:0] vga_col_g_inv = 8'hFF - vga_col_sel_g;
wire [7:0] vga_col_b_inv = 8'hFF - vga_col_sel_b;
assign sample_raw_1 = {vga_col_r_inv, vga_col_r_inv[7:4]};
assign sample_raw_2 = {vga_col_g_inv, vga_col_g_inv[7:4]};
assign sample_raw_3 = {vga_col_b_inv, vga_col_b_inv[7:4]};

reg [41:0] io_out_sel;
assign io_out = io_out_sel;
reg [41:0] io_oe_sel;
assign io_oe = io_oe_sel;
reg [41:0] io_cs_sel;
assign io_cs = io_cs_sel;
reg [41:0] io_pu_sel;
assign io_pu = io_pu_sel;
reg [41:0] io_pd_sel;
assign io_pd = io_pd_sel;
always @(*) begin
	case(design_sel_buffered)
		0: begin
			io_out_sel = 0;
			io_oe_sel = 42'h3FFFFFFFFFF;
			io_pu_sel = 0;
			io_pd_sel = 0;
			io_cs_sel = 0;
		end
		1: begin
			io_out_sel = {8'h00, vga0_out, 26'h0};
			io_oe_sel = {8'h00, 8'hFF, 26'h0};
			io_pu_sel = 0;
			io_pd_sel = 1;
			io_cs_sel = 1;
		end
		2: begin
			io_out_sel = {8'h00, vga1_out, 26'h0};
			io_oe_sel = {8'h00, 8'hFF, 26'h0};
			io_pu_sel = 0;
			io_pd_sel = {8'hFF, 8'h00, 25'h0, 1'b1};
			io_cs_sel = {8'hFF, 8'h00, 25'h0, 1'b1};
		end
		3: begin
			io_out_sel = {1'b0, io_out_diceroll, {28{io_out_hellorld}}, io_out_blinker, 1'b0};
			io_oe_sel = {1'b0, 9'h1F, 31'h7FFFFFFF, 1'b0};
			io_pu_sel = 0;
			io_pd_sel = {1'b1, 40'h0, 1'b1};
			io_cs_sel = {1'b1, 40'h0, 1'b1};
		end
		4: begin
			io_out_sel = {nano_PA, nano_DO, nano_RW, nano_DS, nano_PSG, nano_int_ena, nano_int_ack, 1'b0, 7'h00, 6'hxx, 1'b0};
			io_oe_sel = {11'h7FF, {8{nano_oe}}, 1'b1, 4'hF, 1'b1, 1'b1, 1'b1, 1'b0, ~nano_DC, 6'h3F, 1'b0};
			io_pu_sel = 0;
			io_pd_sel = {27'h0, 1'b1, 13'h0, 1'b1};
			io_cs_sel = {27'h0, 1'b1, 13'h0, 1'b1};
		end
		5: begin
			io_out_sel = {8'h00, 6'h2A, vga_demo_io_out, 26'h0};
			io_oe_sel = {8'h00, 8'hFF, 26'h0};
			io_pu_sel = {8'hFF, 8'h00, 26'h0};
			io_pd_sel = 1;
			io_cs_sel = {8'hFF, 8'h00, 25'h0, 1'b1};
		end
		6: begin
			io_out_sel = {5'h0, mc_io_out[16:8], 19'h0, mc_io_out[7:0], 1'b0};
			io_oe_sel = {5'h0, 9'h1FF, 19'h0, 8'hFF, 1'b0};
			io_pu_sel = {5'h1F, 37'h0};
			io_pd_sel = {5'h0, 9'h0, 19'h7FFFF, 8'h00, 1'b1};
			io_cs_sel = {5'h1F, 9'h0, 19'h7FFFF, 8'h00, 1'b1};
		end
		7: begin
			io_out_sel = 0;
			io_oe_sel = 42'h3FFFFFFFFFF;
			io_pu_sel = 0;
			io_pd_sel = 0;
			io_cs_sel = 0;
		end
	endcase
end

generate
for (genvar i=1; i<6; i++) begin
	(* keep *)
	gf180mcu_fd_sc_mcu7t5v0__antenna input_tie_1 (
		`ifdef USE_POWER_PINS
		.VNW    (VDD),
		.VPW    (VSS),
		.VDD    (VDD),
		.VSS    (VSS),
		`endif
		.I(io_in[i])
	);
	(* keep *)
	gf180mcu_fd_sc_mcu7t5v0__antenna input_tie_2 (
		`ifdef USE_POWER_PINS
		.VNW    (VDD),
		.VPW    (VSS),
		.VDD    (VDD),
		.VSS    (VSS),
		`endif
		.I(io_in[i+31])
	);
end
endgenerate

endmodule
