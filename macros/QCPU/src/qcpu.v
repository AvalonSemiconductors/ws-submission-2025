`default_nettype none

module qcpu(
	input clk,
	input rst_n,
	
	output reg CS_ROM,
	output reg SCLK_ROM,
	output reg [3:0] ROM_DO,
	input [3:0] ROM_DI,
	output reg ROM_OEB,
	output reg ROM_spi_mode,

	output reg [7:0] PORTA_DDR,
	output reg [7:0] PORTB_DDR,
	output reg [7:0] PORTA,
	output reg [7:0] PORTB,
	input [7:0] PINA,
	input [7:0] PINB,

	output reg RAM_we,
	output [6:0] RAM_addr,
	output [7:0] RAM_in,
	input [7:0] RAM_out,

	output txd,
	input rxd,
	output spi_sclk,
	output spi_do,
	input spi_di,

	output M1,

	input pause,
	output reg pwm,
	output reg toggle,

	input intb
);

//SPI-Mode ROM
reg [4:0] ROM_spi_cycle;
reg [7:0] ROM_spi_dat_out;
reg spi_clkdiv;

//State machine steps
reg [6:0] startup_cycle; //This one’s for the reset sequence
reg [5:0] mem_cycle; //This one is used for handling ROM accesses
reg [1:0] instr_cycle;

//CPU Regs
reg [13:0] PC;
wire [13:0] PC_n = PC + 2;
reg [7:0] regs [15:0];
reg C;
reg Z;
reg IE;
reg TIE;

reg [13:0] ROM_addr_buff; //Which ROM address to access next
reg [13:0] last_addr; //Which ROM address was accessed last, used to detect sequential accesses
reg rom_data_dist; //Where the data read from ROM goes. 0 = instr_buff, 1 = R2, R3

//Instruction latch & decode
reg [15:0] instr_buff;

wire is_immediate = instr_buff[15:12] == 4'b0100;
wire is_EXT = instr_buff[15:8] == 8'b01011111;
wire is_regreg = instr_buff[15:12] == 4'b0101 && !is_EXT;
wire is_jump = instr_buff[15:14] == 2'b00;
wire is_condbr = instr_buff[15:13] == 3'b011;
wire is_load = instr_buff[15:14] == 2'b11;
wire is_store = instr_buff[15:14] == 2'b10;

wire [5:0] base_address = instr_buff[13:8];
wire [3:0] imm_reg = instr_buff[11:8];
wire [3:0] regreg_opc = instr_buff[11:8];
wire [1:0] br_cond = instr_buff[12:11];
wire [10:0] br_rel_dest = instr_buff[10:0];
wire [13:0] jump_dest = instr_buff[13:0];

wire [7:0] imm_val = instr_buff[7:0];
wire [3:0] regreg_r1 = instr_buff[7:4];
wire [3:0] regreg_r2_imm = instr_buff[3:0];
wire [3:0] loadstore_idx_r = instr_buff[3:0];
wire [3:0] loadstore_dest_r = instr_buff[7:4];
wire [3:0] ext_opc = instr_buff[7:4];
wire [3:0] ext_reg = instr_buff[3:0];

wire [13:0] br_rel_dest_se = {br_rel_dest[10], br_rel_dest[10], br_rel_dest[10], br_rel_dest};

reg should_branch;
always @(*) begin
	case(br_cond)
		0: should_branch = !C;
		1: should_branch = C;
		2: should_branch = !Z;
		3: should_branch = Z;
	endcase
end

assign RAM_addr = base_address + regs[loadstore_idx_r];
assign RAM_in = regs[loadstore_dest_r];

//IO Stuff
reg [7:0] IO_addr_buff;
reg [15:0] uart_div;
wire [7:0] uart_rec_byte;
wire uart_busy;
wire uart_has_byte;
reg uart_clear_status;
reg [7:0] spi_div;
wire [7:0] spi_rec_byte;
wire spi_busy;
reg [7:0] timer_div;
reg [15:0] timer;
reg [15:0] timer_capture;
reg [7:0] timer_div_counter;
reg [15:0] timer_top;
reg [7:0] pwm_counter;
reg [7:0] pwm_top;
reg toggle_clkdiv;
reg [15:0] toggle_ctr;
reg [15:0] toggle_top;

//Interrupt stuff
reg had_int;
reg needs_interrupt;
reg [13:0] orig_PC;
reg [3:0] orig_flags;
reg [7:0] orig_IO_addr_buff;
reg needs_timer_interrupt;

//ALU
//wire [15:0] mul_res = regs[1] * regs[ext_reg];
wire [15:0] mul_res;
multiplier multiplier(
	.a(regs[1]),
	.b(regs[ext_reg]),
	.o(mul_res)
);
wire [7:0] RSH = {C & ext_opc[0], regs[ext_reg][7:1]};
wire [7:0] LSH = {regs[ext_reg][6:0], C & ext_opc[0]};
wire [7:0] ROR = {regs[ext_reg][0], regs[ext_reg][7:1]};
wire [7:0] ROL = {regs[ext_reg][6:0], regs[ext_reg][7]};

wire [7:0] rr_r1 = regs[regreg_r1];
wire [7:0] rr_r2 = regs[regreg_r2_imm];
wire [7:0] inv_rr2 = ~rr_r2;
wire [8:0] adderi1 = {1'b0, rr_r1};
wire [8:0] adderi2 = (regreg_opc[3] ? (regreg_opc[1] ? {1'b0, 4'hF, ~regreg_r2_imm} : {1'b0, 4'h0, regreg_r2_imm}) : (regreg_opc[1] ? {1'b0, inv_rr2} : {1'b0, rr_r2}));
wire [8:0] add = adderi1 + adderi2 + (((regreg_opc[1:0] != 0) & C) | (regreg_opc[1:0] == 2));
reg [8:0] ALU_res;
always @(*) begin
	case(regreg_opc)
		0: ALU_res = add;
		1: ALU_res = add;
		2: ALU_res = add;
		3: ALU_res = add;
		4: ALU_res = {C, rr_r1 & rr_r2};
		5: ALU_res = {C, rr_r1 | rr_r2};
		6: ALU_res = {C, rr_r1 ^ rr_r2};
		7: ALU_res = {C, inv_rr2};
		8: ALU_res = add;
		9: ALU_res = add;
		10: ALU_res = add;
		11: ALU_res = add;
		default: ALU_res = {C, rr_r1};
	endcase
end

`ifdef SIM
wire [7:0] R0 = regs[0];
wire [7:0] R1 = regs[1];
wire [7:0] R2 = regs[2];
wire [7:0] R3 = regs[3];
wire [7:0] R4 = regs[4];
wire [7:0] R5 = regs[5];
wire [7:0] R6 = regs[6];
wire [7:0] R7 = regs[7];
wire [7:0] R8 = regs[8];
wire [7:0] R9 = regs[9];
wire [7:0] R10 = regs[10];
wire [7:0] R11 = regs[11];
wire [7:0] R12 = regs[12];
wire [7:0] R13 = regs[13];
wire [7:0] R14 = regs[14];
wire [7:0] R15 = regs[15];
`endif

assign M1 = instr_cycle == 0;

always @(posedge clk) begin
	uart_clear_status <= 0;
	if(!rst_n) begin
		CS_ROM <= 1'b1;
		SCLK_ROM <= 1'b0;
		ROM_DO <= 4'b1100;
		ROM_OEB <= 1'b1;
		ROM_spi_mode <= 1'b1;
		ROM_spi_dat_out <= 8'h00;
		ROM_spi_cycle <= 5'h00;
		startup_cycle <= 7'h01;
		mem_cycle <= 6'h00;
		spi_clkdiv <= 0;
		last_addr <= 14'h3FFF;
		PC <= 0;
		instr_buff <= 16'h0000;
		regs[0] <= 8'h00;
		instr_cycle <= 2'h0;
		C <= 1'b0;
		Z <= 1'b0;
		IE <= 1'b0;
		TIE <= 1'b0;
		IO_addr_buff <= 8'h00;
		PORTA_DDR <= 8'h00;
		PORTB_DDR <= 8'h00;
		PORTA <= 8'h00;
		PORTB <= 8'h00;
		RAM_we <= 0;
		uart_div <= 8'h02;
		timer_div <= 8'h05;
		timer <= 0;
		timer_capture <= 0;
		timer_div_counter <= 0;
		timer_top <= 16'hFFFF;
		had_int <= 1'b1;
		needs_interrupt <= 1'b0;
		orig_PC <= 0;
		orig_IO_addr_buff <= 0;
		orig_flags <= 0;
		pwm <= 1'b0;
		pwm_counter <= 8'h00;
		pwm_top <= 8'h80;
		toggle <= 1'b0;
		toggle_clkdiv <= 1'b0;
		toggle_ctr <= 16'h0000;
		toggle_top <= 16'h0100;
	end else begin
		pwm_counter <= pwm_counter + 1;
		if(pwm_counter == pwm_top) pwm <= 1'b1;
		if(pwm_counter == 8'h00) pwm <= 1'b0;
		toggle_clkdiv <= !toggle_clkdiv;
		if(toggle_clkdiv) begin
			toggle_ctr <= toggle_ctr + 1;
			if(toggle_ctr >= toggle_top) begin
				toggle_ctr <= 0;
				toggle <= !toggle;
			end
		end
		timer_div_counter <= timer_div_counter + 1;
		if(timer_div_counter == timer_div) begin
			timer_div_counter <= 0;
			timer <= timer + 1;
			if(timer >= timer_top && TIE) begin
				needs_timer_interrupt <= 1'b1;
				timer <= 0;
			end
		end
		regs[0] <= 8'h00; //Ensure R0 is always 0
		had_int <= intb;
		if(!intb && had_int) begin
			needs_interrupt <= 1'b1;
		end
		//For sending data to spiflash in SPI mode
		//Only briefly used to transition the device into QSPI mode
		if(ROM_spi_cycle != 0) begin
			spi_clkdiv <= !spi_clkdiv;
			if(spi_clkdiv) begin
				ROM_spi_cycle <= ROM_spi_cycle == 17 ? 0 : ROM_spi_cycle + 1;
				if(ROM_spi_cycle[0]) begin
					SCLK_ROM <= 1'b0;
					ROM_DO[0] <= ROM_spi_dat_out[7];
					ROM_spi_dat_out <= {ROM_spi_dat_out[6:0], 1'b0};
				end else begin
					SCLK_ROM <= 1'b1;
				end
			end
		end else if(startup_cycle != 0) begin
			startup_cycle <= startup_cycle + 1;
			case(startup_cycle)
				1: begin
					CS_ROM <= 0;
					ROM_spi_dat_out <= 8'hFF;
					ROM_spi_cycle <= 1;
				end
				2: begin
					CS_ROM <= 1;
				end
				4: begin
					CS_ROM <= 0;
					ROM_spi_dat_out <= 8'hAB;
					ROM_spi_cycle <= 1;
				end
				5: begin
					ROM_spi_dat_out <= 8'h00;
					ROM_spi_cycle <= 1;
				end
				7: begin
					ROM_spi_dat_out <= 8'h00;
					ROM_spi_cycle <= 1;
				end
				8: begin
					ROM_spi_dat_out <= 8'h00;
					ROM_spi_cycle <= 1;
				end
				10: begin
					ROM_spi_dat_out <= 8'h00;
					ROM_spi_cycle <= 1;
				end
				11: begin
					CS_ROM <= 1;
				end
				15: begin
					CS_ROM <= 0;
					ROM_spi_dat_out <= 8'hEB;
					ROM_spi_cycle <= 1;
				end
				16: begin
					ROM_OEB <= 0;
					ROM_spi_mode <= 0;
					ROM_DO <= 4'h0;
				end
				//20 - 23
				18: SCLK_ROM <= 1;
				20: SCLK_ROM <= 0;
				//16 - 19
				22: SCLK_ROM <= 1;
				24: SCLK_ROM <= 0;
				//12 - 15
				26: SCLK_ROM <= 1;
				28: SCLK_ROM <= 0;
				//8 - 11
				30: SCLK_ROM <= 1;
				32: SCLK_ROM <= 0;
				//4 - 7
				34: SCLK_ROM <= 1;
				36: SCLK_ROM <= 0;
				//0 - 3
				38: SCLK_ROM <= 1;
				40: begin
					SCLK_ROM <= 0;
					ROM_DO <= 4'b1010;
				end
				42: SCLK_ROM <= 1; //M4 - M7
				44: begin
					SCLK_ROM <= 0;
					ROM_DO <= 4'b0101;
				end
				46: SCLK_ROM <= 1; //M0 - M3
				48: begin
					SCLK_ROM <= 0;
					ROM_OEB <= 1;
				end
				50: SCLK_ROM <= 1;
				52: SCLK_ROM <= 0;
				54: SCLK_ROM <= 1;
				56: SCLK_ROM <= 0;
				58: SCLK_ROM <= 1;
				60: SCLK_ROM <= 0;
				62: SCLK_ROM <= 1;
				64: SCLK_ROM <= 0;
				66: SCLK_ROM <= 1;
				68: SCLK_ROM <= 0;
				70: SCLK_ROM <= 1;
				72: SCLK_ROM <= 0;
				74: SCLK_ROM <= 1;
				76: SCLK_ROM <= 0;
				78: CS_ROM <= 1;
				82: startup_cycle <= 0;
			endcase
		end else if(mem_cycle != 0) begin
			mem_cycle <= mem_cycle + 1;
			case(mem_cycle)
				1: begin
					last_addr <= ROM_addr_buff;
					if(last_addr + 1 == ROM_addr_buff) begin
						//Sequential read, just clock the flash a few times to get it
						mem_cycle <= 27;
					end else begin
						//Non-sequential read, need to restart spiflash read with a new address
						CS_ROM <= 1;
						SCLK_ROM <= 0;
					end
				end
				2: begin
					CS_ROM <= 0;
					ROM_DO <= 4'h0;
					ROM_OEB <= 0;
				end
				3: SCLK_ROM <= 1;
				4: SCLK_ROM <= 0;
				5: SCLK_ROM <= 1;
				6: begin
					SCLK_ROM <= 0;
					ROM_DO <= {1'b0, ROM_addr_buff[13:11]};
				end
				7: SCLK_ROM <= 1;
				8: begin
					SCLK_ROM <= 0;
					ROM_DO <= ROM_addr_buff[10:7];
				end
				9: SCLK_ROM <= 1;
				10: begin
					SCLK_ROM <= 0;
					ROM_DO <= ROM_addr_buff[6:3];
				end
				11: SCLK_ROM <= 1;
				12: begin
					SCLK_ROM <= 0;
					ROM_DO <= {ROM_addr_buff[2:0], 1'b0};
				end
				13: SCLK_ROM <= 1;
				14: begin
					SCLK_ROM <= 0;
					ROM_DO <= 4'b1010;
				end
				15: SCLK_ROM <= 1;
				16: begin
					SCLK_ROM <= 0;
					ROM_DO <= 4'b0101;
				end
				17: SCLK_ROM <= 1;
				18: begin
					SCLK_ROM <= 0;
					ROM_OEB <= 1;
				end
				19: SCLK_ROM <= 1;
				20: SCLK_ROM <= 0;
				21: SCLK_ROM <= 1;
				22: SCLK_ROM <= 0;
				23: SCLK_ROM <= 1;
				24: SCLK_ROM <= 0;
				25: SCLK_ROM <= 1;
				26: SCLK_ROM <= 0;

				27: begin
					SCLK_ROM <= 1;
					if(rom_data_dist) regs[2][7:4] <= ROM_DI;
					else instr_buff[15:12] <= ROM_DI;
				end
				28: SCLK_ROM <= 0;
				29: begin
					SCLK_ROM <= 1;
					if(rom_data_dist) regs[2][3:0] <= ROM_DI;
					else instr_buff[11:8] <= ROM_DI;
				end
				30: SCLK_ROM <= 0;
				31: begin
					SCLK_ROM <= 1;
					if(rom_data_dist) regs[1][7:4] <= ROM_DI;
					else instr_buff[7:4] <= ROM_DI;
				end
				32: SCLK_ROM <= 0;
				33: begin
					SCLK_ROM <= 1;
					if(rom_data_dist) regs[1][3:0] <= ROM_DI;
					else instr_buff[3:0] <= ROM_DI;
				end
				34: begin
					SCLK_ROM <= 0;
					mem_cycle <= 0;
				end
			endcase
		end else begin
			if(instr_cycle == 0) begin
				if(!pause) begin
					if(needs_timer_interrupt && TIE) begin
						instr_cycle <= 3;
						needs_timer_interrupt <= 1'b0;
					end else if(needs_interrupt && IE) begin
						instr_cycle <= 2;
						needs_interrupt <= 1'b0;
					end else begin
						ROM_addr_buff <= PC;
						mem_cycle <= 1;
						instr_cycle <= 1;
						rom_data_dist <= 0;
						RAM_we <= 0;
						instr_buff <= 0;
					end
				end
			end else if(instr_cycle == 1) begin
				if(is_immediate) begin
					if(imm_reg == 0) IO_addr_buff <= imm_val;
					else regs[imm_reg] <= imm_val;
					instr_cycle <= 0;
					PC <= PC + 1;
				end
				if(is_jump) begin
					PC <= jump_dest;
					instr_cycle <= 0;
				end
				if(is_condbr) begin
					if(should_branch) begin
						PC <= PC + br_rel_dest_se;
					end else begin
						PC <= PC + 1;
					end
					instr_cycle <= 0;
				end
				if(is_EXT && ext_opc == 7) begin
					//IO Write, handled separately
					case(IO_addr_buff)
						0: PORTA_DDR <= regs[ext_reg];
						1: PORTA <= regs[ext_reg];
						2: PORTB_DDR <= regs[ext_reg];
						3: PORTB <= regs[ext_reg];
						6: uart_div[7:0] <= regs[ext_reg];
						7: uart_div[15:8] <= regs[ext_reg];
						10: spi_div <= regs[ext_reg];
						12: timer_div <= regs[ext_reg];
						13: timer_capture <= timer; //Value written is ignored, timer is captured
						14: timer_capture[7:0] <= regs[ext_reg];
						15: timer_capture[15:8] <= regs[ext_reg];
						16: timer <= timer_capture; //Value written is ignored, capture is written to timer
						17: timer_top[7:0] <= regs[ext_reg];
						18: timer_top[15:8] <= regs[ext_reg];
						19: pwm_top <= regs[ext_reg];
						20: toggle_top[7:0] <= regs[ext_reg];
						21: toggle_top[15:8] <= regs[ext_reg];
					endcase
					PC <= PC + 1;
					instr_cycle <= 0;
				end
				else if(is_EXT && ext_opc == 8) begin
					//IO Read, handled separately
					case(IO_addr_buff)
						0: regs[ext_reg] <= PORTA_DDR;
						1: regs[ext_reg] <= PORTA;
						2: regs[ext_reg] <= PORTB_DDR;
						3: regs[ext_reg] <= PORTB;
						4: regs[ext_reg] <= PINA;
						5: regs[ext_reg] <= PINB;
						6: regs[ext_reg] <= uart_div[7:0];
						7: regs[ext_reg] <= uart_div[15:8];
						8: begin
							regs[ext_reg] <= uart_rec_byte;
							uart_clear_status <= 1;
						end
						9: begin
							regs[ext_reg] <= {5'b0, spi_busy, uart_has_byte, uart_busy};
						end
						10: regs[ext_reg] <= spi_div;
						11: regs[ext_reg] <= spi_rec_byte;
						12: regs[ext_reg] <= timer_div;
						14: regs[ext_reg] <= timer_capture[7:0];
						15: regs[ext_reg] <= timer_capture[15:8];
						17: regs[ext_reg] <= timer_top[7:0];
						18: regs[ext_reg] <= timer_top[15:8];
						19: regs[ext_reg] <= pwm_top;
						20: regs[ext_reg] <= toggle_top[7:0];
						21: regs[ext_reg] <= toggle_top[15:8];
					endcase
					PC <= PC + 1;
					instr_cycle <= 0;
				end
				else if(is_EXT && ext_opc == 10) begin
					//Wait for UART and SPI to complete
					if(!uart_busy && !spi_busy) begin
						PC <= PC + 1;
						instr_cycle <= 0;
					end
				end
				else if(is_EXT && ext_opc != 7) begin
					if(ext_opc == 0 || ext_opc == 1) begin
						regs[ext_reg] <= RSH;
						C <= regs[ext_reg][0];
						Z <= RSH == 0;
					end
					if(ext_opc == 2 || ext_opc == 3) begin
						regs[ext_reg] <= LSH;
						C <= regs[ext_reg][7];
						Z <= LSH == 0;
					end
					case(ext_opc)
						4: begin
							regs[ext_reg] <= ROR;
							Z <= ROR == 0;
						end
						5: begin
							regs[ext_reg] <= ROL;
							Z <= ROL == 0;
						end
						6: IO_addr_buff <= regs[ext_reg];
						9: begin
							C <= regs[1] >= ext_reg;
							Z <= regs[1] == ext_reg;
						end
						11: begin
							PC <= orig_PC;
							IO_addr_buff <= orig_IO_addr_buff;
							TIE <= orig_flags[3];
							IE <= orig_flags[2];
							Z <= orig_flags[1];
							C <= orig_flags[0];
						end
						12: begin
							regs[1] <= mul_res[7:0];
							regs[2] <= mul_res[15:8];
						end
						13: regs[ext_reg] <= {4'h0, TIE, IE, Z, C};
						14: begin
							TIE <= regs[ext_reg][3];
							IE <= regs[ext_reg][2];
							Z <= regs[ext_reg][1];
							C <= regs[ext_reg][0];
						end
						15: begin
							rom_data_dist <= 1;
							mem_cycle <= 1;
							ROM_addr_buff <= {regs[3], regs[2]};
						end
					endcase
					if(ext_opc != 11) PC <= PC + 1;
					instr_cycle <= 0;
				end
				if(is_regreg) begin
					if(regreg_opc == 12) begin
						regs[1] <= PC_n[7:0];
						regs[2] <= {2'b00, PC_n[13:8]};
						PC <= PC + 1;
					end else if(regreg_opc == 13) begin
						PC <= {regs[2][5:0], regs[1]};
					end else if(regreg_opc == 14) begin
						C <= regs[regreg_r1] >= regs[regreg_r2_imm];
						Z <= regs[regreg_r1] == regs[regreg_r2_imm];
						PC <= PC + 1;
					end else begin
						regs[regreg_r1] <= ALU_res[7:0];
						C <= ALU_res[8];
						Z <= ALU_res[7:0] == 0;
						PC <= PC + 1;
					end
					instr_cycle <= 0;
				end
				if(is_load) begin
					regs[loadstore_dest_r] <= RAM_out;
					PC <= PC + 1;
					instr_cycle <= 0;
				end
				if(is_store) begin
					PC <= PC + 1;
					instr_cycle <= 0;
					RAM_we <= 1;
				end
			end else if(instr_cycle == 2 || instr_cycle == 3) begin
				//Interrupt action
				orig_PC <= PC;
				orig_IO_addr_buff <= IO_addr_buff;
				orig_flags <= {TIE, IE, Z, C};
				IE <= 0;
				TIE <= 0;
				PC <= instr_cycle == 2 ? 14'h0001 : 14'h0002;
				instr_cycle <= 0;
			end
		end
	end
end

qcpu_uart uart(
	.divisor(uart_div),
	.din(regs[ext_reg]),
	.dout(uart_rec_byte),
	.TX(txd),
	.RX(rxd),
	.start(instr_cycle == 1 && is_EXT && ext_opc == 7 && IO_addr_buff == 8),
	.busy(uart_busy),
	.has_byte(uart_has_byte),
	.clr_hb(uart_clear_status),
	.clk(clk),
	.rst(~rst_n)
);

qcpu_spi spi(
	.divisor(spi_div),
	.din(regs[ext_reg]),
	.dout(spi_rec_byte),
	.SCLK(spi_sclk),
	.DO(spi_do),
	.DI(spi_di),
	.start(instr_cycle == 1 && is_EXT && ext_opc == 7 && IO_addr_buff == 11),
	.busy(spi_busy),
	.clk(clk),
	.rst(~rst_n)
);

endmodule
