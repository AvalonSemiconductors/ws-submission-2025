`default_nettype none

module cpu65(
`ifdef BENCH
	output [7:0] dbg_flags,
	output [7:0] dbg_A,
	output [7:0] dbg_X,
	output [7:0] dbg_Y,
	output [7:0] dbg_SP,
`endif
	input PH0IN,
	output PH1OUT,
	output PH2OUT,
	
	input rst_n,
	input RDY,
	input AEC,
	
	input IRQn,
	input NMIn,
	input SOn,
	output SYNC,
	
	output RWn,
	output RWn_oe,
	output [15:0] A_o,
	output A_oe,
	output MLn,
	output VPn,
	
	output [7:0] D_o,
	input [7:0] D_i,
	output D_oe,
	
	input sync_irqs,
	input sync_rdy,
	input rdy_writes,
	input do_latency,
	
	output bonus_output
);

`ifdef BENCH
assign dbg_flags = PS_combined;
assign dbg_A = A;
assign dbg_X = X;
assign dbg_Y = Y;
assign dbg_SP = SP;
`endif

assign PH1OUT = PH0IN;
assign PH2OUT = !PH0IN;

assign A_oe = AEC;
assign RWn_oe = AEC;

reg [6:0] state;
reg [7:0] ireg;
reg [7:0] A;
reg [7:0] X;
reg [7:0] Y;
reg [7:0] SP;
reg [15:0] PC;
reg [7:0] mem_buffer;
reg [15:0] address_buffer;
reg [1:0] rmw_state;
reg [2:0] chirp_ptr;
reg [6:0] chirpchar;
reg [37:0] rng;

reg irqn_sync;
reg nmin_sync;
reg son_sync;
reg [1:0] vector_loc;
reg break_fetched;
reg addr_carry_del;
reg nmi_edge;
reg nmi_pending;

// -------------------
// |N|V|x|(B)|D|I|Z|C|
// -------------------
reg N;
reg V;
reg D;
reg I;
reg Z;
reg C;
reg E;
//Only IRQ and NMI push B as 0
wire [7:0] PS_combined = {N, V, 1'b1, 1'b1, D, I, Z, C};
assign bonus_output = I;

// Vectors:
// $FFFA - NMI
// $FFFC - RESET
// $FFFE - IRQ

assign SYNC = state[0];
wire irq_actual = !(sync_irqs ? irqn_sync : IRQn) && !I;
wire nmi_actual = !(sync_irqs ? nmin_sync : NMIn);
wire son_actual = !(sync_irqs ? son_sync : SOn);
wire nmi_edge_detect = nmi_actual && !nmi_edge;

/*
 * Decode instruction type
 */
wire is_jam = ireg[3:0] == 4'h2 && (!ireg[7] || ireg[4]);
wire needs_one_byte = ireg[3:2] == 2'b01 || (ireg[3:2] == 2'b00 && ireg[0]) || (ireg[3:0] == 4'h0 && (ireg[4] || ireg[7])) || (ireg[3:0] == 4'h2 && ireg[4] && ireg[7] && !is_jam) || (ireg[3] && !ireg[2] && ireg[0] && !ireg[4]);
wire needs_two_bytes = ireg[3:2] == 2'b11 || (ireg[3] && !ireg[2] && ireg[0] && ireg[4]);
wire is_pull = ireg == 8'h28 || ireg == 8'h68;
wire is_rts = ireg == 8'h60;
wire is_rti = ireg == 8'h40;
wire is_push = ireg == 8'h08 || ireg == 8'h48;
wire type_branch = ireg[3:0] == 0 && ireg[4];
wire type_jsr = ireg == 8'h20;
wire type_indirect16 = ireg == 8'h6C;
wire type_jump = ireg == 8'h4C || type_indirect16;
wire type_return = ireg[3:0] == 0 && !ireg[4] && ireg[7:6] == 2'b01;
wire type_break = ireg == 8'h00;
wire type_implied = (ireg[3:0] == 4'h8 || ireg[3:0] == 4'hA || is_jam) && !is_pull && !is_push;
wire type_imm = ((ireg[3] && !ireg[2] && ireg[0]) || (ireg[7] && !ireg[3] && !ireg[2] && !ireg[0])) && !ireg[4];
wire type_zeropage = !ireg[3] && needs_one_byte && !type_branch && !type_imm;
wire zp_indirect = ireg[3:2] == 2'b00 && ireg[0];
wire type_zp_x = zp_indirect && type_zeropage && !ireg[4];
wire type_zp_y = zp_indirect && type_zeropage && ireg[4];
//Why are you weird?
wire loadstore_column = ireg[7:6] == 2'b10;
wire type_loadstore = loadstore_column && ((ireg[2] || ireg[3:0] == 4'h3 || ireg[3:0] == 4'h1 || ireg == 8'hA0 || ireg == 8'hA2 || ireg[3:0] == 4'hB && ireg[7:4] != 4'h8) || (ireg[3:0] == 4'h9 && ireg[7:4] != 4'h8));
wire type_transfer = (loadstore_column && ireg[3:0] == 4'hA) || ireg == 8'h98 || ireg == 8'hA8;
wire type_absolute = ireg[3] && !type_implied && !type_jump && !type_imm && !is_push && !is_pull;

/*
 * Decode addressing mode
 */
wire index_reg_y = (!ireg[2] && ireg[4]) || (ireg[7:6] == 2'b10 && ireg[4] && ireg[2:1] == 2'b11); //Otherwise, is X
wire is_sbx = ireg == 8'hCB;
wire is_indexed = ireg[4] && !type_implied && ireg[3:0] != 4'h2 && ireg[3:0] != 4'h0;
wire is_rmw = (ireg[3:0] == 4'h3 || ireg[2:1] == 2'b11 || (ireg[3:0] == 4'hB && ireg[4])) && !type_loadstore;
wire is_undoc_rmw = is_rmw && ireg[0];
wire is_doc_rmw = is_rmw && !ireg[0];

wire is_anc = ireg == 8'h0B || ireg == 8'h2B;
wire is_arr = ireg == 8'h6B;
wire anc_column = ireg[3:0] == 4'hB && !ireg[7];
wire shift_a = ireg[3:0] == 4'hA || (anc_column && !ireg[4]);
wire shift_m = anc_column || ireg[3:1] == 3'h3 || ireg[3:1] == 3'h7 || ireg[3:0] == 4'h3;
wire is_special_nop = ireg[7:6] == 2'b11 && (ireg[3:0] == 4'h2 || ireg == 8'hD4 || ireg == 8'hF4 || ireg == 8'hDC || ireg == 8'hFC);
wire is_bit = ireg == 8'h2C || ireg == 8'h24;
wire is_alu = (ireg[7:6] == 2'b11 && !type_implied && !type_branch && !is_special_nop) || (!ireg[7] && ireg[0] && !(anc_column && !ireg[4])) || is_bit;
wire is_compare = (ireg[7:5] == 3'b110 || (ireg[7:5] == 3'b111 && ireg[1:0] == 2'b00) || is_bit) && is_alu;
wire is_flags_op = ireg[3:0] == 4'h8 && ireg[4] && ireg[7:4] != 4'h9;
wire is_addsub = ireg[6:5] == 2'b11 && ireg[0];
wire is_shs = ireg == 8'h9B;
wire is_shs_special_state = is_shs && state[0];
wire is_xaa = ireg == 8'h8B;

wire is_store = type_loadstore && ireg[7:5] == 3'b100;
wire is_load = type_loadstore && ireg[7:5] == 3'b101;

/*
 * Internal bus simulation
 */
wire select_A = ((is_store && ireg[0]) || ireg == 8'h8B || ireg == 8'hA8 || ireg == 8'hAA || is_alu || anc_column) && ireg[3:0] != 4'h0 && (ireg[3:0] != 4'h4 || is_bit) && (ireg[3:0] != 4'hC || is_bit);
wire select_X = (ireg[7:4] == 4'hE && ireg[1:0] == 2'b00) || (ireg[7:5] == 3'b100 && ireg[1] && ireg[3:0] != 4'h2) || ireg == 8'hCA || ireg == 8'hCB;
wire select_Y = (ireg[7:4] == 4'hC && ireg[1:0] == 2'b00) || (ireg[7:5] == 3'b100 && ireg[1:0] == 2'b00 && ireg[3:2] != 2'b00);
wire select_SP = ireg == 8'hBA || ireg == 8'hBB;
wire select_M = is_xaa || is_load || (anc_column && !ireg[4]) || (is_pull && ireg[6]) || (ireg[7:4] == 4'h9 && (ireg[3:0] == 4'h3 || (ireg[3:0] == 4'hB && !is_shs_special_state) || ireg[3:0] == 4'hC || ireg[3:0] == 4'hE || ireg[3:0] == 4'hF));

wire [7:0] A_val_adj = is_xaa ? ((A | 8'hFE) & {3'b111, RDY, 4'hF}) : A;
wire [7:0] anded_bus = ~(~(select_A ? A_val_adj : 8'hFF) | ~(select_X ? X : 8'hFF) | ~(select_Y ? Y : 8'hFF) | ~(select_SP ? SP : 8'hFF) | ~(select_M ? mem_buffer : 8'hFF));

wire funny_cond = ireg[3:0] == 4'h3 || ireg[3:0] == 4'h6 || ireg[3:0] == 4'h7 || ireg[3:0] == 4'hE || ireg[3:0] == 4'hF || (ireg[3:0] == 4'hB && ireg[4]);
wire do_increment = (ireg[7:5] == 3'b111 && funny_cond) || ireg == 8'hE8 || ireg == 8'hC8 || (is_store && !is_shs_special_state);
wire do_decrement = (ireg[7:5] == 3'b110 && funny_cond) || ireg == 8'h88 || ireg == 8'hCA;

wire [7:0] incdec_in = (is_store && !is_shs_special_state) ? D_i : ((type_implied || anc_column || ireg == 8'hBB || is_shs_special_state || is_xaa) ? anded_bus : mem_buffer);
wire [7:0] incdec_bus = do_increment ? incdec_in + 1 : (do_decrement ? incdec_in - 1 : incdec_in);

wire is_shifted = !ireg[7] && (funny_cond || (ireg[3:0] == 4'hA && !ireg[4]) || (ireg[3:0] == 4'hB && !is_anc));
wire is_rotate = ireg[5]; //Differentiates between ASL,LSR and ROL,ROR
wire [7:0] shifter_in = ~(~(shift_a ? A : 8'hFF) | ~(shift_m ? mem_buffer : 8'hFF));
wire [7:0] left_rotated = {shifter_in[6:0], C && is_rotate};
wire [7:0] right_rotated = {C && is_rotate, shifter_in[7:1]};
wire shifter_left = ireg[7:6] == 2'b00;

wire [7:0] processed_bus = is_shifted ? (shifter_left ? left_rotated : right_rotated) : incdec_bus;
wire shifter_carry_out = shifter_left ? shifter_in[7] : shifter_in[0];
wire bus_flag_N = processed_bus[7];
wire bus_flag_Z = processed_bus == 0;

wire write_A = (is_alu || (is_pull && ireg[6]) || anc_column || (is_load && ireg[0]) || ireg == 8'h98 || ireg == 8'h8A || ireg == 8'h8B || (type_implied && is_shifted)) && !is_compare && !is_sbx && !is_doc_rmw;
wire write_X = (ireg[7:5] == 3'b101 && ireg[1] && !is_jam) || ireg == 8'hE8 || ireg == 8'hCA;
wire write_Y = (ireg[7:5] == 3'b101 && ireg[1:0] == 2'b00 && is_load) || ireg == 8'hC8 || ireg == 8'hA8 || ireg == 8'h88;
wire write_SP = ireg == 8'h9A || ireg == 8'h9B || ireg == 8'hBB || is_shs;

/*
 * Control signal assignments
 */
wire data_read_cyc;
wire break_sp_states = (state[2] || state[3] || state[4]) && type_break;
wire jsr_sp_states = (state[3] || state[4]) && type_jsr;
wire rts_sp_states = ((state[2] || state[3] || state[4]) && (is_rts || is_rti)) || (state[5] && is_rti);
assign RWn = !(break_sp_states || jsr_sp_states || rmw_state != 0 || (is_push && state[2]) || (is_store && data_read_cyc));
assign VPn = !(type_break && (state[5] || state[6]));
assign MLn = !(is_rmw && !state[0] && !state[1]);

reg [7:0] dout_combo;
always @(*) begin
	if(rmw_state[0]) dout_combo = mem_buffer;
	else if(rmw_state[1]) dout_combo = processed_bus;
	else if(break_sp_states) begin
		case(state[4:2])
			default: dout_combo = 8'hxx;
			3'b001: dout_combo = PC[15:8];
			3'b010: dout_combo = PC[7:0];
			3'b100: dout_combo = PS_combined ^ {3'b000, !break_fetched, 4'h0};
		endcase
	end else if(jsr_sp_states) begin
		case(state[4:3])
			default: dout_combo = 8'hxx;
			2'b01: dout_combo = PC[15:8];
			2'b10: dout_combo = PC[7:0];
		endcase
	end else if(is_push) begin
		if(ireg[6]) dout_combo = A;
		else dout_combo = PS_combined;
	end else if(is_store && data_read_cyc) dout_combo = anded_bus;
	
	else begin
		dout_combo = 8'hxx;
	end
end
assign D_o = dout_combo;
assign D_oe = (!RWn && (PH0IN || !do_latency)) && AEC;

reg [15:0] addr_out_combo;
always @(*) begin
	if(rmw_state != 0) addr_out_combo = address_buffer;
	else if(break_sp_states || rts_sp_states || (type_jsr && (state[2] || state[3] || state[4])) || (is_push && state[2]) || (is_pull && (state[2] || state[3]))) addr_out_combo = {8'h01, SP};
	else if(type_break && state[5]) addr_out_combo = {13'h1FFF, vector_loc, 1'b0};
	else if(type_break && state[6]) addr_out_combo = {13'h1FFF, vector_loc, 1'b1};
	else if(type_zeropage && (state[2] || state[3] || state[4] || state[5])) addr_out_combo = address_buffer;
	else if(type_absolute && (state[3] || state[4] || state[5])) addr_out_combo = address_buffer;
	else if(type_jump && (state[3] || state[4])) addr_out_combo = address_buffer;
	
	else begin
		addr_out_combo = PC;
	end
end
assign A_o = addr_out_combo;

/*
 * ALU
 */

wire [15:0] mul_o;
`ifdef SIM
assign mul_o = A * Y;
`else
multiplier65 multiplier(
	.a(A),
	.b(Y),
	.o(mul_o)
);
`endif

