`default_nettype none

module cpurv32(
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
	output ALE,
	output reg bus_extend,
	output reg reset_ALE,
	
	output RWn,
	output RWn_oe,
	output [15:0] A_o,
	output A_oe,
	output reg MLn,
	output reg VPn,
	
	output [7:0] D_o,
	input [7:0] D_i,
	output D_oe,
	
	input sync_irqs,
	input sync_rdy,
	input rdy_writes,
	input do_latency,
	
	output reg [7:0] port_val,
	output reg [7:0] port_dir,
	input [7:0] port_in,
	output TXD,
	input RXD,
	output reg uart_reloc
);

assign PH1OUT = PH0IN;
assign PH2OUT = !PH0IN;

assign A_oe = AEC;
assign RWn_oe = AEC;

// Vectors:
// $FFFF_FFF0 - RESERVED
// $FFFF_FFF4 - NMI
// $FFFF_FFF8 - IRQ
// $FFFF_FFFC - RESET

reg nmi_edge;
reg sync_irqs_reg;
reg irqn_sync;
reg nmin_sync;
reg son_sync;
reg nmi_pending;
reg breakpoint_trigger;
wire irq_actual = !(sync_irqs_reg ? irqn_sync : IRQn);
wire nmi_actual = !(sync_irqs_reg ? nmin_sync : NMIn);
wire son_actual = !(sync_irqs_reg ? son_sync : SOn);
wire nmi_edge_detect = nmi_actual && !nmi_edge;

reg [3:0] mem_state;
reg [31:0] mem_buffer;
reg [31:0] addr_buffer;
reg mem_type;
reg mem_extend;
reg ifetch;
reg [1:0] mem_byte;
reg [28:0] reservation_slot;
reg [15:0] addr_hi_latch;
reg just_reset;

reg rdy_latched;
wire rdy_actual = (sync_rdy ? rdy_latched : RDY) || (!rdy_writes && !RWn);
always @(posedge PH0IN) begin
	rdy_latched <= RDY;
end

reg [31:0] ireg;
reg i_ignore;
wire isALUreg = ireg[6:0] == 7'b0110011;
wire isALUimm = ireg[6:0] == 7'b0010011;
wire isBranch = ireg[6:0] == 7'b1100011;
wire isJALR   = ireg[6:0] == 7'b1100111;
wire isJAL    = ireg[6:0] == 7'b1101111;
wire isAUIPC  = ireg[6:0] == 7'b0010111;
wire isLUI    = ireg[6:0] == 7'b0110111;
wire isLoad   = ireg[6:0] == 7'b0000011;
wire isStore  = ireg[6:0] == 7'b0100011;
wire isSYSTEM = ireg[6:0] == 7'b1110011;
wire isAtomic = ireg[6:0] == 7'b0101111;

wire [4:0] rs1Id  = ireg[19:15];
wire [4:0] rs2Id  = ireg[24:20];
wire [4:0] rdId   = ireg[11:7];
wire [2:0] funct3 = ireg[14:12];
wire [4:0] funct5 = ireg[31:27];
wire [6:0] funct7 = ireg[31:25];
wire [11:0] func12 = ireg[31:20];
wire [31:0] Uimm = {ireg[31], ireg[30:12], 12'h000};
wire [31:0] Iimm = {{21{ireg[31]}}, ireg[30:20]};
wire [31:0] Simm = {{21{ireg[31]}}, ireg[30:25], ireg[11:7]};
wire [31:0] Bimm = {{20{ireg[31]}}, ireg[7], ireg[30:25], ireg[11:8], 1'b0};
wire [31:0] Jimm = {{12{ireg[31]}}, ireg[19:12], ireg[20], ireg[30:21], 1'b0};

wire isLoadOrLoadReserved = isLoad || (isAtomic && funct5 == 2);

reg [31:0] PC;
reg [31:0] prev_PC;
wire [31:0] PC_next = PC + 32'h4;
wire [31:0] PC_jmp = prev_PC + (isJAL ? Jimm : Bimm);
reg [31:0] regs [31:0];
wire [31:0] rs1 = regs[rs1Id];
wire [31:0] rs2 = regs[rs2Id];

`ifdef SIM
wire [31:0] zero = regs[0];
wire [31:0] ra = regs[1];
wire [31:0] sp = regs[2];
wire [31:0] gp = regs[3];
wire [31:0] tp = regs[4];
wire [31:0] t0 = regs[5];
wire [31:0] t1 = regs[6];
wire [31:0] t2 = regs[7];
wire [31:0] s0 = regs[8];
wire [31:0] s1 = regs[9];
wire [31:0] a0 = regs[10];
wire [31:0] a1 = regs[11];
`endif

wire [31:0] aluIn1 = isJAL || isAUIPC ? prev_PC : (isAtomic ? mem_buffer : rs1);
wire [31:0] aluIn2 = isStore ? Simm : (isALUreg || isBranch || isAtomic ? rs2 : (isAUIPC ? Uimm : Iimm));
wire [31:0] XOR = aluIn1 ^ aluIn2;
wire [31:0] plus = aluIn2 + aluIn1;
wire EQ = XOR == 0;
wire [32:0] minus = {1'b1, ~aluIn2} + {1'b0, aluIn1} + 33'b1;
wire LT = minus[32];
wire LTS = (aluIn1[31] ^ aluIn2[31]) ? aluIn1[31] : minus[32];
wire [4:0] shift_amount = isALUreg ? rs2[4:0] : ireg[24:20];
wire m1s = (funct3 == 3'b000 || funct3 == 3'b001 || funct3 == 3'b010) && rs1[31];
wire m2s = (funct3 == 3'b000 || funct3 == 3'b001) && rs2[31];
wire [31:0] rs1_inv = (~rs1) + 1;
wire [31:0] rs2_inv = (~rs2) + 1;
wire [31:0] muli1 = m1s ? rs1_inv : rs1;
wire [31:0] muli2 = m2s ? rs2_inv : rs2;
`ifdef SIM
wire [63:0] mul = muli1 * muli2;
`else
wire [63:0] mul;
rv_multiplier rv_multiplier(
	.b(muli2),
	.clk(PH0IN),
	.rst(!rst_n),
	.o(mul),
	.a(muli1)
);
`endif

