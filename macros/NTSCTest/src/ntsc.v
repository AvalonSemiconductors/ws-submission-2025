`default_nettype none

//Input clock = 14.31818MHz
//= 0.069841279usec per clock

module ntsc(
`ifdef USE_POWER_PINS
	inout VDD,
	inout VSS,
`endif
	input clk_i,
	input rst_override_n,
	input [41:0] io_in_buffered,
	
	output [11:0] sample_raw_1
);

`define NTSC_SYNC_LEVEL 12'h000
`define NTSC_BLACK_LEVEL 12'h4CD
`define NTSC_WHITE_LEVEL 12'hFFF
`define NTSC_LINES 262
`define NTSC_VSYNC_START 249
`define NTSC_VSYNC_END 255
`define NTSC_LINE_LEN 910
`define NTSC_HSYNC_START 22
`define NTSC_4_7_us 67
`define NTSC_HSYNC_END `NTSC_HSYNC_START+`NTSC_4_7_us
`define NTSC_BURST_START 89
`define NTSC_BURST_END `NTSC_BURST_START+35
`define NTSC_BLANK_END `NTSC_HSYNC_START+135

wire reset = !(io_in_buffered[41] && rst_override_n);
reg [11:0] ntsc_luma;
assign sample_raw_1 = reset ? 12'h000 : (12'hFFF - ntsc_luma);

reg [8:0] curr_line;
reg [9:0] curr_hpos;
reg active_period;
reg vsync;
reg v_backporch;

wire [3:0] program_select = io_in_buffered[40:37];
wire color_enable = io_in_buffered[36];
wire pal_sel = io_in_buffered[35];
reg [9:0] active_pixel; // 0 -> 751
reg [7:0] active_line; // 0 -> 245

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
	end else begin
		/*
		 * Sync pulses and counters
		 */
		curr_hpos <= curr_hpos + 1;
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
			end
			if(curr_line == 1) v_backporch <= 0;
		end
		
		/*
		 * Demo-specific code
		 */
		if(active_period) begin
			if(program_select == 0) ntsc_luma <= `NTSC_BLACK_LEVEL; //Black frame
			if(program_select == 1) ntsc_luma <= `NTSC_WHITE_LEVEL; //White frame
			if(program_select == 2) ntsc_luma <= active_pixel[0] ^ active_line[0] == 0 ? `NTSC_BLACK_LEVEL : `NTSC_WHITE_LEVEL; //Fine Checkerboard pattern
			if(program_select == 3) ntsc_luma <= ((active_pixel + {active_line, 1'b0}) & 'h7FF) + `NTSC_BLACK_LEVEL; //Grayscale test pattern
			if(program_select == 4) ntsc_luma <= active_pixel[3] ^ active_line[3] == 0 ? (active_pixel[5] ^ active_pixel[5] == 0 ? `NTSC_BLACK_LEVEL : 12'h555) : (active_pixel[5] ^ active_pixel[5] == 0 ? 12'h999 : `NTSC_WHITE_LEVEL); //Larger checkerboard pattern with some grayscale
		end
	end
end

endmodule
