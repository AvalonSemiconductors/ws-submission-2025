`default_nettype none

//Input clock = 14.31818MHz (NTSC)
//= 0.069841279usec per clock

//Input clock = 17.734475 (PAL)
//= 0,056387347usec per clock

module ntsc(
`ifdef USE_POWER_PINS
	inout VDD,
	inout VSS,
`endif
	input clk_i,
	input rst_override_n,
	input [6:0] io_in_buffered,
	
	output [11:0] io_out,
	
	output [11:0] sample_raw_1
);

`define NTSC_SYNC_LEVEL 12'h000
`define NTSC_BLACK_LEVEL 12'h4CD
`define NTSC_WHITE_LEVEL 12'hFFF
`define NTSC_LINES 263
`define NTSC_VSYNC_START 246
`define NTSC_VSYNC_END 252
`define NTSC_LINE_LEN 910
`define NTSC_HSYNC_START 22
`define NTSC_4_7_us 67
`define NTSC_HSYNC_END `NTSC_HSYNC_START+`NTSC_4_7_us
`define NTSC_BURST_START 89
`define NTSC_BURST_END `NTSC_BURST_START+35
`define NTSC_BLANK_END `NTSC_HSYNC_START+135

`define PAL_SYNC_LEVEL 12'h000
`define PAL_BLACK_LEVEL 12'h4CD
`define PAL_WHITE_LEVEL 12'hFFF
`define PAL_LINES 312
`define PAL_VSYNC_START 279
`define PAL_VSYNC_END 285
`define PAL_LINE_LEN 1135
`define PAL_HSYNC_START 29
`define PAL_4_7_us 83
`define PAL_HSYNC_END `PAL_HSYNC_START+`PAL_4_7_us
`define PAL_BURST_START 99
`define PAL_BURST_END `PAL_BURST_START+40
`define PAL_BLANK_END `PAL_HSYNC_START+214

reg [7:0] frame_counter;

wire reset = !(io_in_buffered[6] && rst_override_n);
reg [11:0] ntsc_luma;
assign sample_raw_1 = reset ? 12'h000 : (12'hFFF - ntsc_luma);
assign io_out = ntsc_luma;

reg [9:0] curr_line;
reg [10:0] curr_hpos;
reg active_period;
reg vsync;
reg v_backporch;

wire [3:0] program_select = io_in_buffered[5:2];
wire color_enable = io_in_buffered[1];
wire pal_sel = io_in_buffered[0];
reg [9:0] active_pixel; // 0 -> 751 ( / 2 = 375)
reg [7:0] active_line; // 0 -> 245

wire [6:0] img_1_pixel = active_line[7:1] + active_pixel[9:3] + frame_counter[6:0];
wire [4:0] img_2_pixel;

wire [11:0] pixel_12bit = {1'b0, program_select[0] ? img_1_pixel : {img_2_pixel, img_2_pixel[4], img_2_pixel[3]}, 4'h0};
wire [11:0] final_img_pixel = `NTSC_BLACK_LEVEL + pixel_12bit + {2'b00, pixel_12bit[11:2]} + {4'h0, pixel_12bit[11:4]};