reg [63:0] div_shifter;
reg [31:0] div_res;
reg [4:0] div_counter;

wire [63:0] mul_res = m1s ^ m2s ? ((~mul) + 1) : mul;
wire signed_div = funct3 == 3'b100 || funct3 == 3'b110;
wire res_sign = signed_div & (rs1[31] ^ rs2[31]);
wire [31:0] divi1 = signed_div && rs1[31] ? rs1_inv : rs1;
wire [31:0] divi2 = signed_div && rs2[31] ? rs2_inv : rs2;
wire [31:0] mod_res = div_shifter[63:32];
wire is_muldiv = funct7 == 1 && isALUreg;
wire is_mul = funct3 < 4;
wire is_div = !is_mul;

wire [3:0] ALUsel = {is_muldiv, funct3};
wire [31:0] div_out = ALUsel == 12 || ALUsel == 13 ? div_res : mod_res;
//Using a trick where both left and right shifts may be implemented with a single barrel-shifter, by conditionally reversing the bit-order going both in and out of the shifter
wire [31:0] shifter_in = (funct3 == 3'b001) ? 
{aluIn1[0], aluIn1[1], aluIn1[2], aluIn1[3], aluIn1[4], aluIn1[5],
aluIn1[6], aluIn1[7], aluIn1[8], aluIn1[9], aluIn1[10], aluIn1[11], aluIn1[12],
aluIn1[13], aluIn1[14], aluIn1[15], aluIn1[16], aluIn1[17], aluIn1[18], aluIn1[19],
aluIn1[20], aluIn1[21], aluIn1[22], aluIn1[23], aluIn1[24], aluIn1[25],
aluIn1[26], aluIn1[27], aluIn1[28], aluIn1[29], aluIn1[30], aluIn1[31]}
 : aluIn1;
wire [31:0] shifter = $signed({funct7[5] & aluIn1[31], shifter_in}) >>> shift_amount;
//ALU function multiplexer
reg [31:0] ALUout;
always @(*) begin
	case(ALUsel)
		0: ALUout = (funct7[5] && ireg[5]) ? minus : plus;
		1: ALUout = {shifter[0], shifter[1], shifter[2], shifter[3], shifter[4], shifter[5], shifter[6],
			shifter[7], shifter[8], shifter[9], shifter[10], shifter[11], shifter[12], shifter[13], shifter[14], shifter[15],
			shifter[16], shifter[17], shifter[18], shifter[19], shifter[20], shifter[21], shifter[22],
			shifter[23], shifter[24], shifter[25], shifter[26], shifter[27], shifter[28], shifter[29],
			shifter[30], shifter[31]};
		2: ALUout = {31'h0, LTS};
		3: ALUout = {31'h0, LT};
		4: ALUout = XOR;
		5: ALUout = shifter;
		6: ALUout = aluIn1 | aluIn2;
		7: ALUout = aluIn1 & aluIn2;
		8: ALUout = mul_res[31:0];
		9: ALUout = mul_res[63:32];
		10: ALUout = mul_res[63:32];
		11: ALUout = mul_res[63:32];
		12: ALUout = res_sign ? (~div_out) + 1 : div_out;
		13: ALUout = div_out;
		14: ALUout = rs1[31] ? (~div_out) + 1 : div_out;
		15: ALUout = div_out;
	endcase
end

//Control flow related logic
reg should_branch;
always @(*) begin
	case(funct3)
		0: should_branch = EQ;
		1: should_branch = !EQ;
		4: should_branch = LTS;
		5: should_branch = !LTS;
		6: should_branch = LT;
		7: should_branch = !LT;
		default: should_branch = 1'bx;
	endcase
end
wire [31:0] jump_PC = isJALR ? plus : PC_jmp;

//NMI
reg [31:0] mnscratch;
reg [31:0] mnepc;
reg NMIE;

//INT
reg [31:0] mepc;
reg wfi;
reg mie;
reg mdt;
reg mpie;

//Peripherals
wire uart_hb;
wire uart_busy;
wire [7:0] uart_dout;
reg [15:0] uart_divisor;
reg [31:0] timer;
reg [31:0] timermatch;

//CSRs
reg [63:0] cycle;
reg [63:0] instret;
reg [37:0] rng;

reg mtie;
reg meie;
reg mtip;
reg meip;
reg [31:0] mscratch;
reg [3:0] mcause;

reg O;
wire [11:0] csr_id = ireg[31:20];
wire [31:0] csr_wval_raw = funct3[2] ? {27'h0, rs1Id} : rs1;
wire csr_write_ignore = (funct3 == 2 || funct3 == 3) && rs1Id == 0;
wire csr_read_ignore = funct3 == 0 && rdId == 0;
wire csr_act = !i_ignore && isSYSTEM && funct3[1:0] != 0 && mem_state == 0 && rdy_actual;

reg [31:0] csr_rval;
always @(*) begin
	case(csr_id)
		default: csr_rval = 32'h00000000;
		12'hF11: csr_rval = 0; //mvendorid
		12'h301: csr_rval = 32'h40401100; //misa (TODO: set bit 0 if A ISA is ever implemented)
		12'hF14: csr_rval = 0; //mhartid
		12'hF12: csr_rval = 32'h82500621; //marchid
		12'hF13: csr_rval = 32'h100; //mimpid, v1.0.0
		12'hFC5: csr_rval = 32'h52494843;
		12'hFC6: csr_rval = 32'h00002150;
		12'hFC7: csr_rval = rng[34:3];
		12'h740: csr_rval = mnscratch;
		12'h741: csr_rval = mnepc;
		12'h742: csr_rval = 32'h80000000; //mncause - always an interrupt on the NMI pin (TODO: maybe do add a break instruction?)
		12'h744: csr_rval = {28'h0, NMIE, 3'b000};
		12'hB00: csr_rval = cycle[31:0];
		12'hB80: csr_rval = cycle[63:32];
		12'hC00: csr_rval = cycle[31:0];
		12'hC80: csr_rval = cycle[63:32];
		12'hC02: csr_rval = instret[31:0];
		12'hC82: csr_rval = instret[63:32];
		12'hBC0: csr_rval = {24'h0, port_dir};
		12'hBC1: csr_rval = {24'h0, (port_val & port_dir) | (port_in & ~port_dir)};
		12'hBC2: csr_rval = {29'h0, bus_extend, O, uart_reloc};
		12'hBC3: csr_rval = timer;
		12'hBC4: csr_rval = timermatch;
		12'h139: csr_rval = uart_busy ? 32'hFFFFFFFF : 32'h0;
		12'h140: csr_rval = uart_hb ? {24'h0, uart_dout} : 32'hFFFFFFFF;
		12'h142: csr_rval = {16'h0000, uart_divisor};
		12'h340: csr_rval = mscratch;
		12'h304: csr_rval = {20'h0, meie, 3'h0, mtie, 7'h00};
		12'h344: csr_rval = {20'h0, meip, 3'h0, mtip, 7'h00};
		12'h341: csr_rval = mepc;
		12'h300: csr_rval = {24'h0, mpie, 3'h0, mie, 3'h0};
		12'h342: csr_rval = {mcause[3], 28'h0, mcause[2:0]};
		12'h310: csr_rval = {21'h0, mdt, 10'h0};
	endcase