wire [7:0] ALU_in_1 = anded_bus;
wire [7:0] ALU_in_2 = is_arr ? mem_buffer : processed_bus;
wire ALU_carry_in = is_undoc_rmw ? (ireg[7] | shifter_carry_out) : C;

//Accurate emulation of the 6502 decimal mode, including behavior on invalid BCD values, gets incredibly ugly
//I love how I have to make this intentionally worse by having the non-straight-forward flag outputs
wire [7:0] adder_in_1 = ALU_in_1;
wire [7:0] adder_in_2 = ireg[7:6] == 2'b11 ? ~ALU_in_2 : ALU_in_2;
wire invalid_bcd_lo = (adder_in_1[3:0] > 9) && !(ALU_in_2[3:0] > 9);
wire invalid_bc_hi = (adder_in_1[7:4] > 9) && !(ALU_in_2[7:4] > 9);
wire is_add = ireg[7:5] == 3'b011;
wire adder_carry_in = ireg[7:5] == 3'b111 ? (ALU_carry_in | is_compare) : (ALU_carry_in & !is_arr) | ireg[7:5] == 3'b110;
wire [4:0] half_add = adder_in_1[3:0] + adder_in_2[3:0] + adder_carry_in;
wire enable_decimal_add = D && is_addsub && !is_compare;
wire bcd_half_carry = enable_decimal_add & (half_add[3:0] >= 10);
wire half_carry = half_add[4] | (bcd_half_carry && is_add);
//Uglyness, because need the carry out of bit 6
wire [3:0] upper_half_add_5 = adder_in_1[6:4] + adder_in_2[6:4] + half_carry;
wire [1:0] upper_half_add_6 = adder_in_1[7] + adder_in_2[7] + upper_half_add_5[3];
wire [4:0] upper_half_add = {upper_half_add_6, upper_half_add_5[2:0]};
wire carry6 = upper_half_add_5[3];
wire bcd_carry_out = enable_decimal_add & (upper_half_add[3:0] >= 10);
wire [8:0] adder_out = {upper_half_add, half_add[3:0]} | {bcd_carry_out && is_add, 8'h00};
wire [3:0] bcd_adjust_lo = is_add ? (half_carry ? 4'h6 : 4'h0) : ((bcd_half_carry || !half_carry) && !invalid_bcd_lo ? 4'hA : 4'h0);
wire [3:0] bcd_adjust_hi = is_add ? (adder_out[8] ? 4'h6 : 4'h0) : ((bcd_carry_out || !adder_out[8]) && !invalid_bc_hi ? 4'hA : 4'h0);
wire [8:0] bcd_adjust_adder_out = {adder_out[8], adder_out[7:4] + bcd_adjust_hi, adder_out[3:0] + bcd_adjust_lo};

//I think ALU_in_1 is the result of bus ANDing
//ALU_in_2 is the result of either A or M being shifted and incremented/decremented
reg [8:0] ALU_out;
always @(*) begin
	case(ireg[7:5])
		default: ALU_out = {C, ALU_in_2};
		0: ALU_out = {C, ALU_in_1 | ALU_in_2};
		1: ALU_out = {C, ALU_in_1 & ALU_in_2};
		2: ALU_out = {C, ALU_in_1 ^ ALU_in_2};
		3: ALU_out = adder_out;
		6: ALU_out = adder_out;
		7: ALU_out = adder_out;
	endcase
end
wire new_N = is_bit ? ALU_in_2[7] : ALU_out[7];
wire new_Z = ALU_out[7:0] == 8'h00;
//https://www.righto.com/2013/01/a-small-part-of-6502-chip-explained.html
//Found no easier way to make the V flag compute correctly
wire new_V = is_bit ? ALU_in_2[6] : ((!(adder_in_1[7] | adder_in_2[7]) & carry6) | (!(carry6 | !(adder_in_1[7] & adder_in_2[7]))));

wire addr_carry_add = (type_absolute && state[3]) || (type_zp_y && state[4]) || (type_branch && state[3]);
wire [7:0] addr_adder_in_1 = type_zp_y && state[3] ? mem_buffer : (addr_carry_add ? address_buffer[15:8] : address_buffer[7:0]);
wire [7:0] addr_adder_in_2 = (addr_carry_add || (type_zp_x && state[3]) || (type_zp_y && state[2]) || type_indirect16) ? ({7'h00, addr_carry_del || (type_zp_y && state[2]) || type_zp_x || type_indirect16} | {8{mem_buffer[7] & type_branch}}) : ((is_indexed || type_zp_x) ? (index_reg_y ? Y : X) : (type_branch ? mem_buffer : D_i));
wire [8:0] addr_adder_out = {1'b0, addr_adder_in_1} + {1'b0, addr_adder_in_2};
wire addr_adder_carry_out = type_branch ? (addr_adder_out[8] ^ mem_buffer[7]) : addr_adder_out[8];
wire jump_complete = (type_jump && !type_indirect16 && state[2]) || (type_jump && type_indirect16 && state[4]) || (type_jsr && state[5]);

reg should_branch;
always @(*) begin
	case(ireg[7:5])
		0: should_branch = !N;
		1: should_branch = N;
		2: should_branch = !V;
		3: should_branch = V;
		4: should_branch = !C;
		5: should_branch = C;
		6: should_branch = !Z;
		7: should_branch = Z;
	endcase
end

//The difference is that anything in data_read_cyc is valid for triggering memory stores
//While everything in data_read_cyc_2 should never ever be associated with a store instruction
//This is to prevent any change of "circular logic" (oscillator) forming.
assign data_read_cyc = (type_imm && state[1]) ||
		(type_zeropage && state[2] && !is_indexed && !type_zp_x && !type_zp_y) ||
		(((type_absolute && !is_indexed) || (type_zeropage && is_indexed && !type_zp_x && !type_zp_y)) && state[3]) ||
		(type_zp_x && state[5]) ||
		(type_absolute && is_indexed && !addr_carry_del && state[3] && !is_rmw && !is_store) ||
		(type_absolute && state[4] && !is_rmw) ||
		(type_absolute && state[6] && !is_rmw) ||
		(type_zp_y && !addr_carry_del && state[4] && !is_rmw && !is_store) ||
		(type_zp_y && state[5]) ||
		((type_imm || type_implied) && state[1]) ||
		(type_absolute && !is_indexed && state[3]);

wire data_read_cyc_2 = (type_branch && !addr_adder_carry_out && state[2]) ||
		(is_push && state[2]) ||
		(is_pull && state[3]) ||
		((is_rti || is_rts) && state[5]) ||
		(type_branch && state[3]) ||
		(type_branch && !should_branch && state[1]) ||
		jump_complete ||
		(type_absolute && is_indexed && is_rmw && state[4]);

reg rdy_latched;
wire rdy_actual = (sync_rdy ? rdy_latched : RDY) || (!rdy_writes && !RWn);
always @(posedge PH0IN) begin
	rdy_latched <= RDY;
end

always @(negedge PH0IN) begin
	nmi_edge <= nmi_actual;
	addr_carry_del <= addr_adder_carry_out;
	if(rst_n && nmi_edge_detect) nmi_pending <= 1'b1;
`ifdef BENCH
	if((type_absolute + type_branch + type_jump + type_break + type_imm + is_flags_op + type_return + type_transfer + type_zeropage > 1) || (type_zp_x && type_zp_y)) begin
		$display("ERROR: Instruction identifies as multiple types simultaneously!");
	end
`endif
	irqn_sync <= IRQn;
	nmin_sync <= NMIn;
	son_sync <= SOn;
	if(!rst_n) begin
		state <= 2;
		SP <= 8'hFF;
		vector_loc <= 2'b10;
		PC <= 0;
		A <= 0;
		X <= 0;
		Y <= 0;
		D <= 0;
		I <= 1;
		V <= 0;
		N <= 0;
		Z <= 1;
		C <= 0;
		E <= 0;
		nmi_pending <= 0;
		ireg <= 0;
		break_fetched <= 0;
		rmw_state <= 0;
	end else if(rdy_actual) begin
		rmw_state <= {rmw_state[0], 1'b0};
		state <= {state[5:0], 1'b0};
		if(((state[0] && !irq_actual && !nmi_pending) ||
		(state[1] && break_fetched) ||
		((type_imm || needs_one_byte || needs_two_bytes) && state[1]) ||
		(needs_two_bytes && state[2]) ||
		(type_absolute && state[1]) ||
		(type_jsr && state[1]) ||
		(is_rts && state[5])
		) && !jump_complete) PC <= PC + 1;
		if(jump_complete || (is_rts && state[4]) || (is_rti && state[5])) PC <= {D_i, mem_buffer};
		if((is_rti && state[3]) || (is_pull && state[3] && !ireg[6])) begin
			N <= D_i[7];
			V <= D_i[6];
			D <= D_i[3];
			I <= D_i[2];
			Z <= D_i[1];
			C <= D_i[0];
		end
		if(type_branch && should_branch && state[2]) PC[7:0] <= addr_adder_out[7:0];
		if(type_branch && state[3]) PC[15:8] <= addr_adder_out[7:0];
		if(break_sp_states || jsr_sp_states || (is_push && state[2])) SP <= SP - 1;
		if(((is_rts || is_rti) && (state[2] || state[3])) || (is_rti && state[4]) || (is_pull && state[2])) SP <= SP + 1;
		if(son_actual) V <= 1'b1;
		if(state[0]) begin
			if(irq_actual && !E) begin
				ireg <= 8'h00;
				vector_loc <= 2'b11;
				E <= 0;
			end else if((nmi_pending || nmi_edge_detect) && !E) begin
				nmi_pending <= 1'b0;
				ireg <= 8'h00;
				vector_loc <= 2'b01;
				E <= 0;
			end else begin
				ireg <= D_i;
				E <= ireg == 8'h92; //Extended instruction prefix - reserved for future use
			end
			break_fetched <= D_i == 8'h00;
			if(D_i == 8'h00) vector_loc <= 2'b11;
			update_regs();
		end
		
		if(type_break && state[5]) begin
			PC[7:0] <= D_i;
			I <= 1'b1;
		end
		if(type_break && state[6]) begin
			PC[15:8] <= D_i;
			state <= 1;
		end
		
		if(data_read_cyc || data_read_cyc_2) begin
			mem_buffer <= D_i;
			if(is_rmw) begin
				rmw_state <= 1;
				state <= 0;
			end else state <= 1;
		end
		if(rmw_state[1]) state <= 1;
		if((type_zeropage && is_indexed && state[2]) || (type_absolute && is_indexed && state[2]) || (type_zp_x && (state[2] || state[3])) || (type_zp_y && state[3]) || (type_indirect16 && state[3])) begin
			address_buffer[7:0] <= addr_adder_out[7:0];
			mem_buffer <= incdec_bus;
		end
		if((type_absolute && is_indexed && state[3]) || (type_zp_y && state[4])) address_buffer[15:8] <= addr_adder_out[7:0];
		if((type_zp_x && state[3]) || (type_zp_y && state[2]) || (type_jump && (state[3] || state[1])) || (type_jsr && state[1]) || (type_branch && state[1]) || (is_rts && state[3]) || (is_rti && state[4])) mem_buffer <= D_i;
		if(type_zp_x && state[4]) address_buffer <= {D_i, mem_buffer};
		if(type_zp_y && state[3]) address_buffer[15:8] <= D_i;
		
		if((needs_one_byte || needs_two_bytes) && state[1]) begin
			address_buffer[7:0] <= D_i;
			address_buffer[15:8] <= 8'h00;
		end
		if(needs_two_bytes && state[2]) begin
			address_buffer[15:8] <= D_i;
		end
		
		if(type_branch && state[1]) address_buffer <= PC + 1;

		if(type_implied && state[1] && is_flags_op) begin
			case(ireg[7:5])
				0: C <= 1'b0;
				1: C <= 1'b1;
				2: I <= 1'b0;
				3: I <= 1'b1;
				5: V <= 1'b0;
				6: D <= 1'b0;
				7: D <= 1'b1;
			endcase
		end
		
		//Processor type detect - this specific undocumented NOP sets the V flag only on AvalonSemiconductors CPUs
		if(state[1] && ireg == 8'hF4) V <= 1'b1;
		
		//Re-purposed JAM codes - nobody uses these, so I’m doing my own thing here
		if(ireg == 8'h02 && state[1]) begin
			//Super secret easter egg instruction!
			chirp_ptr <= chirp_ptr + 1;
			A <= {1'b0, chirpchar};
		end
		if(ireg == 8'hF2 && state[1]) begin
			//COR (corrupt) - for testing use only
			A <= rng[7:0];
			X <= rng[15:8];
			Y <= rng[23:16];
			SP <= rng[31:24];
			N <= rng[32];
			V <= rng[33];
			D <= rng[34];
			I <= rng[35];
			Z <= rng[36];
			C <= rng[37];
		end
		if(ireg == 8'hB2 && state[1]) begin
			//MUL - Y,A <= Y * A
			Y <= mul_o[15:8];
			A <= mul_o[7:0];
			Z <= mul_o == 0;
			N <= mul_o[15];
		end
		if(ireg == 8'h92 && state[1]) begin
			//Reserved: prefix for more extended instructions in the future
		end
		if(ireg == 8'h12 && state[1]) begin
			//SEV
			V <= 1'b1;
		end
		if(ireg == 8'h22 && state[1]) begin
		
		end
		if(ireg == 8'h32 && state[1]) begin
		
		end
		if(ireg == 8'h42 && state[1]) begin
		
		end
		if(ireg == 8'h52 && state[1]) begin
		
		end
		if(ireg == 8'h62 && state[1]) begin
		
		end
		if(ireg == 8'h72 && state[1]) begin
		
		end
	end
end

task update_regs;
	begin
		if(write_A) A <= is_alu ? (enable_decimal_add ? bcd_adjust_adder_out[7:0] : ALU_out[7:0]) : processed_bus;
		if(write_X) X <= processed_bus;
		if(is_sbx) X <= ALU_out[7:0];
		if(write_Y) Y <= processed_bus;
		if(write_SP) SP <= processed_bus;
		if((write_A && !is_alu) || write_X || write_Y || is_doc_rmw) begin
			N <= bus_flag_N;
			Z <= bus_flag_Z;
			if(is_arr) begin
				V <= new_V;
				C <= ALU_out[8];
			end else if(is_shifted || is_anc) C <= shifter_carry_out;
		end
		if(is_alu && !is_doc_rmw) begin
			N <= new_N;
			Z <= new_Z;
			if(is_addsub || is_compare) C <= ALU_out[8];
			else if(is_undoc_rmw) C <= shifter_carry_out;
			if((is_addsub && !is_compare) || is_bit) V <= new_V;
		end
	end
endtask

//Pssssst! Secret!
always @(*) begin
	case(chirp_ptr)
		0: chirpchar = 7'h43;
		1: chirpchar = 7'h68;
		2: chirpchar = 7'h69;
		3: chirpchar = 7'h72;
		4: chirpchar = 7'h70;
		5: chirpchar = 7'h21;
		6: chirpchar = 13;
		7: chirpchar = 10;
	endcase
end

//For COR
always @(negedge PH0IN) begin
	if(!rst_n) rng[0] <= 1'b1;
	else rng <= {rng[36:0], rng[37] ^ rng[36] ^ rng[32] ^ rng[31]};
end

endmodule
