`default_nettype none

module dram_controller(
`ifdef USE_POWER_PINS
	inout wire VSS,
	inout wire VDD,
`endif
	input clk_i,
	input rst_override_n,
	
	input [41:0] io_in_buffered,
	output [41:0] io_out
);

reg conf_is_a17;

wire rst_n = io_in_buffered[2];
wire reset = !rst_n || !rst_override_n;

wire CSn = io_in_buffered[23];
wire RWn = io_in_buffered[24];
wire CONFn = io_in_buffered[25];
wire [17:0] address = {conf_is_a17 ? CONFn : io_in_buffered[3], io_in_buffered[0], io_in_buffered[22:7]};
reg [8:0] DA;
reg rdy_polarity;
assign io_out[26] = DA[0];
assign io_out[27] = DA[1];
assign io_out[34:29] = DA[7:2];
assign io_out[38] = DA[8];
reg RASn;
assign io_out[35] = RASn;
reg CASn;
assign io_out[36] = CASn;
reg DWn;
assign io_out[37] = DWn;
wire RDY;
reg RDY_l;
assign io_out[1] = RDY ^ rdy_polarity;
reg BEn;
assign io_out[39] = BEn;
reg RLE;
assign io_out[40] = RLE;
reg WLE;
assign io_out[41] = WLE;

//Inputs
assign io_out[22:7] = 0;
assign io_out[25:23] = 0;
assign io_out[0] = 0;
assign io_out[3:2] = 0;

reg [15:0] refresh_timer;
reg [15:0] refresh_interval;
reg needs_refresh;
reg configure_enabled;
reg initial_config;
wire [7:0] conf_val = address[7:0];
reg [3:0] column_bits;
reg page_mode_en;
reg do_data_setup;

//Unused: 4, 5, 6, 28
assign io_out[28] = 1'b0;
assign io_out[6:4] = {needs_refresh, page_mode_en, conf_is_a17};

reg [8:0] column_mask;
always @(*) begin
	case(column_bits)
		0: column_mask = 9'h001;
		1: column_mask = 9'h003;
		2: column_mask = 9'h007;
		3: column_mask = 9'h00F;
		4: column_mask = 9'h01F;
		5: column_mask = 9'h03F;
		6: column_mask = 9'h07F;
		7: column_mask = 9'h0FF;
		default: column_mask = 9'h1FF;
	endcase
end

localparam IDLE = 0;
localparam REFRESH0 = 1;
localparam REFRESH1 = 2;
localparam RAS1 = 3;
localparam RAS_RELEASE = 4;
localparam CAS1 = 5;
localparam CAS2 = 6;
reg [2:0] state;
reg [2:0] next_state;
reg access_type;

reg [17:0] address_latch;
wire [17:0] addr_sel = state == IDLE || state == REFRESH1 ? address : address_latch;
//>> operator is bugged, idk why
reg [8:0] addr_shifted;
always @(*) begin
	case(column_bits)
		0: addr_shifted = addr_sel[9:1];
		1: addr_shifted = addr_sel[10:2];
		2: addr_shifted = addr_sel[11:3];
		3: addr_shifted = addr_sel[12:4];
		4: addr_shifted = addr_sel[13:5];
		5: addr_shifted = addr_sel[14:6];
		6: addr_shifted = addr_sel[15:7];
		7: addr_shifted = addr_sel[16:8];
		default: addr_shifted = addr_sel[17:9];
	endcase
end
wire [8:0] in_row_address = addr_shifted;
wire [8:0] in_col_address = addr_sel & column_mask;

reg [8:0] last_row;
reg [8:0] refresh_row;
reg csb_held;
reg delay_rdy;
reg pause_on_refresh;
reg [1:0] ras_release_targ;

reg [7:0] delay_setup;
reg [7:0] delay_hold;
reg [7:0] delay_ras;
reg [7:0] delay_cas;
reg [7:0] delay_ras_to_cas;
reg [7:0] delay_cas_precharge;
reg [7:0] delay_ras_precharge;
reg [4:0] init_step;
reg [7:0] curr_delay;
reg [7:0] delay_step;

//assign LOEn = !(!CSn && RWn);
wire refresh_states_1 = state == REFRESH0 || (state == RAS_RELEASE && needs_refresh);
wire refresh_states_2 = refresh_states_1 || state == REFRESH1;
wire request_valid = !CSn && initial_config && !csb_held && (state == IDLE || refresh_states_2) && RDY_l && CONFn;
assign RDY = request_valid ? 0 : RDY_l;

always @(posedge clk_i) begin
	WLE <= 1'b0;
	RLE <= 1'b0;
	if(state == IDLE) RDY_l <= 1;
	if(reset) begin
		refresh_timer <= 0;
		refresh_timer <= 16'hFFFF;
		configure_enabled <= 1'b1;
		column_bits <= 7;
		rdy_polarity <= 0;
		state <= IDLE;
		refresh_row <= 0;
		csb_held <= 0;
		delay_step <= 0;
		curr_delay <= 0;
		page_mode_en <= 0;
		RDY_l <= 1'b1;
		RASn <= 1'b1;
		CASn <= 1'b1;
		DWn <= 1'b1;
		BEn <= 1'b1;
		do_data_setup <= 0;
		initial_config <= 0;
		RLE <= 0;
		needs_refresh <= 0;
		refresh_interval <= 6;
		address_latch <= 0;
		init_step <= 0;
		DA <= 9'h1FF;
		delay_rdy <= 0;
		pause_on_refresh <= 0;
		ras_release_targ <= 0;
	end else begin
		if(!needs_refresh && initial_config) refresh_timer <= refresh_timer + 1;
		if(refresh_interval == refresh_timer) begin
			needs_refresh <= 1'b1;
			if(pause_on_refresh) RDY_l <= 1'b0;
		end
		
		csb_held <= !CSn;
		if(!CSn && !CONFn && configure_enabled && !csb_held) begin
			init_step <= init_step + 1;
			case(init_step)
				0: refresh_interval[7:0] <= conf_val;
				1: refresh_interval[15:8] <= conf_val;
				2: begin
					column_bits <= conf_val[3:0];
					rdy_polarity <= conf_val[4];
					page_mode_en <= conf_val[5];
					do_data_setup <= conf_val[6];
					delay_rdy <= conf_val[7];
				end
				3: delay_setup <= conf_val;
				4: delay_hold <= conf_val;
				5: delay_ras <= conf_val;
				6: delay_cas <= conf_val;
				7: delay_ras_to_cas <= conf_val;
				8: delay_ras_precharge <= conf_val;
				9: delay_cas_precharge <= conf_val;
				default: begin
					configure_enabled <= conf_val[0];
					if(conf_val[0]) conf_is_a17 <= conf_val[1];
					pause_on_refresh <= conf_val[7];
					needs_refresh <= 0;
					init_step <= 0;
					initial_config <= 1'b1;
				end
			endcase
		end
		if(request_valid && (!pause_on_refresh || refresh_interval != refresh_timer)) begin
			RDY_l <= 1'b0;
			if(!RWn) WLE <= 1'b1;
			address_latch <= address;
			access_type <= RWn;
			BEn <= RWn;
			if(refresh_states_2) begin
				next_state <= RAS1;
			end else begin
				if(RASn == 0 && last_row == in_row_address && page_mode_en) begin
					DA <= in_col_address;
					state <= CAS1;
					DWn <= RWn;
					if(do_data_setup) begin
						curr_delay <= delay_setup;
						delay_step <= 0;
					end
				end else if(RASn == 0) begin
					state <= RAS_RELEASE;
					ras_release_targ <= 2'b10;
					DA <= in_row_address;
				end else begin
					DA <= in_row_address;
					state <= RAS1;
				end
			end
		end
		
		if(curr_delay != delay_step) delay_step <= delay_step + 1;
		else begin
			case(state)
				IDLE: begin
					if(needs_refresh) begin
						state <= RASn ? REFRESH0 : RAS_RELEASE;
						//last_row <= REFRESH0;
						ras_release_targ <= 2'b01;
						refresh_row <= refresh_row + 1;
						DA <= refresh_row;
						next_state <= request_valid ? RAS1 : IDLE;
					end
				end
				REFRESH0: begin
					RASn <= 1'b0;
					curr_delay <= delay_ras;
					delay_step <= 0;
					state <= REFRESH1;
				end
				REFRESH1: begin
					RASn <= 1'b1;
					curr_delay <= delay_ras_precharge;
					delay_step <= 0;
					state <= request_valid ? RAS1 : next_state;
					needs_refresh <= 0;
					DA <= in_row_address;
					refresh_timer <= 0;
					if(pause_on_refresh && !request_valid) RDY_l <= 1'b1;
				end
				RAS_RELEASE: begin
					RASn <= 1'b1;
					curr_delay <= delay_ras_precharge;
					delay_step <= 0;
					state <= ras_release_targ == 2'b01 ? REFRESH0 : (ras_release_targ == 2'b10 ? RAS1 : IDLE);
				end
				RAS1: begin
					RASn <= 1'b0;
					curr_delay <= delay_ras_to_cas;
					delay_step <= 0;
					last_row <= in_row_address;
					state <= CAS1;
					DWn <= access_type;
					DA <= in_col_address;
				end
				CAS1: begin
					CASn <= 1'b0;
					curr_delay <= delay_cas;
					delay_step <= 0;
					state <= CAS2;
				end
				CAS2: begin
					CASn <= 1'b1;
					curr_delay <= delay_cas_precharge;
					delay_step <= 0;
					state <= page_mode_en ? IDLE : RAS_RELEASE;
					if(!page_mode_en) ras_release_targ <= 0;
					if(access_type) RLE <= 1'b1;
					DWn <= 1'b1;
					BEn <= 1'b1;
					if(!delay_rdy) RDY_l <= 1'b1;
					access_type <= 1'b1;
				end
			endcase
		end
	end
end

endmodule