end

reg [31:0] csr_wval;
always @(*) begin
	case(funct3[1:0])
		default: csr_wval = 32'hxxxxxxxx;
		1: csr_wval = csr_wval_raw;
		2: csr_wval = csr_wval_raw | csr_rval;
		3: csr_wval = ~csr_wval_raw | csr_rval;
	endcase
end

reg ALE_post;
wire ALE_pre = addr_buffer[31:16] != addr_hi_latch && bus_extend && mem_state || reset_ALE;
assign ALE = ALE_pre && !ALE_post;
assign A_o = !ALE_pre ? addr_buffer[15:0] : addr_buffer[31:16];
assign D_o = mem_buffer[7:0];
assign D_oe = (!RWn && (PH0IN || !do_latency)) && AEC;
assign RWn = !(mem_state && mem_type && !ALE_pre);
always @(posedge PH0IN) ALE_post <= ALE_pre;

reg [2:0] state;
localparam FETCH = 0;
localparam MUL = 1;
localparam DIV1 = 2;
localparam DIV2 = 3;
localparam VECTOR = 4;
localparam ATOMIC = 5;

assign SYNC = ifetch;

wire irq_check = mem_state == 4'b1000 && ifetch;

reg [31:0] mem_in;
always @(*) begin
	case(mem_byte)
		0: mem_in = {{24{mem_extend & D_i[7]}}, D_i};
		1: mem_in = {{16{mem_extend & D_i[7]}}, D_i, mem_buffer[7:0]};
		2: mem_in = {8'hxx, D_i, mem_buffer[15:0]};
		3: mem_in = {D_i, mem_buffer[23:0]};
	endcase
end

always @(negedge PH0IN) begin
	regs[0] <= 0;
	nmi_edge <= nmi_actual & rst_n;
	irqn_sync <= IRQn | rst_n;
	nmin_sync <= NMIn | rst_n;
	son_sync <= SOn | rst_n;
	if(rst_n) begin
		timer <= timer + 1;
		cycle <= cycle + 1;
		if(timer >= timermatch) begin
			timer <= 0;
			mtip <= 1'b1;
		end
		if(nmi_edge_detect) nmi_pending <= 1'b1;
		if(irq_actual && mie) meip <= 1'b1;
	end
	if(!rst_n) begin
		mem_state <= 4'b1000;
		addr_buffer <= 32'hFFFFFFFC;
		state <= VECTOR;
		mem_type <= 1'b0;
		ifetch <= 1'b0;
		ireg <= 0;
		mem_extend <= 0;
		i_ignore <= 0;
		NMIE <= 0;
		cycle <= 0;
		instret <= 0;
		VPn <= 1'b0;
		port_dir <= 8'h0;
		uart_divisor <= 88;
		uart_reloc <= 0;
		O <= 0;
		nmi_pending <= 0;
		mem_byte <= 0;
		sync_irqs_reg <= sync_irqs;
		mtie <= 0;
		meie <= 0;
		mtip <= 0;
		meip <= 0;
		wfi <= 0;
		mie <= 0;
		mdt <= 0;
		mpie <= 0;
		breakpoint_trigger <= 0;
		timer <= 0;
		timermatch <= 32'hFFFFFFFF;
		MLn <= 1'b1;
		bus_extend <= 0;
		reset_ALE <= 0;
		just_reset <= 1'b1;
		addr_hi_latch <= 0;
	end else if(rdy_actual) begin
		if(ALE_pre) addr_hi_latch <= addr_buffer[31:16];
		if(son_actual) O <= 1'b1;
		//Handle irupt in first mem_state
		if(irq_check && nmi_pending && NMIE) begin
			nmi_pending <= 0;
			NMIE <= 0;
			mnepc <= PC;
			mem_state <= 4'b1000;
			VPn <= 0;
			mem_byte <= 0;
			addr_buffer <= 32'hFFFFFFF4;
			ifetch <= 0;
			state <= VECTOR;
			wfi <= 0;
		end else if(irq_check && ((meip && meie && mie) || breakpoint_trigger || (mtip && mtie && mie)) && NMIE) begin
			mcause <= breakpoint_trigger ? 4'h4 : (mtip ? 4'hA : 4'h9);
			if(!breakpoint_trigger && mtip) mtip <= 0;
			if(!breakpoint_trigger && !mtip && meip) meip <= 0;
			breakpoint_trigger <= 0;
			mpie <= mie;
			mie <= 1'b0;
			mepc <= PC;
			mem_state <= 4'b1000;
			VPn <= 0;
			mem_byte <= 0;
			addr_buffer <= 32'hFFFFFFF8;
			ifetch <= 0;
			state <= VECTOR;
			wfi <= 0;
		end else if(mem_state) begin
			if(just_reset) begin
				reset_ALE <= 1'b1;
				just_reset <= 0;
			end else if(reset_ALE) reset_ALE <= 0;
			else if(!bus_extend || addr_buffer[31:16] == addr_hi_latch) begin
				if(!ifetch || !wfi) begin
					mem_state <= {1'b0, mem_state[3:1]};
					mem_byte <= mem_byte + 1;
					addr_buffer <= addr_buffer + 1;
				end
				if(mem_type) begin
					mem_buffer <= {8'hxx, mem_buffer[31:8]};
				end else begin
					mem_buffer <= mem_in;
					if(ifetch) begin
						i_ignore <= 0;
						if(mem_state == 1) begin
							instret <= instret + 1;
							PC <= PC_next;
							prev_PC <= PC;
							ireg <= mem_in;
						end
					end else if((isLoadOrLoadReserved && state == FETCH) || state == ATOMIC) begin
						regs[rdId] <= mem_in;
					end
					if((isLoadOrLoadReserved || isStore) && mem_state == 1 && !ifetch && i_ignore && state == FETCH) begin
						addr_buffer <= PC;
						ifetch <= 1'b1;
						mem_state <= 4'b1000;
						mem_type <= 1'b0;
						mem_byte <= 0;
					end
				end
			end
		end else begin
			case(state)
				FETCH: begin
					addr_buffer <= PC;
					ifetch <= 1'b1;
					mem_state <= 4'b1000;
					mem_type <= 1'b0;
					i_ignore <= 1'b1;
					mem_byte <= 0;
					MLn <= 1'b1;
					
					if(!i_ignore) begin
						if(isSYSTEM) begin
							if(funct3[1:0] != 0) begin
								//Ziscr
								regs[rdId] <= csr_rval;
								if(!csr_write_ignore) begin
									case(csr_id)
										default: begin
										`ifdef SIM
										$display("Invalid CSR write: %x", csr_id);
										`endif
										end
										12'h740: mnscratch <= csr_wval;
										12'h741: mnepc <= csr_wval;
										12'h744: NMIE <= NMIE | csr_wval[3];
										12'hBC0: port_dir <= csr_wval[7:0];
										12'hBC1: port_val <= csr_wval[7:0];
										12'h142: uart_divisor <= csr_wval[15:0];
										12'hBC2: begin
											uart_reloc <= csr_wval[0];
											O <= csr_wval[1];
											bus_extend <= csr_wval[2];
										end
										12'hBC3: timer <= csr_wval;
										12'hBC4: timermatch <= csr_wval;
										12'h139: begin //Silence simulator warning for UTX
										end
										12'hFC5: begin
										end
										12'hFC6: begin
										end
										12'h340: mscratch <= csr_wval;
										12'h304: begin
											mtie <= csr_wval[7];
											meie <= csr_wval[11];
										end
										12'h344: begin
											mtip <= csr_wval[7];
											meip <= csr_wval[11];
										end
										12'h341: mepc <= csr_wval;
										12'h300: begin
											mie <= csr_wval[3];
											mpie <= csr_wval[7];
										end
										12'h342: begin
											mcause[3] <= csr_wval[31];
											mcause[2:0] <= csr_wval[2:0];
										end
										12'h305: begin
											//Because of the 6502-like-ness of this CPU, the vector is in memory
											//Writing this CSR attempts to write that vector
											//...Wait, what? What do you m ean this is cursed?
											mem_state <= 4'b1000;
											addr_buffer <= 32'hFFFFFFF8;
											mem_buffer <= csr_wval;
											mem_type <= 1'b1;
											ifetch <= 1'b0;
										end
										12'h310: mdt <= csr_wval[10];
									endcase
								end
							end else if(funct3 == 0) begin
								//"SYSTEM"
								if(func12 == 12'h702) begin
									//MNRET
									NMIE <= 1'b1;
									PC <= mnepc;
									addr_buffer <= mnepc;
								end else if(func12 == 12'h105) begin
									//WFI
									wfi <= 1'b1;
									mie <= 1'b1;
								end else if(func12[7:0] == 8'h02) begin
									//MRET
									mie <= mpie;
									mpie <= 1'b1;
									PC <= mepc;
									addr_buffer <= mepc;
								end else if(func12 == 1) begin
									//EBREAK 3 breakpoint
									breakpoint_trigger <= 1'b1;
								end
							end
						end else if(is_muldiv) begin
							state <= is_mul ? MUL : DIV1;
							mem_state <= 0;
							if(is_div) begin
								div_counter <= 0;
								div_shifter <= {32'h0, divi1};
								div_res <= 0;
							end
						end else if(isJAL || isJALR) begin
							regs[rdId] <= PC;
							PC <= jump_PC;
							addr_buffer <= jump_PC;
						end else if(isBranch) begin
							if(should_branch) begin
								PC <= PC_jmp;
								addr_buffer <= PC_jmp;
							end
						end else if(isLoad || (isAtomic && funct5 != 3)) begin
							mem_extend <= !funct3[2] | isAtomic;
							mem_state <= funct3[1:0] == 0 ? 4'b0001 : (funct3[1:0] == 1 ? 4'b0010 : 4'b1000);
							addr_buffer <= isAtomic ? rs1 : plus;
							mem_type <= 1'b0;
							ifetch <= 1'b0;
							if(isAtomic && funct5 == 2) reservation_slot <= rs1[31:3];
							if(isAtomic && funct5 != 2) begin
								state <= ATOMIC;
								MLn <= 0;
							end
						end else if(isStore || (isAtomic && funct5 == 3 && rs1[31:3] == reservation_slot)) begin
							mem_state <= funct3[1:0] == 0 ? 4'b0001 : (funct3[1:0] == 1 ? 4'b0010 : 4'b1000);
							addr_buffer <= isAtomic ? rs1 : plus;
							mem_buffer <= rs2;
							mem_type <= 1'b1;
							ifetch <= 1'b0;
						end else if(isLUI) regs[rdId] <= Uimm;
						else if(isAUIPC) regs[rdId] <= plus;
						else if(isALUreg || isALUimm) regs[rdId] <= ALUout;
						if(isAtomic && funct5 == 3) regs[rdId] <= {31'h0, rs1[31:3] != reservation_slot};
					end
				end
				MUL: begin
					//Just a delay cycle to wait for the multiplier to finish
					state <= FETCH;
					regs[rdId] <= ALUout;
				end
				DIV1: begin
					div_res <= {div_res[30:0], div_shifter[62:31] >= divi2};
					if(div_shifter[62:31] >= divi2) div_shifter <= {div_shifter[62:31] - divi2, div_shifter[30:0], 1'b0};
					else div_shifter <= {div_shifter[62:0], 1'b0};
					div_counter <= div_counter + 1;
					if(div_counter == 31) state <= DIV2;
				end
				DIV2: begin
					regs[rdId] <= ALUout;
					state <= FETCH;
				end
				VECTOR: begin
					PC <= mem_buffer;
					VPn <= 1'b1;
					state <= FETCH;
				end
				ATOMIC: begin
				`ifdef SIM
				$display("Atomic op exec");
				`endif
					case(funct5)
						default: mem_buffer <= rs2;
						0: mem_buffer <= plus;
						4: mem_buffer <= XOR;
						12: mem_buffer <= aluIn1 & aluIn2;
						8: mem_buffer <= aluIn1 | aluIn2;
						16: mem_buffer <= $signed(rs2) < $signed(mem_buffer) ? rs2 : mem_buffer;
						20: mem_buffer <= $signed(rs2) > $signed(mem_buffer) ? rs2 : mem_buffer;
						24: mem_buffer <= rs2 < mem_buffer ? rs2 : mem_buffer;
						28: mem_buffer <= rs2 > mem_buffer ? rs2 : mem_buffer;
					endcase
					mem_state <= funct3[1:0] == 0 ? 4'b0001 : (funct3[1:0] == 1 ? 4'b0010 : 4'b1000);
					addr_buffer <= rs1;
					mem_type <= 1'b1;
					mem_byte <= 0;
					ifetch <= 1'b0;
					state <= FETCH;
				end
			endcase
		end
	end
end

always @(negedge PH0IN) begin
	if(!rst_n) rng[0] <= 1'b1;
	else rng <= {rng[36:0], rng[37] ^ rng[36] ^ rng[32] ^ rng[31]};
end

rv_uart rv_uart(
	.clk(PH0IN),
	.rst(!rst_n),
	.divisor(uart_divisor),
	.din(csr_wval[7:0]),
	.dout(uart_dout),
	.TX(TXD),
	.RX(RXD),
	.start(csr_act && csr_id == 12'h139 && !csr_write_ignore),
	.busy(uart_busy),
	.has_byte(uart_hb),
	.clr_hb(csr_act && csr_id == 12'h140 && !csr_read_ignore)
);

endmodule