always @(posedge clk_i) begin
	if(reset) begin
		ntsc_luma <= 0;
		curr_line <= 0;
		curr_hpos <= 0;
		active_period <= 0;
		vsync         <= 0;
		v_backporch   <= 0;
		active_pixel  <= 0;
		active_line   <= 0;
		frame_counter <= 0;
	end else begin
		/*
		 * Sync pulses and counters
		 */
		curr_hpos <= curr_hpos + 1;
		if(pal_sel) begin
			if(curr_hpos == 0) ntsc_luma <= `PAL_BLACK_LEVEL;
			if(curr_hpos == `PAL_HSYNC_START-1) ntsc_luma <= `PAL_SYNC_LEVEL;
			if(curr_hpos == `PAL_HSYNC_END-1 && !vsync) ntsc_luma <= `PAL_BLACK_LEVEL;
			if(curr_hpos == `PAL_LINE_LEN - `PAL_4_7_us + `PAL_HSYNC_START && vsync) ntsc_luma <= `PAL_BLACK_LEVEL;
			if(curr_hpos == `PAL_BLANK_END) begin
				active_period <= !vsync && !v_backporch;
				active_pixel <= 0;
			end
			if(active_period) active_pixel <= active_pixel + 1;
			if(curr_hpos == `PAL_LINE_LEN-1) begin
				curr_hpos <= 0;
				active_period <= 0;
				curr_line <= curr_line + 1;
				if(!v_backporch && !vsync) active_line <= active_line + 1;
				if(curr_line == `PAL_VSYNC_START - 6) v_backporch <= 1'b1;
				if(curr_line == `PAL_VSYNC_START) vsync <= 1'b1;
				if(curr_line == `PAL_VSYNC_END) vsync <= 0;
				if(curr_line == `PAL_LINES-1) begin
					curr_line <= 0;
					active_line <= 0;
					frame_counter <= frame_counter + 1;
				end
				if(curr_line == 1) v_backporch <= 0;
			end
		end else begin
			if(curr_hpos == 0) ntsc_luma <= `NTSC_BLACK_LEVEL;
			if(curr_hpos == `NTSC_HSYNC_START-1) ntsc_luma <= `NTSC_SYNC_LEVEL;
			if(curr_hpos == `NTSC_HSYNC_END-1 && !vsync) ntsc_luma <= `NTSC_BLACK_LEVEL;
			if(curr_hpos == `NTSC_LINE_LEN - `NTSC_4_7_us + `NTSC_HSYNC_START && vsync) ntsc_luma <= `NTSC_BLACK_LEVEL;
			if(curr_hpos == `NTSC_BLANK_END) begin
				active_period <= !vsync && !v_backporch;
				active_pixel <= 0;
			end
			if(active_period) active_pixel <= active_pixel + 1;
			if(curr_hpos == `NTSC_LINE_LEN-1) begin
				curr_hpos <= 0;
				active_period <= 0;
				curr_line <= curr_line + 1;
				if(!v_backporch && !vsync) active_line <= active_line + 1;
				if(curr_line == `NTSC_VSYNC_START - 4) v_backporch <= 1'b1;
				if(curr_line == `NTSC_VSYNC_START) vsync <= 1'b1;
				if(curr_line == `NTSC_VSYNC_END) vsync <= 0;
				if(curr_line == `NTSC_LINES-1) begin
					curr_line <= 0;
					active_line <= 0;
					frame_counter <= frame_counter + 1;
				end
				if(curr_line == 1) v_backporch <= 0;
			end
		end
		
		/*
		 * Demo-specific code
		 */
		if(active_period) begin
			if(program_select == 0) ntsc_luma <= `NTSC_BLACK_LEVEL; //Black frame
			if(program_select == 1) ntsc_luma <= `NTSC_WHITE_LEVEL; //White frame
			if(program_select == 2) ntsc_luma <= active_pixel[0] ^ active_line[0] == 0 ? `NTSC_BLACK_LEVEL : `NTSC_WHITE_LEVEL; //Fine Checkerboard pattern
			if(program_select == 3) ntsc_luma <= ((active_pixel + {active_line, 1'b0}) & 'h7FF) + `NTSC_BLACK_LEVEL; //Grayscale test pattern
			if(program_select == 4) ntsc_luma <= active_pixel[3] ^ active_line[3] == 0 ? (active_pixel[5] ^ active_line[5] == 0 ? `NTSC_BLACK_LEVEL : 12'h555) : (active_pixel[5] ^ active_line[5] == 0 ? 12'h999 : `NTSC_WHITE_LEVEL); //Larger checkerboard pattern with some grayscale
			if(program_select > 4) ntsc_luma <= final_img_pixel;
		end
	end
end

tholin_img tholin_img(
	.column(active_pixel[9:2]),
	.row(active_line[7:1]),
	.pixel(img_2_pixel)
);

endmodule
