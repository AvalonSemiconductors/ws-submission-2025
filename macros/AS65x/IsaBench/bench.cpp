#include "Vcpu65_tb.h"
#include "verilated.h"
#include <iostream>
#include <source_location>
#include <random>
#include <iomanip>

#define I_NOP 0xEA
#define I_NOP_IMM 0x80

#define I_LDA_IMM 0xA9
#define I_LDY_IMM 0xA0
#define I_LDX_IMM 0xA2
#define I_LAX_IMM 0xAB
#define I_ORA_IMM 0x09
#define I_AND_IMM 0x29
#define I_EOR_IMM 0x49
#define I_ADC_IMM 0x69
#define I_CMP_IMM 0xC9
#define I_SBC_IMM 0xE9
#define I_ANC_IMM 0x0B
#define I_ANC2_IMM 0x2B
#define I_ASR_IMM 0x4B
#define I_ARR_IMM 0x6B
#define I_XAA_IMM 0x8B
#define I_SBX_IMM 0xCB
#define I_SBC2_IMM 0xEB
#define I_CPY_IMM 0xC0
#define I_CPX_IMM 0xE0

#define I_CLC 0x18
#define I_SEC 0x38
#define I_CLI 0x58
#define I_SEI 0x78
#define I_CLV 0xB8
#define I_CLD 0xD8
#define I_SED 0xF8

#define I_ASL 0x0A
#define I_ROL 0x2A
#define I_LSR 0x4A
#define I_ROR 0x6A

#define I_DEY 0x88
#define I_INY 0xC8
#define I_INX 0xE8
#define I_DEX 0xCA
#define I_TYA 0x98
#define I_TAY 0xA8
#define I_TXA 0x8A
#define I_TXS 0x9A
#define I_TAX 0xAA
#define I_TSX 0xBA

#define I_ORA_A8 0x05
#define I_AND_A8 0x25
#define I_EOR_A8 0x45
#define I_ADC_A8 0x65
#define I_LDA_A8 0xA5
#define I_CMP_A8 0xC5
#define I_SBC_A8 0xE5
#define I_LDY_A8 0xA4
#define I_LDX_A8 0xA6
#define I_LAX_A8 0xA7
#define I_CPY_A8 0xC4
#define I_CPX_A8 0xE4

#define I_ORA_A8X 0x15
#define I_AND_A8X 0x35
#define I_EOR_A8X 0x55
#define I_ADC_A8X 0x75
#define I_LDA_A8X 0xB5
#define I_CMP_A8X 0xD5
#define I_SBC_A8X 0xF5
#define I_LDY_A8X 0xB4
#define I_LDX_A8Y 0xB6
#define I_LAX_A8Y 0xB7

#define I_ORA_A16 0x0D
#define I_AND_A16 0x2D
#define I_EOR_A16 0x4D
#define I_ADC_A16 0x6D
#define I_CMP_A16 0xCD
#define I_CPY_A16 0xCC
#define I_CPX_A16 0xEC
#define I_SBC_A16 0xED
#define I_LDY_A16 0xAC
#define I_LDA_A16 0xAD
#define I_LDX_A16 0xAE
#define I_LAX_A16 0xAF
#define I_NOP_A16 0x0C

#define I_ORA_A16X 0x1D
#define I_AND_A16X 0x3D
#define I_EOR_A16X 0x5D
#define I_ADC_A16X 0x7D
#define I_CMP_A16X 0xDD
#define I_SBC_A16X 0xFD
#define I_LDA_A16X 0xBD
#define I_LDY_A16X 0xBC

#define I_ORA_A16Y 0x19
#define I_AND_A16Y 0x39
#define I_EOR_A16Y 0x59
#define I_ADC_A16Y 0x79
#define I_CMP_A16Y 0xD9
#define I_SBC_A16Y 0xF9
#define I_LDA_A16Y 0xB9
#define I_LDX_A16Y 0xBE
#define I_LAX_A16Y 0xBF
#define I_LAS_A16Y 0xBB

#define I_ORA_A8_INDIR_X 0x01
#define I_AND_A8_INDIR_X 0x21
#define I_EOR_A8_INDIR_X 0x41
#define I_ADC_A8_INDIR_X 0x61
#define I_CMP_A8_INDIR_X 0xC1
#define I_SBC_A8_INDIR_X 0xE1
#define I_LDA_A8_INDIR_X 0xA1
#define I_LAX_A8_INDIR_X 0xA3

#define I_ORA_A8_INDIR_Y 0x11
#define I_AND_A8_INDIR_Y 0x31
#define I_EOR_A8_INDIR_Y 0x51
#define I_ADC_A8_INDIR_Y 0x71
#define I_CMP_A8_INDIR_Y 0xD1
#define I_SBC_A8_INDIR_Y 0xF1
#define I_LDA_A8_INDIR_Y 0xB1
#define I_LAX_A8_INDIR_Y 0xB3

#define I_INC_A8 0xE6
#define I_INC_A8X 0xF6
#define I_DEC_A8 0xC6
#define I_DEC_A8X 0xD6
#define I_INC_A16 0xEE
#define I_INC_A16X 0xFE
#define I_DEC_A16 0xCE
#define I_DEC_A16X 0xDE

#define I_ASL_A8 0x06
#define I_ROL_A8 0x26
#define I_LSR_A8 0x46
#define I_ROR_A8 0x66
#define I_ASL_A8X 0x16
#define I_ROL_A8X 0x36
#define I_LSR_A8X 0x56
#define I_ROR_A8X 0x76

#define I_ASL_A16 0x0E
#define I_ROL_A16 0x2E
#define I_LSR_A16 0x4E
#define I_ROR_A16 0x6E
#define I_ASL_A16X 0x1E
#define I_ROL_A16X 0x3E
#define I_LSR_A16X 0x5E
#define I_ROR_A16X 0x7E

#define I_SLO_A8 0x07
#define I_RLA_A8 0x27
#define I_SRE_A8 0x47
#define I_RRA_A8 0x67
#define I_SLO_A8X 0x17
#define I_RLA_A8X 0x37
#define I_SRE_A8X 0x57
#define I_RRA_A8X 0x77

#define I_SLO_A16Y 0x1B
#define I_RLA_A16Y 0x3B
#define I_SRE_A16Y 0x5B
#define I_RRA_A16Y 0x7B

#define I_SLO_A16 0x0F
#define I_RLA_A16 0x2F
#define I_SRE_A16 0x4F
#define I_RRA_A16 0x6F
#define I_SLO_A16X 0x1F
#define I_RLA_A16X 0x3F
#define I_SRE_A16X 0x5F
#define I_RRA_A16X 0x7F

#define I_SLO_A8_INDIR_X 0x03
#define I_RLA_A8_INDIR_X 0x23
#define I_SRE_A8_INDIR_X 0x43
#define I_RRA_A8_INDIR_X 0x63

#define I_SLO_A8_INDIR_Y 0x13
#define I_RLA_A8_INDIR_Y 0x33
#define I_SRE_A8_INDIR_Y 0x53
#define I_RRA_A8_INDIR_Y 0x73

#define I_DCP_A8 0xC7
#define I_ISC_A8 0xE7
#define I_DCP_A8X 0xD7
#define I_ISC_A8X 0xF7

#define I_DCP_A16 0xCF
#define I_ISC_A16 0xEF
#define I_DCP_A16X 0xDF
#define I_ISC_A16X 0xFF
#define I_DCP_A16Y 0xDB
#define I_ISC_A16Y 0xFB

#define I_DCP_A8_INDIR_X 0xC3
#define I_ISC_A8_INDIR_X 0xE3

#define I_DCP_A8_INDIR_Y 0xD3
#define I_ISC_A8_INDIR_Y 0xF3

#define I_JMP 0x4C
#define I_JMP_INDIR 0x6C

#define I_BPL 0x10
#define I_BMI 0x30
#define I_BVC 0x50
#define I_BVS 0x70
#define I_BCC 0x90
#define I_BCS 0xB0
#define I_BNE 0xD0
#define I_BEQ 0xF0

#define I_JSR 0x20
#define I_RTS 0x60
#define I_BRK 0x00
#define I_RTI 0x40

#define I_PHP 0x08
#define I_PLP 0x28
#define I_PHA 0x48
#define I_PLA 0x68

#define I_BIT_A8 0x24
#define I_BIT_A16 0x2C

#define I_STA_A8 0x85
#define I_STX_A8 0x86
#define I_STY_A8 0x84
#define I_SAX_A8 0x87
#define I_STA_A8X 0x95
#define I_STX_A8X 0x96
#define I_STY_A8X 0x94
#define I_SAX_A8Y 0x97
#define I_STA_A8_INDIR_X 0x81
#define I_SAX_A8_INDIR_X 0x83
#define I_STA_A8_INDIR_Y 0x91
#define I_SHA_A8_INDIR_Y 0x93
#define I_STA_A16 0x8D
#define I_STX_A16 0x8E
#define I_STY_A16 0x8C
#define I_SAX_A16 0x8F
#define I_STA_A16X 0x9D
#define I_STA_A16Y 0x99
#define I_SHS_A16Y 0x9B
#define I_SHY_A16X 0x9C
#define I_SHX_A16Y 0x9E
#define I_SHA_A16Y 0x9F

const uint8_t implied_nops[] = {0x1A, 0x3A, 0x5A, 0x7A, 0xDA, 0xEA, 0xFA, 0};
const uint8_t immediate_nops[] = {0x80, 0x82, 0xC2, 0xE2, 0x89, 0};
const uint8_t a8_nops[] = {0x04, 0x44, 0x64, 0};
const uint8_t a8x_nops[] = {0x14, 0x34, 0x54, 0x74, 0xD4, 0xF4, 0};
const uint8_t a16x_nops[] = {0x1C, 0x3C, 0x5C, 0x7C, 0xDC, 0xFC, 0};

static Vcpu65_tb top;
static std::random_device dev;
std::mt19937 rng(dev());
std::uniform_int_distribution<std::mt19937::result_type> distByte(0,255);
std::uniform_int_distribution<std::mt19937::result_type> distWord(0,65535);

double sc_time_stamp() { return 0; }

uint16_t expect_PC;
uint8_t expect_SP;
uint8_t captured_flags;
uint8_t captured_A;
uint8_t captured_X;
uint8_t captured_Y;
uint8_t captured_SP;

void capture_flags(void) {
	captured_flags = top.flags;
}

void capture_regs() {
	captured_A = top.reg_A;
	captured_X = top.reg_X;
	captured_Y = top.reg_Y;
	captured_SP = top.reg_SP;
}

void capture_state() {
	capture_flags();
	capture_regs();
}

void assert_c(uint8_t a, std::source_location srcl = std::source_location::current()) {
	if(!a) {
		Verilated::timeInc(1);
		top.eval();
		Verilated::timeInc(1);
		top.eval();
		std::cout << "Assertion failed at " << srcl.function_name() << ": L" << std::dec << srcl.line() << std::endl;
		top.final();
		std::exit(1);
	}
}

#define FLAG_N 128
#define FLAG_V 64
#define FLAG_B 16
#define FLAG_D 8
#define FLAG_I 4
#define FLAG_Z 2
#define FLAG_C 1

void expect_flag_changes(uint8_t mask) {
	uint8_t anded_prev = captured_flags & mask;
	uint8_t anded_curr = top.flags & mask;
	assert_c((anded_prev ^ anded_curr) == mask);
	anded_prev = captured_flags & ~mask;
	anded_curr = top.flags & ~mask;
	assert_c(anded_prev == anded_curr);
}

#define REG_A 1
#define REG_X 2
#define REG_Y 4
#define REG_SP 8

void expect_register_changes(uint8_t mask) {
	if((mask & REG_A) == 0) assert_c(top.reg_A == captured_A);
	if((mask & REG_X) == 0) assert_c(top.reg_X == captured_X);
	if((mask & REG_Y) == 0) assert_c(top.reg_Y == captured_Y);
	if((mask & REG_SP) == 0) assert_c(top.reg_SP == captured_SP);
	//if((mask & REG_A) != 0) assert_c(top.reg_A != captured_A);
	//if((mask & REG_X) != 0) assert_c(top.reg_X != captured_X);
	//if((mask & REG_Y) != 0) assert_c(top.reg_Y != captured_Y);
	//if((mask & REG_SP) != 0) assert_c(top.reg_SP != captured_SP);
}

void expect_flags_set(uint8_t mask) {
	assert_c((top.flags & mask) == mask);
}

void expect_flags_clear(uint8_t mask) {
	assert_c((top.flags & mask) == 0);
}

#define BUS_STATE_READ 0
#define BUS_STATE_WRITE 1

void expect_bus_cycle(uint16_t addr, uint8_t value, uint8_t state, uint8_t sync) {
	if(top.clk_i == 1) {
		top.clk_i = 0;
		Verilated::timeInc(1);
		top.eval();
	}
	assert_c(!(state && sync));
	assert_c(top.SYNC == sync);
	assert_c(top.RWn == !state);
	assert_c(top.A == addr);
	if(!state) top.D_IN = value;
	else top.D_IN = !value;
	top.clk_i = 1;
	Verilated::timeInc(1);
	top.eval();
	assert_c(top.SYNC == sync);
	assert_c(top.RWn == !state);
	assert_c(top.A == addr);
	if(state) {
		assert_c(top.D_OUT == value);
	}
}

void expect_vector(uint16_t expected, uint16_t target_addr, uint8_t is_break) {
	capture_state();
	expect_bus_cycle(0x0100 | expect_SP, expect_PC >> 8, BUS_STATE_WRITE, 0);
	assert_c(top.VPn == 1);
	expect_SP--;
	expect_bus_cycle(0x0100 | expect_SP, expect_PC & 0xFF, BUS_STATE_WRITE, 0);
	assert_c(top.VPn == 1);
	expect_SP--;
	expect_bus_cycle(0x0100 | expect_SP, top.flags ^ (is_break ? 0 : 16), BUS_STATE_WRITE, 0);
	assert_c(top.VPn == 1);
	expect_SP--;
	expect_bus_cycle(expected, target_addr & 0xFF, BUS_STATE_READ, 0);
	assert_c(top.VPn == 0);
	expect_bus_cycle(expected|1, target_addr >> 8, BUS_STATE_READ, 0);
	assert_c(top.VPn == 0);
	expect_flags_set(FLAG_I);
	expect_PC = target_addr;
}

void cpu_reset(uint16_t reset_addr) {
	expect_SP = 0xFF;
	top.rst_n = 0;
	Verilated::timeInc(1);
	top.eval();
	top.clk_i = 1;
	Verilated::timeInc(1);
	top.eval();
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
	top.clk_i = 1;
	Verilated::timeInc(1);
	top.eval();
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
	top.clk_i = 1;
	Verilated::timeInc(1);
	top.eval();
	top.rst_n = 1;
	Verilated::timeInc(1);
	top.eval();
	Verilated::timeInc(5);
	top.eval();
	expect_vector(0xFFFC, reset_addr, 0);
	return;
}

void implied_instruction_exec(uint8_t next_opcode) {
	expect_bus_cycle(expect_PC, distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void immediate_instruction_exec(uint8_t next_opcode, uint8_t arg) {
	expect_bus_cycle(expect_PC++, arg, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void zp_instruction_exec(uint8_t next_opcode, uint8_t addr, uint8_t arg) {
	expect_bus_cycle(expect_PC++, addr, BUS_STATE_READ, 0);
	expect_bus_cycle(addr, arg, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void zp_store_instruction_exec(uint8_t next_opcode, uint8_t addr, uint8_t expected) {
	expect_bus_cycle(expect_PC++, addr, BUS_STATE_READ, 0);
	expect_bus_cycle(addr, expected, BUS_STATE_WRITE, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void zp_x_instruction_exec(uint8_t next_opcode, uint8_t addr, uint8_t arg) {
	expect_bus_cycle(expect_PC++, addr, BUS_STATE_READ, 0);
	expect_bus_cycle(addr, distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle((addr + top.reg_X) & 0xFF, arg, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void zp_x_store_instruction_exec(uint8_t next_opcode, uint8_t addr, uint8_t expected, uint8_t index_reg) {
	assert_c(index_reg == REG_X || index_reg == REG_Y);
	
	expect_bus_cycle(expect_PC++, addr, BUS_STATE_READ, 0);
	expect_bus_cycle(addr, distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle((addr + (index_reg == REG_X ? top.reg_X : top.reg_Y)) & 0xFF, expected, BUS_STATE_WRITE, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void zp_y_instruction_exec(uint8_t next_opcode, uint8_t addr, uint8_t arg) {
	expect_bus_cycle(expect_PC++, addr, BUS_STATE_READ, 0);
	expect_bus_cycle(addr, distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle((addr + top.reg_Y) & 0xFF, arg, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void abs_instruction_exec(uint8_t next_opcode, uint16_t addr, uint8_t arg) {
	expect_bus_cycle(expect_PC++, addr & 0xFF, BUS_STATE_READ, 0);
	assert_c(top.MLn == 1);
	expect_bus_cycle(expect_PC++, addr >> 8, BUS_STATE_READ, 0);
	assert_c(top.MLn == 1);
	expect_bus_cycle(addr, arg, BUS_STATE_READ, 0);
	assert_c(top.MLn == 1);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	assert_c(top.MLn == 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void abs_store_instruction_exec(uint8_t next_opcode, uint16_t addr, uint8_t expected) {
	expect_bus_cycle(expect_PC++, addr & 0xFF, BUS_STATE_READ, 0);
	assert_c(top.MLn == 1);
	expect_bus_cycle(expect_PC++, addr >> 8, BUS_STATE_READ, 0);
	assert_c(top.MLn == 1);
	expect_bus_cycle(addr, expected, BUS_STATE_WRITE, 0);
	assert_c(top.MLn == 1);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	assert_c(top.MLn == 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void abs_x_instruction_exec(uint8_t next_opcode, uint16_t addr, uint8_t arg, uint8_t index_reg) {
	assert_c(index_reg == REG_X || index_reg == REG_Y);
	uint16_t expected_addr = addr;
	if(index_reg == REG_X) expected_addr += top.reg_X;
	else expected_addr += top.reg_Y;
	expect_bus_cycle(expect_PC++, addr & 0xFF, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC++, addr >> 8, BUS_STATE_READ, 0);
	if((expected_addr & 0xFF00) != (addr & 0xFF00)) expect_bus_cycle((addr & 0xFF00) | (expected_addr & 0x00FF), distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(expected_addr, arg, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void abs_x_store_instruction_exec(uint8_t next_opcode, uint16_t addr, uint8_t expected, uint8_t index_reg) {
	assert_c(index_reg == REG_X || index_reg == REG_Y);
	uint16_t expected_addr = addr;
	if(index_reg == REG_X) expected_addr += top.reg_X;
	else expected_addr += top.reg_Y;
	expect_bus_cycle(expect_PC++, addr & 0xFF, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC++, addr >> 8, BUS_STATE_READ, 0);
	expect_bus_cycle((addr & 0xFF00) | (expected_addr & 0x00FF), distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(expected_addr, expected, BUS_STATE_WRITE, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void zp_indir_x_instruction_exec(uint8_t next_opcode, uint8_t addr, uint16_t pointer, uint8_t arg) {
	uint8_t expected_addr = addr + top.reg_X;
	expect_bus_cycle(expect_PC++, addr, BUS_STATE_READ, 0);
	expect_bus_cycle(addr, distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(expected_addr++, pointer & 0xFF, BUS_STATE_READ, 0);
	expect_bus_cycle(expected_addr, pointer >> 8, BUS_STATE_READ, 0);
	expect_bus_cycle(pointer, arg, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void zp_indir_x_store_instruction_exec(uint8_t next_opcode, uint8_t addr, uint16_t pointer, uint8_t expected) {
	uint8_t expected_addr = addr + top.reg_X;
	expect_bus_cycle(expect_PC++, addr, BUS_STATE_READ, 0);
	expect_bus_cycle(addr, distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(expected_addr++, pointer & 0xFF, BUS_STATE_READ, 0);
	expect_bus_cycle(expected_addr, pointer >> 8, BUS_STATE_READ, 0);
	expect_bus_cycle(pointer, expected, BUS_STATE_WRITE, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void zp_indir_y_instruction_exec(uint8_t next_opcode, uint8_t addr, uint16_t pointer, uint8_t arg) {
	uint16_t expected_addr = pointer + top.reg_Y;
	expect_bus_cycle(expect_PC++, addr, BUS_STATE_READ, 0);
	expect_bus_cycle(addr++, pointer & 0xFF, BUS_STATE_READ, 0);
	expect_bus_cycle(addr, pointer >> 8, BUS_STATE_READ, 0);
	if((expected_addr & 0xFF00) != (pointer & 0xFF00)) expect_bus_cycle((pointer & 0xFF00) | (expected_addr & 0x00FF), distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(expected_addr, arg, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void zp_indir_y_store_instruction_exec(uint8_t next_opcode, uint8_t addr, uint16_t pointer, uint8_t expected) {
	uint16_t expected_addr = pointer + top.reg_Y;
	expect_bus_cycle(expect_PC++, addr, BUS_STATE_READ, 0);
	expect_bus_cycle(addr++, pointer & 0xFF, BUS_STATE_READ, 0);
	expect_bus_cycle(addr, pointer >> 8, BUS_STATE_READ, 0);
	expect_bus_cycle((pointer & 0xFF00) | (expected_addr & 0x00FF), distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(expected_addr, expected, BUS_STATE_WRITE, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void zp_rmw_instruction_exec(uint8_t next_opcode, uint8_t addr, uint8_t arg, uint8_t expected) {
	expect_bus_cycle(expect_PC++, addr, BUS_STATE_READ, 0);
	expect_bus_cycle(addr, arg, BUS_STATE_READ, 0);
	expect_bus_cycle(addr, arg, BUS_STATE_WRITE, 0);
	expect_bus_cycle(addr, expected, BUS_STATE_WRITE, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void zp_x_rmw_instruction_exec(uint8_t next_opcode, uint8_t addr, uint8_t arg, uint8_t expected) {
	uint8_t expected_addr = addr + top.reg_X;
	expect_bus_cycle(expect_PC++, addr, BUS_STATE_READ, 0);
	expect_bus_cycle(addr, distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(expected_addr, arg, BUS_STATE_READ, 0);
	expect_bus_cycle(expected_addr, arg, BUS_STATE_WRITE, 0);
	expect_bus_cycle(expected_addr, expected, BUS_STATE_WRITE, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void abs_rmw_instruction_exec(uint8_t next_opcode, uint16_t addr, uint8_t arg, uint8_t expected) {
	expect_bus_cycle(expect_PC++, addr & 0xFF, BUS_STATE_READ, 0);
	assert_c(top.MLn == 1);
	expect_bus_cycle(expect_PC++, addr >> 8, BUS_STATE_READ, 0);
	assert_c(top.MLn == 0);
	expect_bus_cycle(addr, arg, BUS_STATE_READ, 0);
	assert_c(top.MLn == 0);
	expect_bus_cycle(addr, arg, BUS_STATE_WRITE, 0);
	assert_c(top.MLn == 0);
	expect_bus_cycle(addr, expected, BUS_STATE_WRITE, 0);
	assert_c(top.MLn == 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	assert_c(top.MLn == 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void abs_x_rmw_instruction_exec(uint8_t next_opcode, uint16_t addr, uint8_t arg, uint8_t expected, uint8_t index_reg) {
	assert_c(index_reg == REG_X || index_reg == REG_Y);
	uint16_t expected_addr = addr;
	if(index_reg == REG_X) expected_addr += top.reg_X;
	else expected_addr += top.reg_Y;
	expect_bus_cycle(expect_PC++, addr & 0xFF, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC++, addr >> 8, BUS_STATE_READ, 0);
	expect_bus_cycle((addr & 0xFF00) | (expected_addr & 0x00FF), distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(expected_addr, arg, BUS_STATE_READ, 0);
	expect_bus_cycle(expected_addr, arg, BUS_STATE_WRITE, 0);
	expect_bus_cycle(expected_addr, expected, BUS_STATE_WRITE, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void zp_indir_x_rmw_instruction_exec(uint8_t next_opcode, uint8_t addr, uint16_t pointer, uint8_t arg, uint8_t expected) {
	uint8_t expected_addr = addr + top.reg_X;
	expect_bus_cycle(expect_PC++, addr, BUS_STATE_READ, 0);
	expect_bus_cycle(addr, distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(expected_addr++, pointer & 0xFF, BUS_STATE_READ, 0);
	expect_bus_cycle(expected_addr, pointer >> 8, BUS_STATE_READ, 0);
	expect_bus_cycle(pointer, arg, BUS_STATE_READ, 0);
	expect_bus_cycle(pointer, arg, BUS_STATE_WRITE, 0);
	expect_bus_cycle(pointer, expected, BUS_STATE_WRITE, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void zp_indir_y_rmw_instruction_exec(uint8_t next_opcode, uint8_t addr, uint16_t pointer, uint8_t arg, uint8_t expected) {
	uint16_t expected_addr = pointer + top.reg_Y;
	expect_bus_cycle(expect_PC++, addr, BUS_STATE_READ, 0);
	expect_bus_cycle(addr++, pointer & 0xFF, BUS_STATE_READ, 0);
	expect_bus_cycle(addr, pointer >> 8, BUS_STATE_READ, 0);
	expect_bus_cycle((pointer & 0xFF00) | (expected_addr & 0x00FF), distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(expected_addr, arg, BUS_STATE_READ, 0);
	expect_bus_cycle(expected_addr, arg, BUS_STATE_WRITE, 0);
	expect_bus_cycle(expected_addr, expected, BUS_STATE_WRITE, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void jmp_instruction_exec(uint8_t next_opcode, uint16_t target) {
	expect_bus_cycle(expect_PC++, target & 0xFF, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC++, target >> 8, BUS_STATE_READ, 0);
	expect_PC = target;
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void jmp_indir_instruction_exec(uint8_t next_opcode, uint16_t pointer, uint16_t target) {
	expect_bus_cycle(expect_PC++, pointer & 0xFF, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC++, pointer >> 8, BUS_STATE_READ, 0);
	expect_bus_cycle(pointer, target & 0xFF, BUS_STATE_READ, 0);
	pointer = (pointer & 0xFF00) | ((pointer + 1) & 0x00FF);
	expect_bus_cycle(pointer, target >> 8, BUS_STATE_READ, 0);
	expect_PC = target;
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

#define NOT_TAKEN 0
#define TAKEN 1

void branch_instruction_exec(uint8_t next_opcode, uint8_t displacement, uint8_t expected) {
	expect_bus_cycle(expect_PC++, displacement, BUS_STATE_READ, 0);
	if(expected) {
		expect_bus_cycle(expect_PC, distByte(rng), BUS_STATE_READ, 0);
		//std::cout << std::hex << (int)expect_PC << std::endl;
		uint16_t sign_ext = displacement;
		if((displacement & 0x80) != 0) sign_ext |= 0xFF00;
		sign_ext += expect_PC;
		//std::cout << std::hex << (int)sign_ext << std::endl;
		if((expect_PC & 0xFF00) != (sign_ext & 0xFF00)) expect_bus_cycle((expect_PC & 0xFF00) | (sign_ext & 0x00FF), distByte(rng), BUS_STATE_READ, 0);
		expect_PC = sign_ext;
	}
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void jsr_instruction_exec(uint8_t next_opcode, uint16_t target) {
	expect_bus_cycle(expect_PC++, target & 0xFF, BUS_STATE_READ, 0);
	expect_bus_cycle(0x0100 | expect_SP, distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(0x0100 | expect_SP--, expect_PC >> 8, BUS_STATE_WRITE, 0);
	expect_bus_cycle(0x0100 | expect_SP--, expect_PC & 0xFF, BUS_STATE_WRITE, 0);
	expect_bus_cycle(expect_PC++, target >> 8, BUS_STATE_READ, 0);
	expect_PC = target;
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void rts_instruction_exec(uint8_t next_opcode, uint16_t target) {
	target--;
	expect_bus_cycle(expect_PC, distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(0x0100 | expect_SP++, distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(0x0100 | expect_SP++, target & 0xFF, BUS_STATE_READ, 0);
	expect_bus_cycle(0x0100 | expect_SP, target >> 8, BUS_STATE_READ, 0);
	expect_PC = target;
	expect_bus_cycle(expect_PC++, distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void rti_instruction_exec(uint8_t next_opcode, uint16_t target, uint8_t new_flags) {
	expect_bus_cycle(expect_PC, distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(0x0100 | expect_SP++, distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(0x0100 | expect_SP++, new_flags, BUS_STATE_READ, 0);
	expect_bus_cycle(0x0100 | expect_SP++, target & 0xFF, BUS_STATE_READ, 0);
	expect_PC = target;
	expect_bus_cycle(0x0100 | expect_SP, target >> 8, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void push_instruction_exec(uint8_t next_opcode, uint8_t expected_val) {
	expect_bus_cycle(expect_PC, distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(0x0100 | expect_SP--, expected_val, BUS_STATE_WRITE, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void pull_instruction_exec(uint8_t next_opcode, uint8_t arg) {
	expect_bus_cycle(expect_PC, distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(0x0100 | expect_SP++, distByte(rng), BUS_STATE_READ, 0);
	expect_bus_cycle(0x0100 | expect_SP, arg, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC++, next_opcode, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
}

void set_register_value(uint8_t reg, uint8_t value) {
	if(reg == REG_A) immediate_instruction_exec(I_LDA_IMM, distByte(rng));
	else if(reg == REG_X) immediate_instruction_exec(I_LDX_IMM, distByte(rng));
	else if(reg == REG_Y) immediate_instruction_exec(I_LDY_IMM, distByte(rng));
	else assert_c(false);
	capture_state();
	immediate_instruction_exec(I_NOP_IMM, value);
	expect_register_changes(reg);
	if(value == 0) {
		expect_flags_set(FLAG_Z);
		expect_flags_clear(FLAG_N);
	}else if(value >= 128) {
		expect_flags_set(FLAG_N);
		expect_flags_clear(FLAG_Z);
	}else expect_flags_clear(FLAG_N + FLAG_Z);
}

void verify_bit_instructions();
void verify_implied_instructions();
void verify_rotate_instructions();
void verify_immediate_instructions();
void verify_zp_instructions();
void verify_zp_x_instructions();
void verify_abs_instructions();
void verify_zp_indir_instructions();
void verify_official_rmw_instructions();
void verify_undoc_rmw_instructions();
void verify_jmp_instructions();
void verify_branch_instructions();
void verify_call_instructions();
void verify_pushpull_instructions();
void verify_bittest_instructions();
void verify_store_instructions();
void verify_xaa_instruction();

int main(int argc, char** argv, char** env) {
#ifdef TRACE_ON
	std::cout << "Warning: tracing is ON!" << std::endl;
	Verilated::traceEverOn(true);
#endif
	top.clk_i = 1;
	top.rst_n = 0;
	top.RDY = 1;
	top.AEC = 1;
	top.IRQn = 1;
	top.NMIn = 1;
	top.SOn = 1;
	cpu_reset(0x8000);
	std::cout << std::endl << "### CLASS: BIT SET/CLEAR ###" << std::endl;
	verify_bit_instructions();
	std::cout << std::endl << "### CLASS: IMMEDIATE ###" << std::endl;
	verify_immediate_instructions();
	std::cout << std::endl << "### CLASS: IMPLIED ###" << std::endl;
	verify_implied_instructions();
	std::cout << std::endl << "### CLASS: ROTATE ###" << std::endl;
	verify_rotate_instructions();
	std::cout << std::endl << "### CLASS: ZEROPAGE ###" << std::endl;
	verify_zp_instructions();
	std::cout << std::endl << "### CLASS: ZEROPAGE INDEXED ###" << std::endl;
	verify_zp_x_instructions();
	std::cout << std::endl << "### CLASS: ABSOLUTE / ABSOLUTE INDEXED ###" << std::endl;
	verify_abs_instructions();
	std::cout << std::endl << "### CLASS: ZEROPAGE INDIRECT ###" << std::endl;
	verify_zp_indir_instructions();
	std::cout << std::endl << "### CLASS: DOCUMENTED R/M/W ###" << std::endl;
	verify_official_rmw_instructions();
	std::cout << std::endl << "### CLASS: UNDOCUMENTED R/M/W ###" << std::endl;
	verify_undoc_rmw_instructions();
	std::cout << std::endl << "### CLASS: JUMPS ###" << std::endl;
	verify_jmp_instructions();
	std::cout << std::endl << "### CLASS: BRANCHES ###" << std::endl;
	verify_branch_instructions();
	std::cout << std::endl << "### CLASS: SUBROUTINE CALLS ###" << std::endl;
	verify_call_instructions();
	std::cout << std::endl << "### CLASS: PUSH / PULL ###" << std::endl;
	verify_pushpull_instructions();
	std::cout << std::endl << "### CLASS: BIT-TEST ###" << std::endl;
	verify_bittest_instructions();
	std::cout << std::endl << "### CLASS: STORE ###" << std::endl;
	verify_store_instructions();
	std::cout << std::endl << "### CLASS: XAA ###" << std::endl;
	verify_xaa_instruction();
	
	std::cout << std::endl << "VERIFYING RDY" << std::endl;
	set_register_value(REG_A, 0xFF);
	immediate_instruction_exec(I_LDA_IMM, distByte(rng));
	top.RDY = 0;
	expect_bus_cycle(expect_PC, 0x69, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC, 0x69, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC, 0x69, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC, 0x69, BUS_STATE_READ, 0);
	top.RDY = 1;
	expect_bus_cycle(expect_PC++, 0x69, BUS_STATE_READ, 0);
	top.RDY = 0;
	expect_bus_cycle(expect_PC, I_NOP_IMM, BUS_STATE_READ, 1);
	expect_bus_cycle(expect_PC, I_NOP_IMM, BUS_STATE_READ, 1);
	expect_bus_cycle(expect_PC, I_NOP_IMM, BUS_STATE_READ, 1);
	expect_bus_cycle(expect_PC, I_NOP_IMM, BUS_STATE_READ, 1);
	top.RDY = 1;
	expect_bus_cycle(expect_PC++, I_NOP_IMM, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
	immediate_instruction_exec(I_STA_A16, distByte(rng));
	uint16_t addr = distWord(rng);
	expect_bus_cycle(expect_PC++, addr & 0xFF, BUS_STATE_READ, 0);
	expect_bus_cycle(expect_PC++, addr >> 8, BUS_STATE_READ, 0);
	top.RDY = 0;
	expect_bus_cycle(addr, 0x69, BUS_STATE_WRITE, 0);
	expect_bus_cycle(expect_PC, I_NOP_IMM, BUS_STATE_READ, 1);
	expect_bus_cycle(expect_PC, I_NOP_IMM, BUS_STATE_READ, 1);
	expect_bus_cycle(expect_PC, I_NOP_IMM, BUS_STATE_READ, 1);
	top.RDY = 1;
	expect_bus_cycle(expect_PC++, I_NOP_IMM, BUS_STATE_READ, 1);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	std::cout << "DONE!" << std::endl;
	
	std::cout << std::endl << "VERIFYING IRQ" << std::endl;
	set_register_value(REG_A, 0x1E);
	immediate_instruction_exec(I_CLV, distByte(rng));
	implied_instruction_exec(I_CLI);
	implied_instruction_exec(I_SEC);
	implied_instruction_exec(I_NOP_A16);
	addr = distWord(rng);
	expect_bus_cycle(expect_PC++, addr & 0xFF, BUS_STATE_READ, 0);
	top.IRQn = 0;
	expect_bus_cycle(expect_PC++, addr >> 8, BUS_STATE_READ, 0);
	expect_bus_cycle(addr, distByte(rng), BUS_STATE_READ, 0);
	uint16_t instr_pc = expect_PC;
	expect_bus_cycle(instr_pc, distByte(rng), BUS_STATE_READ, 1);
	expect_bus_cycle(instr_pc, distByte(rng), BUS_STATE_READ, 0);
	expect_vector(0xFFFE, distWord(rng), 0);
	expect_bus_cycle(expect_PC++, I_NOP_IMM, BUS_STATE_READ, 1);
	immediate_instruction_exec(I_LDX_IMM, distByte(rng));
	immediate_instruction_exec(I_NOP_A16, distByte(rng));
	top.IRQn = 1;
	abs_instruction_exec(I_RTI, distWord(rng), distByte(rng));
	rti_instruction_exec(I_NOP_IMM, instr_pc, FLAG_V + FLAG_C);
	expect_flags_set(FLAG_V + FLAG_C);
	expect_flags_clear(FLAG_N + FLAG_Z + FLAG_I);
	immediate_instruction_exec(I_SEI, distByte(rng));
	implied_instruction_exec(I_CLV);
	top.IRQn = 0;
	implied_instruction_exec(I_NOP_IMM);
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	top.IRQn = 1;
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	std::cout << "DONE!" << std::endl;
	
	std::cout << std::endl << "VERIFYING NMI" << std::endl;
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	immediate_instruction_exec(I_SEC, distByte(rng));
	top.NMIn = 0;
	expect_bus_cycle(expect_PC, distByte(rng), BUS_STATE_READ, 0);
	top.clk_i = 0;
	Verilated::timeInc(1);
	top.eval();
	instr_pc = expect_PC;
	expect_bus_cycle(instr_pc, distByte(rng), BUS_STATE_READ, 1);
	expect_bus_cycle(instr_pc, distByte(rng), BUS_STATE_READ, 0);
	expect_vector(0xFFFA, distWord(rng), 0);
	expect_bus_cycle(expect_PC++, I_NOP_IMM, BUS_STATE_READ, 1);
	immediate_instruction_exec(I_LDX_IMM, distByte(rng));
	immediate_instruction_exec(I_LDY_IMM, distByte(rng));
	immediate_instruction_exec(I_LDA_IMM, distByte(rng));
	immediate_instruction_exec(I_LAX_IMM, distByte(rng));
	immediate_instruction_exec(I_RTI, distByte(rng));
	rti_instruction_exec(I_NOP_IMM, instr_pc, 0);
	expect_flags_clear(FLAG_N + FLAG_Z + FLAG_C + FLAG_V + FLAG_I);
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	top.NMIn = 1;
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	std::cout << "DONE!" << std::endl;
	
	Verilated::timeInc(1);
	top.eval();
	Verilated::timeInc(5);
	top.eval();
	std::cout << std::endl << "All tests passed!" << std::endl << std::endl;
	top.final();
	return 0;
}

void verify_bit_instructions() {
	expect_flags_set(FLAG_I + FLAG_Z);
	expect_flags_clear(FLAG_C + FLAG_V + FLAG_D);
	expect_bus_cycle(expect_PC++, I_NOP, BUS_STATE_READ, 1);
	std::cout << "SEC" << std::endl;
	capture_state();
	implied_instruction_exec(I_SEC);
	implied_instruction_exec(I_CLI);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	std::cout << "CLI" << std::endl;
	capture_state();
	implied_instruction_exec(I_CLC);
	expect_register_changes(0);
	expect_flag_changes(FLAG_I);
	expect_flags_clear(FLAG_I);
	std::cout << "CLC" << std::endl;
	capture_state();
	implied_instruction_exec(I_SEI);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_C);
	std::cout << "SEI & SOB" << std::endl;
	capture_state();
	top.SOn = 0;
	implied_instruction_exec(I_SED);
	expect_register_changes(0);
	expect_flag_changes(FLAG_I + FLAG_V);
	expect_flags_set(FLAG_I + FLAG_V);
	top.SOn = 1;
	std::cout << "SED" << std::endl;
	capture_state();
	implied_instruction_exec(I_CLD);
	expect_register_changes(0);
	expect_flag_changes(FLAG_D);
	expect_flags_set(FLAG_D);
	std::cout << "CLD" << std::endl;
	capture_state();
	implied_instruction_exec(I_CLV);
	expect_register_changes(0);
	expect_flag_changes(FLAG_D);
	expect_flags_clear(FLAG_D);
	std::cout << "CLV" << std::endl;
	capture_state();
	implied_instruction_exec(I_NOP);
	expect_register_changes(0);
	expect_flag_changes(FLAG_V);
	expect_flags_clear(FLAG_V);
}

void verify_implied_instructions() {
	uint8_t value = (distByte(rng) & 0x7F) | 4;
	std::cout << "TXA" << std::endl;
	set_register_value(REG_X, value);
	set_register_value(REG_Y, 0x00);
	capture_state();
	immediate_instruction_exec(I_TXA, distByte(rng));
	implied_instruction_exec(I_NOP_IMM);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_Z);
	expect_flags_clear(FLAG_Z + FLAG_N);
	assert_c(top.reg_A == value);
	std::cout << "TXS" << std::endl;
	set_register_value(REG_A, 0x00);
	capture_state();
	immediate_instruction_exec(I_TXS, distByte(rng));
	implied_instruction_exec(I_NOP_IMM);
	expect_register_changes(REG_SP);
	expect_flag_changes(0);
	expect_flags_set(FLAG_Z); //Transfering to SP does not affect flags
	assert_c(top.reg_SP == value);
	expect_SP = value;
	std::cout << "TSX" << std::endl;
	set_register_value(REG_X, 0x80);
	capture_state();
	immediate_instruction_exec(I_TSX, distByte(rng));
	implied_instruction_exec(I_TAX);
	expect_register_changes(REG_X);
	expect_flag_changes(FLAG_N); //Transfering from SP *does* affect flags
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_X == value);
	std::cout << "TAX" << std::endl;
	capture_state();
	implied_instruction_exec(I_NOP_IMM);
	expect_register_changes(REG_X);
	expect_flag_changes(FLAG_Z);
	expect_flags_clear(FLAG_N);
	expect_flags_set(FLAG_Z);
	assert_c(top.reg_X == 0);
	std::cout << "TAY" << std::endl;
	value = distByte(rng) | 0x81;
	set_register_value(REG_A, value);
	set_register_value(REG_Y, 0x00);
	capture_state();
	immediate_instruction_exec(I_TAY, distByte(rng));
	implied_instruction_exec(I_NOP_IMM);
	expect_register_changes(REG_Y);
	expect_flag_changes(FLAG_Z + FLAG_N);
	expect_flags_clear(FLAG_Z);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_Y == value);
	std::cout << "TYA" << std::endl;
	set_register_value(REG_A, distByte(rng));
	capture_state();
	immediate_instruction_exec(I_TYA, distByte(rng));
	implied_instruction_exec(I_NOP_IMM);
	expect_register_changes(REG_A);
	assert_c(top.reg_A == value);
	std::cout << "DEY" << std::endl;
	set_register_value(REG_Y, 0x81);
	capture_state();
	immediate_instruction_exec(I_DEY, distByte(rng));
	implied_instruction_exec(I_DEY);
	expect_register_changes(REG_Y);
	expect_flag_changes(0);
	assert_c(top.reg_Y == 0x80);
	capture_state();
	implied_instruction_exec(I_TYA);
	expect_register_changes(REG_Y);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_Y == 0x7F);
	std::cout << "DEX" << std::endl;
	implied_instruction_exec(I_TAX);
	implied_instruction_exec(I_DEX);
	capture_state();
	assert_c(top.reg_X == 0x7F);
	implied_instruction_exec(I_INX);
	expect_register_changes(REG_X);
	expect_flag_changes(0);
	assert_c(top.reg_X == 0x7E);
	std::cout << "INX" << std::endl;
	capture_state();
	implied_instruction_exec(I_INX);
	expect_flag_changes(0);
	expect_register_changes(REG_X);
	assert_c(top.reg_X == 0x7F);
	capture_state();
	expect_flags_clear(FLAG_N);
	implied_instruction_exec(I_NOP_IMM);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	std::cout << "INY" << std::endl;
	set_register_value(REG_Y, 0xFF);
	capture_state();
	immediate_instruction_exec(I_INY, distByte(rng));
	implied_instruction_exec(I_INY);
	expect_register_changes(REG_Y);
	expect_flag_changes(FLAG_N + FLAG_Z);
	expect_flags_clear(FLAG_N);
	expect_flags_set(FLAG_Z);
	assert_c(top.reg_Y == 0x00);
	capture_state();
	implied_instruction_exec(I_NOP_IMM);
	expect_flag_changes(FLAG_Z);
	expect_flags_clear(FLAG_Z);
	expect_register_changes(REG_Y);
	assert_c(top.reg_Y == 0x01);
	immediate_instruction_exec(I_NOP, distByte(rng));
	for(int i = 0;;i++) {
		if(implied_nops[i] == 0) break;
		std::cout << "NOP (" << std::setw(2) << std::setfill('0') << std::hex << std::right << (int)implied_nops[i] << ")" << std::endl;
		capture_state();
		implied_instruction_exec(implied_nops[i]);
		expect_register_changes(0);
		expect_flag_changes(0);
	}
	capture_state();
	implied_instruction_exec(I_NOP);
	expect_register_changes(0);
	expect_flag_changes(0);
}

void verify_immediate_instructions() {
	//Setup
	capture_state();
	std::cout << "LDA #" << std::endl;
	uint8_t value = (distByte(rng) & 0x7F) | 1;
	implied_instruction_exec(I_LDA_IMM);
	immediate_instruction_exec(I_LDY_IMM, value);
	expect_flag_changes(FLAG_Z);
	expect_flags_clear(FLAG_Z + FLAG_N);
	expect_register_changes(REG_A);
	assert_c(top.reg_A == value);
	capture_state();
	std::cout << "LDY #" << std::endl;
	value = (distByte(rng) & 0x7F) | 1;
	immediate_instruction_exec(I_LDX_IMM, value);
	expect_flag_changes(0);
	expect_register_changes(REG_Y);
	assert_c(top.reg_Y == value);
	capture_state();
	std::cout << "LDX #" << std::endl;
	value = distByte(rng) | 0x80;
	immediate_instruction_exec(I_LAX_IMM, value);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	expect_register_changes(REG_X);
	assert_c(top.reg_X == value);
	capture_state();
	std::cout << "LAX #" << std::endl;
	immediate_instruction_exec(I_NOP_IMM, 0x00);
	expect_flag_changes(FLAG_N + FLAG_Z);
	expect_flags_clear(FLAG_N);
	expect_flags_set(FLAG_Z);
	expect_register_changes(REG_A + REG_X);
	assert_c(top.reg_A == 0 && top.reg_X == 0);
	capture_state();
	for(int i = 0;;i++) {
		if(immediate_nops[i] == 0) break;
		std::cout << "NOP # (" << std::setw(2) << std::setfill('0') << std::hex << std::right << (int)immediate_nops[i] << ")" << std::endl;
		capture_state();
		immediate_instruction_exec(immediate_nops[i], distByte(rng));
		expect_flag_changes(0);
		expect_register_changes(0);
	}
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	expect_flag_changes(0);
	expect_register_changes(0);
	std::cout << "ORA #" << std::endl;
	value = (distByte(rng) & 0x7F) | 1;
	set_register_value(REG_A, value);
	capture_state();
	immediate_instruction_exec(I_ORA_IMM, distByte(rng));
	uint8_t value2 = distByte(rng) | 0x81;
	immediate_instruction_exec(I_NOP_IMM, value2);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == value | value2);
	std::cout << "AND #" << std::endl;
	set_register_value(REG_A, value);
	capture_state();
	immediate_instruction_exec(I_AND_IMM, distByte(rng));
	immediate_instruction_exec(I_NOP_IMM, value2);
	expect_register_changes(REG_A);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == (value & value2));
	std::cout << "EOR #" << std::endl;
	set_register_value(REG_A, value);
	capture_state();
	immediate_instruction_exec(I_EOR_IMM, distByte(rng));
	immediate_instruction_exec(I_NOP_IMM, value2);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == value ^ value2);
	set_register_value(REG_A, value2);
	capture_state();
	immediate_instruction_exec(I_EOR_IMM, distByte(rng));
	immediate_instruction_exec(I_NOP_IMM, value2);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_Z + FLAG_N);
	expect_flags_set(FLAG_Z);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == 0);
	std::cout << "ADC #" << std::endl;
	immediate_instruction_exec(I_CLC, distByte(rng));
	implied_instruction_exec(I_NOP_IMM);
	set_register_value(REG_A, 0x67);
	capture_state();
	immediate_instruction_exec(I_ADC_IMM, distByte(rng));
	immediate_instruction_exec(I_ADC_IMM, 0x22);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N + FLAG_V);
	expect_flags_set(FLAG_N + FLAG_V);
	assert_c(top.reg_A == 0x89);
	capture_state();
	immediate_instruction_exec(I_ADC_IMM, 0x81);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N + FLAG_C);
	expect_flags_clear(FLAG_N);
	expect_flags_set(FLAG_C + FLAG_V);
	assert_c(top.reg_A == 0x0A);
	capture_state();
	immediate_instruction_exec(I_ADC_IMM, 0x02);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_V + FLAG_C);
	expect_flags_clear(FLAG_V + FLAG_C);
	assert_c(top.reg_A == 0x0D);
	capture_state();
	immediate_instruction_exec(I_SBC_IMM, 0x02);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	assert_c(top.reg_A == 0x0F);
	std::cout << "SBC #" << std::endl;
	capture_state();
	immediate_instruction_exec(I_SBC_IMM, 0x0C);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	assert_c(top.reg_A == 0x02);
	capture_state();
	immediate_instruction_exec(I_SBC_IMM, 0x02);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_Z);
	expect_flags_set(FLAG_Z);
	expect_flags_clear(FLAG_V);
	assert_c(top.reg_A == 0x00);
	capture_state();
	immediate_instruction_exec(I_SBC2_IMM, 0x11);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N + FLAG_Z + FLAG_C);
	expect_flags_clear(FLAG_C + FLAG_Z);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == 0xEF);
	capture_state();
	immediate_instruction_exec(I_SBC2_IMM, 0x70);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N + FLAG_C + FLAG_V);
	expect_flags_set(FLAG_C + FLAG_V);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == 0x7E);
	capture_state();
	value = distByte(rng);
	immediate_instruction_exec(I_NOP_IMM, value);
	value = 0x7E - value;
	expect_register_changes(REG_A);
	assert_c(top.reg_A == value);
	std::cout << "CMP #" << std::endl;
	set_register_value(REG_X, distByte(rng));
	immediate_instruction_exec(I_CLC, distByte(rng));
	implied_instruction_exec(I_NOP_IMM);
	set_register_value(REG_Y, distByte(rng));
	value = 0x30;
	if(distByte(rng) & 1) value += (distByte(rng)) & 0xF;
	else value -= (distByte(rng)) & 0xF;
	set_register_value(REG_A, value);
	immediate_instruction_exec(I_CMP_IMM, distByte(rng));
	capture_state();
	immediate_instruction_exec(I_CMP_IMM, value);
	expect_register_changes(0);
	expect_flag_changes(FLAG_Z + FLAG_C);
	expect_flags_set(FLAG_Z + FLAG_C);
	capture_state();
	immediate_instruction_exec(I_CMP_IMM, value + 0x40 + (distByte(rng) % 17));
	expect_register_changes(0);
	expect_flag_changes(FLAG_Z + FLAG_C + FLAG_N);
	expect_flags_set(FLAG_N);
	expect_flags_clear(FLAG_Z + FLAG_C);
	capture_state();
	immediate_instruction_exec(I_NOP_IMM, 0);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C + FLAG_N);
	expect_flags_set(FLAG_C);
	expect_flags_clear(FLAG_Z + FLAG_N);
	std::cout << "SBX #" << std::endl;
	set_register_value(REG_X, 0xC3);
	immediate_instruction_exec(I_SEC, distByte(rng));
	implied_instruction_exec(I_NOP_IMM);
	set_register_value(REG_A, 0x1E);
	immediate_instruction_exec(I_SBX_IMM, distByte(rng));
	capture_state();
	immediate_instruction_exec(I_NOP_IMM, 5);
	expect_register_changes(REG_X);
	expect_flag_changes(FLAG_N + FLAG_C);
	expect_flags_set(FLAG_N);
	expect_flags_clear(FLAG_C);
	assert_c(top.reg_X == 0xFD);
	std::cout << "ANC #" << std::endl;
	set_register_value(REG_A, 0xC7);
	immediate_instruction_exec(I_ANC_IMM, distByte(rng));
	capture_state();
	immediate_instruction_exec(I_NOP_IMM, 0x69);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == 0x41);
	set_register_value(REG_A, 0xC7);
	set_register_value(REG_X, (distByte(rng) & 0x7F) | 1);
	immediate_instruction_exec(I_ANC2_IMM, distByte(rng));
	capture_state();
	immediate_instruction_exec(I_NOP_IMM, 0xF0);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N + FLAG_C);
	expect_flags_set(FLAG_N + FLAG_C);
	assert_c(top.reg_A == 0xC0);
	std::cout << "CPY #" << std::endl;
	set_register_value(REG_Y, 0x42);
	immediate_instruction_exec(I_CPY_IMM, distByte(rng));
	capture_state();
	immediate_instruction_exec(I_CPY_IMM, 0x42);
	expect_register_changes(0);
	expect_flag_changes(FLAG_Z);
	expect_flags_clear(FLAG_N);
	expect_flags_set(FLAG_Z + FLAG_C);
	capture_state();
	immediate_instruction_exec(I_NOP_IMM, 0x68);
	expect_register_changes(0);
	expect_flag_changes(FLAG_Z + FLAG_N + FLAG_C);
	expect_flags_clear(FLAG_C + FLAG_Z);
	expect_flags_set(FLAG_N);
	std::cout << "CPX #" << std::endl;
	value = 0x20 + (distByte(rng) & 0x1F);
	set_register_value(REG_X, value);
	immediate_instruction_exec(I_CPX_IMM, distByte(rng));
	capture_state();
	immediate_instruction_exec(I_CPX_IMM, value - 10);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_N + FLAG_Z);
	expect_flags_set(FLAG_C);
	capture_state();
	immediate_instruction_exec(I_NOP_IMM, value);
	expect_register_changes(0);
	expect_flag_changes(FLAG_Z);
	expect_flags_set(FLAG_C + FLAG_Z);
}

void verify_rotate_instructions() {
	implied_instruction_exec(I_NOP_IMM);
	std::cout << "ASL" << std::endl;
	set_register_value(REG_A, 0x61);
	immediate_instruction_exec(I_CLC, distByte(rng));
	implied_instruction_exec(I_ASL);
	capture_state();
	implied_instruction_exec(I_ASL);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == 0xC2);
	capture_state();
	implied_instruction_exec(I_ASL);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_N + FLAG_C);
	assert_c(top.reg_A == 0x84);
	capture_state();
	implied_instruction_exec(I_NOP_IMM);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == 0x08);
	std::cout << "ROL" << std::endl;
	set_register_value(REG_A, 0x80);
	immediate_instruction_exec(I_CLC, distByte(rng));
	implied_instruction_exec(I_ROL);
	capture_state();
	implied_instruction_exec(I_ROL);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_Z + FLAG_C + FLAG_N);
	expect_flags_set(FLAG_Z + FLAG_C);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == 0x00);
	capture_state();
	implied_instruction_exec(I_ROL);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_Z + FLAG_C);
	expect_flags_clear(FLAG_Z + FLAG_C);
	assert_c(top.reg_A == 0x01);
	capture_state();
	implied_instruction_exec(I_SEC);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	assert_c(top.reg_A == 0x02);
	std::cout << "ROR" << std::endl;
	implied_instruction_exec(I_ROR);
	capture_state();
	implied_instruction_exec(I_ROR);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N + FLAG_C);
	expect_flags_clear(FLAG_C);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == 0x81);
	capture_state();
	implied_instruction_exec(I_NOP_IMM);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C + FLAG_N);
	expect_flags_clear(FLAG_N);
	expect_flags_set(FLAG_C);
	assert_c(top.reg_A == 0x40);
	std::cout << "LSR" << std::endl;
	set_register_value(REG_A, 0xD2);
	immediate_instruction_exec(I_LSR, distByte(rng));
	capture_state();
	implied_instruction_exec(I_LSR);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C + FLAG_N);
	expect_flags_clear(FLAG_C + FLAG_N);
	assert_c(top.reg_A == 0x69);
	capture_state();
	implied_instruction_exec(I_NOP_IMM);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	assert_c(top.reg_A == 0x34);
	std::cout << "ASR" << std::endl;
	set_register_value(REG_A, 0x3E);
	immediate_instruction_exec(I_ASR_IMM, distByte(rng));
	capture_state();
	immediate_instruction_exec(I_NOP_IMM, 0xE2);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_C);
	assert_c(top.reg_A == 0x11);
	std::cout << "ARR" << std::endl;
	set_register_value(REG_A, 0xF0);
	immediate_instruction_exec(I_CLV, distByte(rng));
	implied_instruction_exec(I_ARR_IMM);
	capture_state();
	immediate_instruction_exec(I_ARR_IMM, 0x8E);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C + FLAG_N + FLAG_V);
	expect_flags_clear(FLAG_N);
	expect_flags_set(FLAG_C + FLAG_V);
	assert_c(top.reg_A == 0x40);
	capture_state();
	immediate_instruction_exec(I_NOP_IMM, 0x00);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C + FLAG_V + FLAG_N);
	expect_flags_clear(FLAG_C + FLAG_V);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == 0x80);
}

void verify_zp_instructions() {
	std::cout << "ORA a8" << std::endl;
	set_register_value(REG_A, 0x30);
	immediate_instruction_exec(I_ORA_A8, distByte(rng));
	capture_state();
	uint8_t addr = distByte(rng);
	zp_instruction_exec(I_AND_A8, addr, 0xF1);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == 0xF1);
	std::cout << "AND a8" << std::endl;
	capture_state();
	addr = distByte(rng);
	zp_instruction_exec(I_EOR_A8, addr, 0x30);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == 0x30);
	std::cout << "EOR a8" << std::endl;
	addr = distByte(rng);
	capture_state();
	zp_instruction_exec(I_CLC, addr, 0xF1);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == 0xC1);
	std::cout << "ADC a8" << std::endl;
	implied_instruction_exec(I_ADC_A8);
	capture_state();
	addr = distByte(rng);
	zp_instruction_exec(I_LDA_A8, addr, 0x11);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	assert_c(top.reg_A == 0xD2);
	std::cout << "LDA a8" << std::endl;
	capture_state();
	addr = distByte(rng);
	zp_instruction_exec(I_LDY_A8, addr, 0x3C);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == 0x3C);
	std::cout << "LDY a8" << std::endl;
	capture_state();
	addr = distByte(rng);
	uint8_t value = (distByte(rng) & 0x7F) | 3;
	zp_instruction_exec(I_LDX_A8, addr, value);
	expect_register_changes(REG_Y);
	expect_flag_changes(0);
	assert_c(top.reg_Y == value);
	std::cout << "LDX a8" << std::endl;
	capture_state();
	addr = distByte(rng);
	value = (distByte(rng) & 0x7F) | 3;
	zp_instruction_exec(I_LAX_A8, addr, value);
	expect_register_changes(REG_X);
	expect_flag_changes(0);
	assert_c(top.reg_X == value);
	std::cout << "LAX a8" << std::endl;
	capture_state();
	addr = distByte(rng);
	value = distByte(rng) | 0x88;
	zp_instruction_exec(a8_nops[0], addr, value);
	expect_register_changes(REG_X + REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_X == value);
	assert_c(top.reg_A == value);
	for(int i = 0;;i++) {
		if(a8_nops[i] == 0) break;
		std::cout << "NOP a8 (" << std::setw(2) << std::setfill('0') << std::hex << std::right << (int)a8_nops[i] << ")" << std::endl;
		capture_state();
		zp_instruction_exec(a8_nops[i], distByte(rng), distByte(rng));
		expect_flag_changes(0);
		expect_register_changes(0);
	}
	zp_instruction_exec(I_NOP_IMM, distByte(rng), distByte(rng));
	expect_flag_changes(0);
	expect_register_changes(0);
	std::cout << "CPY a8" << std::endl;
	set_register_value(REG_X, 0x00);
	immediate_instruction_exec(I_CLC, distByte(rng));
	implied_instruction_exec(I_NOP_IMM);
	set_register_value(REG_A, 0x20);
	set_register_value(REG_Y, 0x3F);
	immediate_instruction_exec(I_CPY_A8, distByte(rng));
	capture_state();
	zp_instruction_exec(I_NOP_IMM, distByte(rng), 0x20);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	expect_flags_clear(FLAG_N);
	std::cout << "CPX a8" << std::endl;
	set_register_value(REG_X, 0x88);
	immediate_instruction_exec(I_CPX_A8, distByte(rng));
	capture_state();
	zp_instruction_exec(I_NOP_IMM, distByte(rng), 0x88);
	expect_register_changes(0);
	expect_flag_changes(FLAG_Z + FLAG_N);
	expect_flags_set(FLAG_C + FLAG_Z);
	expect_flags_clear(FLAG_N);
	std::cout << "SBC a8" << std::endl;
	set_register_value(REG_A, 0x88);
	immediate_instruction_exec(I_SBC_A8, distByte(rng));
	capture_state();
	zp_instruction_exec(I_CMP_A8, distByte(rng), 0x10);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N + FLAG_V);
	expect_flags_set(FLAG_V + FLAG_C);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == 0x78);
	std::cout << "CMP a8" << std::endl;
	capture_state();
	zp_instruction_exec(I_CMP_A8, 0x00, 0x55);
	expect_register_changes(0);
	expect_flag_changes(0);
	expect_flags_set(FLAG_C);
	capture_state();
	zp_instruction_exec(I_NOP_IMM, 0x01, 0x9D);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C + FLAG_N);
	expect_flags_set(FLAG_N);
	expect_flags_clear(FLAG_C);
}

void verify_zp_x_instructions() {
	std::cout << "ORA a8,X" << std::endl;
	set_register_value(REG_A, 0x23);
	set_register_value(REG_X, 0x02);
	immediate_instruction_exec(I_ORA_A8X, distByte(rng));
	capture_state();
	zp_x_instruction_exec(I_AND_A8X, distByte(rng), 0xC1);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == 0xE3);
	std::cout << "AND a8,X" << std::endl;
	capture_state();
	zp_x_instruction_exec(I_EOR_A8X, distByte(rng), 0xF0);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	assert_c(top.reg_A == 0xE0);
	std::cout << "EOR a8,X" << std::endl;
	capture_state();
	zp_x_instruction_exec(I_SEC, distByte(rng), 0x83);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == 0x63);
	std::cout << "ADC a8,X" << std::endl;
	implied_instruction_exec(I_NOP_IMM);
	set_register_value(REG_X, 0xC7);
	immediate_instruction_exec(I_ADC_A8X, distByte(rng));
	capture_state();
	zp_x_instruction_exec(I_SBC_A8X, distByte(rng), 0xF3);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N + FLAG_V);
	expect_flags_set(FLAG_C);
	expect_flags_clear(FLAG_N + FLAG_V);
	assert_c(top.reg_A == 0x57);
	std::cout << "SBC a8,X" << std::endl;
	capture_state();
	zp_x_instruction_exec(I_CMP_A8X, distByte(rng), 0x02);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	assert_c(top.reg_A = 0x55);
	std::cout << "CMP a8,X" << std::endl;
	capture_state();
	zp_x_instruction_exec(I_CMP_A8X, distByte(rng), 0x4D);
	expect_register_changes(0);
	expect_flag_changes(0);
	expect_flags_set(FLAG_C);
	capture_state();
	zp_x_instruction_exec(I_NOP_IMM, 0x00, 0x55);
	expect_register_changes(0);
	expect_flag_changes(FLAG_Z);
	expect_flags_set(FLAG_Z);
	for(int i = 0;;i++) {
		if(a8x_nops[i] == 0) break;
		set_register_value(REG_X, distByte(rng));
		std::cout << "NOP a8,X (" << std::setw(2) << std::setfill('0') << std::hex << std::right << (int)a8x_nops[i] << ")" << std::endl;
		immediate_instruction_exec(a8x_nops[i], distByte(rng));
		capture_state();
		zp_x_instruction_exec(I_NOP_IMM, distByte(rng), distByte(rng));
		expect_flag_changes(0);
		expect_register_changes(0);
	}
	std::cout << "LDA a8,X" << std::endl;
	set_register_value(REG_X, (distByte(rng) & 0x7F) | 3);
	uint8_t value = distByte(rng) | 0x80;
	immediate_instruction_exec(I_LDA_A8X, distByte(rng));
	capture_state();
	zp_x_instruction_exec(I_NOP_IMM, distByte(rng), value);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == value);
	std::cout << "LDY a8,X" << std::endl;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_Y, 0xFF);
	immediate_instruction_exec(I_LDY_A8X, distByte(rng));
	capture_state();
	zp_x_instruction_exec(I_NOP_IMM, distByte(rng), 0);
	expect_register_changes(REG_Y);
	expect_flag_changes(FLAG_Z + FLAG_N);
	expect_flags_set(FLAG_Z);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_Y == 0);
	std::cout << "LDX a8,Y" << std::endl;
	value = (distByte(rng) & 0x7F) | 8;
	set_register_value(REG_Y, 23);
	immediate_instruction_exec(I_LDX_A8Y, distByte(rng));
	capture_state();
	zp_y_instruction_exec(I_NOP_IMM, 0, value);
	expect_register_changes(REG_X);
	expect_flag_changes(0);
	expect_flags_clear(FLAG_N + FLAG_Z);
	assert_c(top.reg_X == value);
	std::cout << "LAX a8,Y" << std::endl;
	set_register_value(REG_Y, distByte(rng));
	set_register_value(REG_A, 0x00);
	immediate_instruction_exec(I_LAX_A8Y, distByte(rng));
	capture_state();
	value = (distByte(rng) & 0x7F) | 0x80;
	zp_y_instruction_exec(I_NOP_IMM, distByte(rng), value);
	expect_register_changes(REG_A + REG_X);
	expect_flag_changes(FLAG_N + FLAG_Z);
	expect_flags_clear(FLAG_Z);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == value);
	assert_c(top.reg_X == value);
}

void verify_abs_instructions() {
	std::cout << "ORA a16" << std::endl;
	uint8_t value = (distByte(rng) & 0x7F) | 1;
	uint8_t value2 = distByte(rng) | 0x80;
	set_register_value(REG_A, value);
	immediate_instruction_exec(I_ORA_A16, distByte(rng));
	capture_state();
	abs_instruction_exec(I_NOP_IMM, distWord(rng), value2);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	assert_c(top.reg_A == (value | value2));
	std::cout << "AND a16" << std::endl;
	value = (distByte(rng) & 0x7F) | 1;
	value2 = distByte(rng) | 0x81;
	set_register_value(REG_A, value2);
	immediate_instruction_exec(I_AND_A16, distByte(rng));
	capture_state();
	abs_instruction_exec(I_NOP_IMM, distWord(rng), value);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == (value & value2));
	std::cout << "EOR a16" << std::endl;
	value = (distByte(rng) & 0x7F) | 1;
	value2 = (distByte(rng) & 0x7E) ^ 0x80;
	set_register_value(REG_A, value2);
	immediate_instruction_exec(I_EOR_A16, distByte(rng));
	capture_state();
	abs_instruction_exec(I_NOP_IMM, distWord(rng), value);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == (value ^ value2));
	std::cout << "ADC a16" << std::endl;
	set_register_value(REG_A, 0xAD);
	immediate_instruction_exec(I_CLC, distByte(rng));
	implied_instruction_exec(I_ADC_A16);
	capture_state();
	abs_instruction_exec(I_CMP_A16, distWord(rng), 0x30);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	assert_c(top.reg_A == 0xDD);
	std::cout << "CMP a16" << std::endl;
	capture_state();
	abs_instruction_exec(I_CLC, distWord(rng), 0x52);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C + FLAG_N);
	std::cout << "SBC a16" << std::endl;
	implied_instruction_exec(I_SBC_A16);
	capture_state();
	abs_instruction_exec(I_NOP_IMM, distWord(rng), 0x22);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	assert_c(top.reg_A == 0xBA);
	std::cout << "CPX a16" << std::endl;
	set_register_value(REG_X, 0xAB);
	set_register_value(REG_Y, 0x9F);
	set_register_value(REG_A, 0xFF);
	immediate_instruction_exec(I_CPX_A16, distByte(rng));
	capture_state();
	abs_instruction_exec(I_CPX_A16, distWord(rng), 0xAC);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_N);
	expect_flags_clear(FLAG_C);
	capture_state();
	abs_instruction_exec(I_CPY_A16, distWord(rng), 0xAB);
	expect_register_changes(0);
	expect_flag_changes(FLAG_N + FLAG_Z + FLAG_C);
	expect_flags_clear(FLAG_N);
	expect_flags_set(FLAG_Z + FLAG_C);
	std::cout << "CPY a16" << std::endl;
	capture_state();
	abs_instruction_exec(I_CLC, distWord(rng), 0x9E);
	expect_register_changes(0);
	expect_flag_changes(FLAG_Z);
	expect_flags_clear(FLAG_Z + FLAG_N);
	expect_flags_set(FLAG_C);
	implied_instruction_exec(I_CPY_A16);
	capture_state();
	abs_instruction_exec(I_LDA_A16, distWord(rng), 0x9F);
	expect_register_changes(0);
	expect_flag_changes(FLAG_Z + FLAG_C);
	expect_flags_clear(FLAG_N);
	expect_flags_set(FLAG_Z + FLAG_C);
	std::cout << "LDA a16" << std::endl;
	capture_state();
	abs_instruction_exec(I_LDY_A16, distWord(rng), 0x2D);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_Z);
	expect_flags_clear(FLAG_Z);
	assert_c(top.reg_A == 0x2D);
	std::cout << "LDY a16" << std::endl;
	capture_state();
	abs_instruction_exec(I_LDX_A16, distWord(rng), 0xDC);
	expect_register_changes(REG_Y);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_Y == 0xDC);
	std::cout << "LDX a16" << std::endl;
	capture_state();
	value = (distByte(rng) & 0x7F) | 1;
	abs_instruction_exec(I_LAX_A16, distWord(rng), value);
	expect_register_changes(REG_X);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_X == value);
	std::cout << "LAX a16" << std::endl;
	capture_state();
	value = (distByte(rng) & 0x7F) | 1;
	abs_instruction_exec(I_NOP_A16, distWord(rng), value);
	expect_register_changes(REG_A + REG_X);
	expect_flag_changes(0);
	assert_c(top.reg_X == value);
	assert_c(top.reg_A == value);
	std::cout << "NOP a16 (0c)" << std::endl;
	capture_state();
	abs_instruction_exec(I_NOP_IMM, distWord(rng), distByte(rng));
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "ORA a16,X" << std::endl;
	value = (distByte(rng) & 0x7F) | 1;
	value2 = (distByte(rng) & 0xFE) | 0x80;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_A, value);
	immediate_instruction_exec(I_ORA_A16X, distByte(rng));
	capture_state();
	abs_x_instruction_exec(I_NOP_IMM, distWord(rng), value2, REG_X);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == (value | value2));
	std::cout << "AND a16,X" << std::endl;
	value = (distByte(rng) & 0x7F) | 1;
	value2 = (distByte(rng) & 0xFE) | 0x81;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_A, value2);
	immediate_instruction_exec(I_AND_A16X, distByte(rng));
	capture_state();
	abs_x_instruction_exec(I_NOP_IMM, distWord(rng), value, REG_X);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == (value & value2));
	std::cout << "EOR a16,X" << std::endl;
	value = (distByte(rng) & 0x7F) | 1;
	value2 = (distByte(rng) & 0xFE) | 0x81;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_A, value2);
	immediate_instruction_exec(I_EOR_A16X, distByte(rng));
	capture_state();
	abs_x_instruction_exec(I_NOP_IMM, distWord(rng), value, REG_X);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	assert_c(top.reg_A == (value ^ value2));
	std::cout << "ADC a16,X" << std::endl;
	set_register_value(REG_A, 0x6E);
	immediate_instruction_exec(I_CLV, distByte(rng));
	implied_instruction_exec(I_CLC);
	implied_instruction_exec(I_ADC_A16X);
	capture_state();
	abs_x_instruction_exec(I_CMP_A16X, distWord(rng), 0x49, REG_X);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_V + FLAG_N);
	expect_flags_set(FLAG_V + FLAG_N);
	expect_flags_clear(FLAG_C);
	assert_c(top.reg_A == 0xB7);
	std::cout << "CMP a16,X" << std::endl;
	capture_state();
	abs_x_instruction_exec(I_CMP_A16X, distWord(rng), 0x49, REG_X);
	expect_register_changes(0);
	expect_flag_changes(FLAG_N + FLAG_C);
	expect_flags_set(FLAG_C);
	expect_flags_clear(FLAG_N);
	capture_state();
	abs_x_instruction_exec(I_LDA_A16X, distWord(rng), 0xB7, REG_X);
	expect_register_changes(0);
	expect_flag_changes(FLAG_Z);
	expect_flags_set(FLAG_Z);
	std::cout << "LDA a16,X" << std::endl;
	capture_state();
	abs_x_instruction_exec(I_LDY_A16X, distWord(rng), 0x1F, REG_X);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_Z);
	expect_flags_clear(FLAG_Z);
	assert_c(top.reg_A == 0x1F);
	std::cout << "LDY a16,X" << std::endl;
	capture_state();
	abs_x_instruction_exec(a16x_nops[0], distWord(rng), 0x9E, REG_X);
	expect_register_changes(REG_Y);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_Y == 0x9E);
	for(int i = 0;;i++) {
		if(a16x_nops[i] == 0) break;
		std::cout << "NOP a16,X (" << std::setw(2) << std::setfill('0') << std::hex << std::right << (int)a16x_nops[i] << ")" << std::endl;
		capture_state();
		abs_x_instruction_exec(a16x_nops[i], distWord(rng), distByte(rng), REG_X);
		expect_flag_changes(0);
		expect_register_changes(0);
	}
	abs_x_instruction_exec(I_NOP_IMM, distWord(rng), distByte(rng), REG_X);
	expect_flag_changes(0);
	expect_register_changes(0);
	std::cout << "ORA a16,Y" << std::endl;
	value = (distByte(rng) & 0x7F) | 1;
	value2 = (distByte(rng) & 0xFE) | 0x80;
	set_register_value(REG_Y, distByte(rng));
	set_register_value(REG_A, value);
	immediate_instruction_exec(I_ORA_A16Y, distByte(rng));
	capture_state();
	abs_x_instruction_exec(I_NOP_IMM, distWord(rng), value2, REG_Y);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == (value | value2));
	std::cout << "AND a16,Y" << std::endl;
	value = (distByte(rng) & 0x7F) | 1;
	value2 = (distByte(rng) & 0xFE) | 0x81;
	set_register_value(REG_Y, distByte(rng));
	set_register_value(REG_A, value2);
	immediate_instruction_exec(I_AND_A16Y, distByte(rng));
	capture_state();
	abs_x_instruction_exec(I_NOP_IMM, distWord(rng), value, REG_Y);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == (value & value2));
	std::cout << "EOR a16,Y" << std::endl;
	value = (distByte(rng) & 0x7F) | 1;
	value2 = (distByte(rng) & 0xFE) | 0x81;
	set_register_value(REG_Y, distByte(rng));
	set_register_value(REG_A, value2);
	immediate_instruction_exec(I_EOR_A16Y, distByte(rng));
	capture_state();
	abs_x_instruction_exec(I_NOP_IMM, distWord(rng), value, REG_Y);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	assert_c(top.reg_A == (value ^ value2));
	std::cout << "ADC a16,X" << std::endl;
	set_register_value(REG_A, 0x42);
	immediate_instruction_exec(I_CLV, distByte(rng));
	implied_instruction_exec(I_SEC);
	implied_instruction_exec(I_ADC_A16Y);
	capture_state();
	abs_x_instruction_exec(I_CMP_A16Y, distWord(rng), 0x05, REG_Y);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_V + FLAG_C);
	assert_c(top.reg_A == 0x48);
	std::cout << "CMP a16,Y" << std::endl;
	capture_state();
	abs_x_instruction_exec(I_CMP_A16Y, distWord(rng), 0x05, REG_Y);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	expect_flags_clear(FLAG_N);
	capture_state();
	abs_x_instruction_exec(I_LDA_A16Y, distWord(rng), 0x48, REG_Y);
	expect_register_changes(0);
	expect_flag_changes(FLAG_Z);
	expect_flags_clear(FLAG_N);
	expect_flags_set(FLAG_Z + FLAG_C);
	std::cout << "LDA a16,Y" << std::endl;
	capture_state();
	abs_x_instruction_exec(I_LDX_A16Y, distWord(rng), 0x05, REG_Y);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_Z);
	expect_flags_clear(FLAG_Z);
	assert_c(top.reg_A == 0x05);
	std::cout << "LDX a16,Y" << std::endl;
	capture_state();
	value = (distByte(rng) & 0x7F) | 1;
	abs_x_instruction_exec(I_LAX_A16Y, distWord(rng), value, REG_Y);
	expect_register_changes(REG_X);
	expect_flag_changes(0);
	assert_c(top.reg_X == value);
	std::cout << "LAX a16,Y" << std::endl;
	capture_state();
	value = distByte(rng) | 0x81;
	abs_x_instruction_exec(I_LAS_A16Y, distWord(rng), value, REG_Y);
	expect_register_changes(REG_X + REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_X == value);
	assert_c(top.reg_A == value);
	std::cout << "LAS a16,Y" << std::endl;
	capture_state();
	abs_x_instruction_exec(I_NOP_IMM, distWord(rng), 0x0F, REG_Y);
	expect_register_changes(REG_X + REG_A + REG_SP);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N);
	expect_SP &= 0x0F;
	assert_c(top.reg_X == expect_SP);
	assert_c(top.reg_A == expect_SP);
	assert_c(top.reg_SP == expect_SP);
}

void verify_zp_indir_instructions() {
	std::cout << "ORA (a8,X)" << std::endl;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_A, 0x28);
	immediate_instruction_exec(I_ORA_A8_INDIR_X, distByte(rng));
	capture_state();
	zp_indir_x_instruction_exec(I_AND_A8_INDIR_X, distByte(rng), distWord(rng), 0x21);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	expect_flags_clear(FLAG_N + FLAG_Z);
	assert_c(top.reg_A == 0x29);
	std::cout << "AND (a8,X)" << std::endl;
	capture_state();
	zp_indir_x_instruction_exec(I_NOP_IMM, distByte(rng), distWord(rng), 0x0C);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	expect_flags_clear(FLAG_N + FLAG_Z);
	assert_c(top.reg_A == 0x08);
	std::cout << "EOR (a8,X)" << std::endl;
	uint8_t value = (distByte(rng) & 0x7F) | 1;
	uint8_t value2 = (distByte(rng) & 0xFE) | 0x81;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_A, value);
	immediate_instruction_exec(I_EOR_A8_INDIR_X, distByte(rng));
	capture_state();
	zp_indir_x_instruction_exec(I_NOP_IMM, distByte(rng), distWord(rng), value2);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == (value ^ value2));
	std::cout << "ADC (a8,X)" << std::endl;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_A, 0xD0);
	immediate_instruction_exec(I_CLV, distByte(rng));
	implied_instruction_exec(I_CLC);
	implied_instruction_exec(I_ADC_A8_INDIR_X);
	capture_state();
	zp_indir_x_instruction_exec(I_NOP_IMM, distByte(rng), distWord(rng), 0x40);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N + FLAG_C);
	expect_flags_clear(FLAG_N);
	expect_flags_set(FLAG_C);
	assert_c(top.reg_A == 0x10);
	std::cout << "CMP (a8,X)" << std::endl;
	immediate_instruction_exec(I_CMP_A8_INDIR_X, distByte(rng));
	capture_state();
	zp_indir_x_instruction_exec(I_CMP_A8_INDIR_X, distByte(rng), distWord(rng), 0x40);
	expect_register_changes(0);
	expect_flag_changes(FLAG_N + FLAG_C);
	expect_flags_set(FLAG_N);
	expect_flags_clear(FLAG_C);
	capture_state();
	zp_indir_x_instruction_exec(I_SBC_A8_INDIR_X, distByte(rng), distWord(rng), 0x10);
	expect_register_changes(0);
	expect_flag_changes(FLAG_Z + FLAG_N + FLAG_C);
	expect_flags_set(FLAG_Z + FLAG_C);
	expect_flags_clear(FLAG_N);
	std::cout << "SBC (a8,X)" << std::endl;
	capture_state();
	zp_indir_x_instruction_exec(I_LDA_A8_INDIR_X, distByte(rng), distWord(rng), 0x40);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N + FLAG_C + FLAG_Z);
	expect_flags_set(FLAG_N);
	expect_flags_clear(FLAG_C + FLAG_Z);
	assert_c(top.reg_A == 0xD0);
	std::cout << "LDA (a8,X)" << std::endl;
	value = (distByte(rng) & 0x7F) | 1;
	capture_state();
	zp_indir_x_instruction_exec(I_LAX_A8_INDIR_X, distByte(rng), distWord(rng), value);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == value);
	std::cout << "LAX (a8,X)" << std::endl;
	value = distByte(rng) | 0x80;
	capture_state();
	zp_indir_x_instruction_exec(I_NOP_IMM, distByte(rng), distWord(rng), value);
	expect_register_changes(REG_A + REG_X);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == value);
	assert_c(top.reg_X == value);
	std::cout << "ORA (a8),Y" << std::endl;
	value = (distByte(rng) & 0x7F) | 1;
	value2 = (distByte(rng) & 0xFE) | 0x80;
	set_register_value(REG_Y, distByte(rng));
	set_register_value(REG_A, value);
	immediate_instruction_exec(I_ORA_A8_INDIR_Y, distByte(rng));
	capture_state();
	zp_indir_y_instruction_exec(I_NOP_IMM, distByte(rng), distWord(rng), value2);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == (value | value2));
	std::cout << "AND (a8),Y" << std::endl;
	value = (distByte(rng) & 0x7F) | 1;
	value2 = (distByte(rng) & 0xFE) | 0x81;
	set_register_value(REG_Y, distByte(rng));
	set_register_value(REG_A, value2);
	immediate_instruction_exec(I_AND_A8_INDIR_Y, distByte(rng));
	capture_state();
	zp_indir_y_instruction_exec(I_NOP_IMM, distByte(rng), distWord(rng), value);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == (value & value2));
	std::cout << "EOR (a8),Y" << std::endl;
	value = (distByte(rng) & 0x7F) | 1;
	value2 = (distByte(rng) & 0xFE) | 0x80;
	set_register_value(REG_Y, distByte(rng));
	set_register_value(REG_A, value);
	immediate_instruction_exec(I_EOR_A8_INDIR_Y, distByte(rng));
	capture_state();
	zp_indir_y_instruction_exec(I_NOP_IMM, distByte(rng), distWord(rng), value2);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == (value ^ value2));
	std::cout << "ADC (a8),Y" << std::endl;
	set_register_value(REG_Y, distByte(rng));
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_A, 0x9A);
	immediate_instruction_exec(I_CLC, distByte(rng));
	implied_instruction_exec(I_ADC_A8_INDIR_Y);
	capture_state();
	zp_indir_y_instruction_exec(I_SBC_A8_INDIR_Y, distByte(rng), distWord(rng), 0x2D);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	expect_flags_clear(FLAG_V);
	assert_c(top.reg_A == 0xC7);
	std::cout << "SBC (a8),Y" << std::endl;
	capture_state();
	zp_indir_y_instruction_exec(I_CMP_A8_INDIR_Y, distByte(rng), distWord(rng), 0x2D);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	assert_c(top.reg_A == 0x99);
	std::cout << "CMP (a8),Y" << std::endl;
	capture_state();
	zp_indir_y_instruction_exec(I_CMP_A8_INDIR_Y, distByte(rng), distWord(rng), 0xFF);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_C);
	capture_state();
	zp_indir_y_instruction_exec(I_LDA_A8_INDIR_Y, distByte(rng), distWord(rng), 0x99);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C + FLAG_Z + FLAG_N);
	expect_flags_set(FLAG_C + FLAG_Z);
	expect_flags_clear(FLAG_N);
	std::cout << "LDA (a8),Y" << std::endl;
	capture_state();
	value = distByte(rng) | 0x80;
	zp_indir_y_instruction_exec(I_LAX_A8_INDIR_Y, distByte(rng), distWord(rng), value);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N + FLAG_Z);
	expect_flags_set(FLAG_N);
	expect_flags_clear(FLAG_Z);
	assert_c(top.reg_A == value);
	std::cout << "LAX (a8),Y" << std::endl;
	capture_state();
	value = (distByte(rng) & 0x7F) | 2;
	zp_indir_y_instruction_exec(I_NOP_IMM, distByte(rng), distWord(rng), value);
	expect_register_changes(REG_A + REG_X);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == value);
	assert_c(top.reg_X == value);
}

void verify_official_rmw_instructions() {
	std::cout << "INC a8" << std::endl;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_Y, 0x01);
	immediate_instruction_exec(I_INC_A8, distByte(rng));
	capture_state();
	zp_rmw_instruction_exec(I_INC_A8X, distByte(rng), 0xEF, 0xF0);
	expect_register_changes(0);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	std::cout << "INC a8,X" << std::endl;
	capture_state();
	zp_x_rmw_instruction_exec(I_DEC_A8, distByte(rng), 0xFF, 0x00);
	expect_register_changes(0);
	expect_flag_changes(FLAG_N + FLAG_Z);
	expect_flags_clear(FLAG_N);
	expect_flags_set(FLAG_Z);
	std::cout << "DEC a8" << std::endl;
	capture_state();
	zp_rmw_instruction_exec(I_DEC_A8X, distByte(rng), 0x00, 0xFF);
	expect_register_changes(0);
	expect_flag_changes(FLAG_Z + FLAG_N);
	expect_flags_clear(FLAG_Z);
	expect_flags_set(FLAG_N);
	std::cout << "DEC a8,X" << std::endl;
	capture_state();
	zp_x_rmw_instruction_exec(I_DEC_A8X, distByte(rng), 0x3D, 0x3C);
	expect_register_changes(0);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N + FLAG_Z);
	uint8_t value = (distByte(rng) & 0x7F) | 0x40;
	capture_state();
	zp_x_rmw_instruction_exec(I_DEC_A16, distByte(rng), value, value - 1);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "DEC a16" << std::endl;
	capture_state();
	abs_rmw_instruction_exec(I_INC_A16, distWord(rng), 0x5C, 0x5B);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "INC a16" << std::endl;
	capture_state();
	abs_rmw_instruction_exec(I_DEC_A16X, distWord(rng), 0xE9, 0xEA);
	expect_register_changes(0);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	std::cout << "DEC a16,X" << std::endl;
	capture_state();
	abs_x_rmw_instruction_exec(I_INC_A16X, distWord(rng), 0x02, 0x01, REG_X);
	expect_register_changes(0);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N);
	std::cout << "INC a16,X" << std::endl;
	capture_state();
	abs_x_rmw_instruction_exec(I_NOP_IMM, distWord(rng), 0x02, 0x03, REG_X);
	expect_register_changes(0);
	expect_flag_changes(0);
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_Y, 0x22);
	std::cout << "ASL a8" << std::endl;
	immediate_instruction_exec(I_SEC, distByte(rng));
	implied_instruction_exec(I_ASL_A8);
	capture_state();
	zp_rmw_instruction_exec(I_SEC, distByte(rng), 0x4C, 0x98);
	expect_register_changes(0);
	expect_flag_changes(FLAG_N + FLAG_C);
	expect_flags_set(FLAG_N);
	expect_flags_clear(FLAG_C);
	std::cout << "ROL a8" << std::endl;
	implied_instruction_exec(I_ROL_A8);
	capture_state();
	zp_rmw_instruction_exec(I_SEC, distByte(rng), 0x01, 0x03);
	expect_register_changes(0);
	expect_flag_changes(FLAG_N + FLAG_C);
	expect_flags_clear(FLAG_N + FLAG_C);
	std::cout << "LSR a8" << std::endl;
	implied_instruction_exec(I_LSR_A8);
	capture_state();
	zp_rmw_instruction_exec(I_LSR_A8, distByte(rng), 0x02, 0x01);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_C);
	capture_state();
	zp_rmw_instruction_exec(I_ROR_A8, distByte(rng), 0xFF, 0x7F);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	std::cout << "ROR a8" << std::endl;
	capture_state();
	zp_rmw_instruction_exec(I_ROR_A8, distByte(rng), 0x44, 0xA2);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C + FLAG_N);
	expect_flags_set(FLAG_N);
	expect_flags_clear(FLAG_C);
	capture_state();
	zp_rmw_instruction_exec(I_NOP_IMM, distByte(rng), 0xA2, 0x51);
	expect_register_changes(0);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N);
	std::cout << "ASL a8,X" << std::endl;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_A, 0x00);
	immediate_instruction_exec(I_ASL_A8X, distByte(rng));
	capture_state();
	zp_x_rmw_instruction_exec(I_LSR_A8X, distByte(rng), 0xA2, 0x44);
	expect_register_changes(0);
	expect_flag_changes(FLAG_Z + FLAG_C);
	expect_flags_clear(FLAG_Z);
	expect_flags_set(FLAG_C);
	std::cout << "LSR a8,X" << std::endl;
	capture_state();
	zp_x_rmw_instruction_exec(I_ROL_A8X, distByte(rng), 0x92, 0x49);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_C);
	std::cout << "ROL a8,X" << std::endl;
	capture_state();
	zp_x_rmw_instruction_exec(I_ROL_A8X, distByte(rng), 0x80, 0x00);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C + FLAG_Z);
	expect_flags_set(FLAG_C + FLAG_Z);
	capture_state();
	zp_x_rmw_instruction_exec(I_ROR_A8X, distByte(rng), 0x00, 0x01);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C + FLAG_Z);
	expect_flags_clear(FLAG_C + FLAG_Z);
	std::cout << "ROR a8,X" << std::endl;
	capture_state();
	zp_x_rmw_instruction_exec(I_ROR_A8X, distByte(rng), 0xD9, 0x6C);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	zp_x_rmw_instruction_exec(I_NOP_IMM, distByte(rng), 0x01, 0x80);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C + FLAG_N);
	expect_flags_set(FLAG_N);
	std::cout << "ASL a16" << std::endl;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_A, 0x01);
	immediate_instruction_exec(I_SEC, distByte(rng));
	implied_instruction_exec(I_ASL_A16);
	capture_state();
	abs_rmw_instruction_exec(I_ROL_A16, distWord(rng), 0x09, 0x12);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_C);
	std::cout << "ROL a16" << std::endl;
	capture_state();
	abs_rmw_instruction_exec(I_ROL_A16, distWord(rng), 0x8C, 0x18);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	capture_state();
	abs_rmw_instruction_exec(I_LSR_A16, distWord(rng), 0x49, 0x93);
	expect_register_changes(0);
	expect_flag_changes(FLAG_N + FLAG_C);
	expect_flags_clear(FLAG_C);
	expect_flags_set(FLAG_N);
	std::cout << "LSR a16" << std::endl;
	capture_state();
	abs_rmw_instruction_exec(I_ROR_A16, distWord(rng), 0xCF, 0x67);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C + FLAG_N);
	expect_flags_set(FLAG_C);
	expect_flags_clear(FLAG_N);
	std::cout << "ROR a16" << std::endl;
	capture_state();
	abs_rmw_instruction_exec(I_NOP_IMM, distWord(rng), 0x67, 0xB3);
	expect_register_changes(0);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	std::cout << "ASL a16,X" << std::endl;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_A, 0x01);
	immediate_instruction_exec(I_ASL_A16X, distByte(rng));
	capture_state();
	abs_x_rmw_instruction_exec(I_ASL_A16X, distWord(rng), 0x22, 0x44, REG_X);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_C);
	capture_state();
	abs_x_rmw_instruction_exec(I_ROL_A16X, distWord(rng), 0x44, 0x88, REG_X);
	expect_register_changes(0);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
	std::cout << "ROL a16,X" << std::endl;
	capture_state();
	abs_x_rmw_instruction_exec(I_ROL_A16X, distWord(rng), 0xDD, 0xBA, REG_X);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	capture_state();
	abs_x_rmw_instruction_exec(I_LSR_A16X, distWord(rng), 0x10, 0x21, REG_X);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C + FLAG_N);
	expect_flags_clear(FLAG_C + FLAG_N);
	std::cout << "LSR a16,X" << std::endl;
	capture_state();
	abs_x_rmw_instruction_exec(I_ROR_A16X, distWord(rng), 0x23, 0x11, REG_X);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	std::cout << "ROR a16,X" << std::endl;
	capture_state();
	abs_x_rmw_instruction_exec(I_NOP_IMM, distWord(rng), 0x11, 0x88, REG_X);
	expect_register_changes(0);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N);
}

void verify_undoc_rmw_instructions() {
	std::cout << "SLO a8" << std::endl;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_A, 0x35);
	immediate_instruction_exec(I_SEC, distByte(rng));
	implied_instruction_exec(I_SLO_A8);
	capture_state();
	zp_rmw_instruction_exec(I_NOP_IMM, distByte(rng), 0x39, 0x72);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_C);
	assert_c(top.reg_A == 0x77);
	std::cout << "SLO a8,X" << std::endl;
	set_register_value(REG_A, 0x92);
	immediate_instruction_exec(I_SLO_A8X, distByte(rng));
	capture_state();
	zp_x_rmw_instruction_exec(I_SEC, distByte(rng), 0x39, 0x72);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	assert_c(top.reg_A == 0xF2);
	std::cout << "RLA a8" << std::endl;
	implied_instruction_exec(I_RLA_A8);
	capture_state();
	zp_rmw_instruction_exec(I_RLA_A8X, distByte(rng), 0x14, 0x29);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C + FLAG_N);
	expect_flags_clear(FLAG_C + FLAG_N);
	assert_c(top.reg_A == 0x20);
	std::cout << "RLA a8,X" << std::endl;
	capture_state();
	zp_x_rmw_instruction_exec(I_NOP_IMM, distByte(rng), 0x85, 0x0A);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C + FLAG_Z);
	expect_flags_set(FLAG_C + FLAG_Z);
	assert_c(top.reg_A == 0x00);
	std::cout << "SRE a8" << std::endl;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_A, 0x55);
	immediate_instruction_exec(I_SRE_A8, distByte(rng));
	capture_state();
	zp_rmw_instruction_exec(I_RRA_A8, distByte(rng), 0x09, 0x04);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	assert_c(top.reg_A == 0x51);
	std::cout << "RRA a8" << std::endl;
	capture_state();
	zp_rmw_instruction_exec(I_SRE_A8X, distByte(rng), 0x86, 0xC3);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	assert_c(top.reg_A == 0x14);
	std::cout << "SRE a8,X" << std::endl;
	capture_state();
	zp_x_rmw_instruction_exec(I_RRA_A8X, distByte(rng), 0xFE, 0x7F);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_C);
	assert_c(top.reg_A == 0x6B);
	std::cout << "RRA a8,X" << std::endl;
	capture_state();
	zp_x_rmw_instruction_exec(I_NOP_IMM, distByte(rng), 0x01, 0x00);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	assert_c(top.reg_A == 0x6C);
	std::cout << "SLO a16,Y" << std::endl;
	set_register_value(REG_Y, distByte(rng));
	set_register_value(REG_A, 0x22);
	immediate_instruction_exec(I_SLO_A16Y, distByte(rng));
	capture_state();
	abs_x_rmw_instruction_exec(I_SEC, distWord(rng), 0x0A, 0x14, REG_Y);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	assert_c(top.reg_A == 0x36);
	std::cout << "RLA a16,Y" << std::endl;
	implied_instruction_exec(I_RLA_A16Y);
	capture_state();
	abs_x_rmw_instruction_exec(I_SRE_A16Y, distWord(rng), 0x0A, 0x15, REG_Y);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_C);
	assert_c(top.reg_A == 0x14);
	std::cout << "SRE a16,Y" << std::endl;
	capture_state();
	abs_x_rmw_instruction_exec(I_RRA_A16Y, distWord(rng), 0x27, 0x13, REG_Y);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	assert_c(top.reg_A == 0x07);
	std::cout << "RRA a16,Y" << std::endl;
	capture_state();
	abs_x_rmw_instruction_exec(I_NOP_IMM, distWord(rng), 0xC0, 0xE0, REG_Y);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C + FLAG_N);
	expect_flags_set(FLAG_N);
	expect_flags_clear(FLAG_C);
	assert_c(top.reg_A == 0xE7);
	std::cout << "SLO (a8,X)" << std::endl;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_A, 0x92);
	immediate_instruction_exec(I_SEC, distByte(rng));
	implied_instruction_exec(I_SLO_A8_INDIR_X);
	capture_state();
	zp_indir_x_rmw_instruction_exec(I_RLA_A8_INDIR_X, distByte(rng), distWord(rng), 0x02, 0x04);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_N);
	expect_flags_clear(FLAG_C);
	assert_c(top.reg_A == 0x96);
	std::cout << "RLA (a8,X)" << std::endl;
	capture_state();
	zp_indir_x_rmw_instruction_exec(I_SRE_A8_INDIR_X, distByte(rng), distWord(rng), 0x78, 0xF0);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	assert_c(top.reg_A == 0x90);
	std::cout << "SRE (a8,X)" << std::endl;
	capture_state();
	zp_indir_x_rmw_instruction_exec(I_RRA_A8_INDIR_X, distByte(rng), distWord(rng), 0x63, 0x31);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	assert_c(top.reg_A == 0xA1);
	std::cout << "RRA (a8,X)" << std::endl;
	capture_state();
	zp_indir_x_rmw_instruction_exec(I_NOP_IMM, distByte(rng), distWord(rng), 0x61, 0xB0);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N + FLAG_V);
	expect_flags_clear(FLAG_N);
	expect_flags_set(FLAG_V + FLAG_C);
	assert_c(top.reg_A == 0x52);
	std::cout << "SLO (a8),Y" << std::endl;
	set_register_value(REG_Y, distByte(rng));
	set_register_value(REG_A, 0xDA);
	immediate_instruction_exec(I_SLO_A8_INDIR_Y, distByte(rng));
	capture_state();
	zp_indir_y_rmw_instruction_exec(I_SRE_A8_INDIR_Y, distByte(rng), distWord(rng), 0x02, 0x04);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_C);
	assert_c(top.reg_A == 0xDE);
	std::cout << "SRE (a8),Y" << std::endl;
	capture_state();
	zp_indir_y_rmw_instruction_exec(I_RLA_A8_INDIR_Y, distByte(rng), distWord(rng), 0x07, 0x03);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	assert_c(top.reg_A == 0xDD);
	std::cout << "RLA (a8),Y" << std::endl;
	capture_state();
	zp_indir_y_rmw_instruction_exec(I_RRA_A8_INDIR_Y, distByte(rng), distWord(rng), 0x70, 0xE1);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_C);
	assert_c(top.reg_A == 0xC1);
	std::cout << "RRA (a8),Y" << std::endl;
	capture_state();
	zp_indir_y_rmw_instruction_exec(I_NOP_IMM, distByte(rng), distWord(rng), 0x03, 0x01);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_V);
	expect_flags_clear(FLAG_V);
	assert_c(top.reg_A == 0xC3);
	std::cout << "SLO a16" << std::endl;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_A, 0x3A);
	immediate_instruction_exec(I_SLO_A16, distByte(rng));
	capture_state();
	abs_rmw_instruction_exec(I_SLO_A16X, distWord(rng), 0xC1, 0x82);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C + FLAG_N);
	expect_flags_set(FLAG_C + FLAG_N);
	assert_c(top.reg_A == 0xBA);
	std::cout << "SLO a16,X" << std::endl;
	capture_state();
	abs_x_rmw_instruction_exec(I_RLA_A16, distWord(rng), 0x16, 0x2C, REG_X);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_C);
	assert_c(top.reg_A == 0xBE);
	std::cout << "RLA a16" << std::endl;
	capture_state();
	abs_rmw_instruction_exec(I_RLA_A16X, distWord(rng), 0x96, 0x2C);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C + FLAG_N);
	expect_flags_set(FLAG_C);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == 0x2C);
	std::cout << "RLA a16,X" << std::endl;
	capture_state();
	abs_x_rmw_instruction_exec(I_SRE_A16, distWord(rng), 0x87, 0x0F, REG_X);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == 0x0C);
	std::cout << "SRE a16" << std::endl;
	capture_state();
	abs_rmw_instruction_exec(I_SRE_A16X, distWord(rng), 0xD0, 0x68);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_C);
	assert_c(top.reg_A == 0x64);
	std::cout << "SRE a16,X" << std::endl;
	capture_state();
	abs_x_rmw_instruction_exec(I_RRA_A16, distWord(rng), 0x0D, 0x06, REG_X);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	assert_c(top.reg_A == 0x62);
	std::cout << "RRA a16" << std::endl;
	capture_state();
	abs_rmw_instruction_exec(I_RRA_A16X, distWord(rng), 0x06, 0x83);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C + FLAG_N);
	expect_flags_set(FLAG_N);
	expect_flags_clear(FLAG_C);
	assert_c(top.reg_A == 0xE5);
	std::cout << "RRA a16,X" << std::endl;
	capture_state();
	abs_x_rmw_instruction_exec(I_NOP_IMM, distWord(rng), 0x52, 0x29, REG_X);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C + FLAG_N);
	expect_flags_clear(FLAG_N);
	expect_flags_set(FLAG_C);
	assert_c(top.reg_A == 0x0E);
	std::cout << "DCP a8" << std::endl;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_A, 0x57);
	immediate_instruction_exec(I_DCP_A8, distByte(rng));
	capture_state();
	zp_rmw_instruction_exec(I_DCP_A8, distByte(rng), 0x32, 0x31);
	expect_register_changes(0);
	expect_flag_changes(0);
	capture_state();
	zp_rmw_instruction_exec(I_ISC_A8, distByte(rng), 0x58, 0x57);
	expect_register_changes(0);
	expect_flag_changes(FLAG_Z);
	expect_flags_set(FLAG_Z + FLAG_C);
	std::cout << "ISC a8" << std::endl;
	capture_state();
	zp_rmw_instruction_exec(I_CLC, distByte(rng), 0x03, 0x04);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_Z);
	expect_flags_clear(FLAG_Z);
	assert_c(top.reg_A == 0x53);
	implied_instruction_exec(I_ISC_A8);
	capture_state();
	zp_rmw_instruction_exec(I_DCP_A8X, distByte(rng), 0xFF, 0x00);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	assert_c(top.reg_A == 0x53);
	std::cout << "DCP a8,X" << std::endl;
	capture_state();
	zp_x_rmw_instruction_exec(I_ISC_A8X, distByte(rng), 0xFE, 0xFD);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_C + FLAG_N);
	std::cout << "ISC a8,X" << std::endl;
	capture_state();
	zp_x_rmw_instruction_exec(I_NOP_IMM, distByte(rng), 0x21, 0x22);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C);
	expect_flags_set(FLAG_C);
	expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == 0x31);
	std::cout << "DCP a16" << std::endl;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_Y, distByte(rng));
	set_register_value(REG_A, 0x31);
	immediate_instruction_exec(I_DCP_A16, distByte(rng));
	capture_state();
	abs_rmw_instruction_exec(I_ISC_A16, distWord(rng), 0x32, 0x31);
	expect_register_changes(0);
	expect_flag_changes(FLAG_Z);
	expect_flags_set(FLAG_Z);
	std::cout << "ISC a16" << std::endl;
	capture_state();
	abs_rmw_instruction_exec(I_DCP_A16X, distWord(rng), 0x57, 0x58);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_Z + FLAG_N + FLAG_C);
	expect_flags_clear(FLAG_Z + FLAG_C);
	expect_flags_set(FLAG_N);
	assert_c(top.reg_A == 0xD9);
	std::cout << "DCP a16,X" << std::endl;
	capture_state();
	abs_x_rmw_instruction_exec(I_ISC_A16X, distWord(rng), 0x67, 0x66, REG_X);
	expect_register_changes(0);
	expect_flag_changes(FLAG_N + FLAG_C);
	expect_flags_clear(FLAG_N);
	expect_flags_set(FLAG_C);
	std::cout << "ISC a16,X" << std::endl;
	capture_state();
	abs_x_rmw_instruction_exec(I_DCP_A16Y, distWord(rng), 0x92, 0x93, REG_X);
	expect_register_changes(REG_A);
	expect_flag_changes(0);
	assert_c(top.reg_A == 0x46);
	std::cout << "DCP a16,Y" << std::endl;
	capture_state();
	abs_x_rmw_instruction_exec(I_DCP_A16Y, distWord(rng), 0x46, 0x45, REG_Y);
	expect_register_changes(0);
	expect_flag_changes(0);
	abs_x_rmw_instruction_exec(I_ISC_A16Y, distWord(rng), 0x47, 0x46, REG_Y);
	expect_register_changes(0);
	expect_flag_changes(FLAG_Z);
	expect_flags_set(FLAG_Z);
	std::cout << "ISC a16,Y" << std::endl;
	capture_state();
	abs_x_rmw_instruction_exec(I_NOP_IMM, distWord(rng), 0x22, 0x23, REG_Y);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_Z);
	expect_flags_clear(FLAG_Z);
	assert_c(top.reg_A == 0x23);
	std::cout << "DCP (a8,X)" << std::endl;
	set_register_value(REG_X, distByte(rng));
	set_register_value(REG_Y, distByte(rng));
	set_register_value(REG_A, 0x2A);
	immediate_instruction_exec(I_SEC, distByte(rng));
	implied_instruction_exec(I_DCP_A8_INDIR_X);
	capture_state();
	zp_indir_x_rmw_instruction_exec(I_ISC_A8_INDIR_X, distByte(rng), distWord(rng), 0x3F, 0x3E);
	expect_register_changes(0);
	expect_flag_changes(FLAG_N + FLAG_C);
	expect_flags_set(FLAG_N);
	expect_flags_clear(FLAG_C);
	std::cout << "ISC (a8,X)" << std::endl;
	capture_state();
	zp_indir_x_rmw_instruction_exec(I_DCP_A8_INDIR_Y, distByte(rng), distWord(rng), 0x0F, 0x10);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_N + FLAG_C);
	expect_flags_clear(FLAG_N);
	expect_flags_set(FLAG_C);
	assert_c(top.reg_A == 0x1A);
	std::cout << "DCP (a8),Y" << std::endl;
	capture_state();
	zp_indir_y_rmw_instruction_exec(I_ISC_A8_INDIR_Y, distByte(rng), distWord(rng), 0x00, 0xFF);
	expect_register_changes(0);
	expect_flag_changes(FLAG_C);
	expect_flags_clear(FLAG_C);
	std::cout << "ISC (a8),Y" << std::endl;
	capture_state();
	zp_indir_y_rmw_instruction_exec(I_NOP_IMM, distByte(rng), distWord(rng), 0x19, 0x1A);
	expect_register_changes(REG_A);
	expect_flag_changes(FLAG_C + FLAG_Z);
	expect_flags_set(FLAG_C + FLAG_Z);
	assert_c(top.reg_A == 0x00);
}

void verify_jmp_instructions() {
	std::cout << "JMP a16" << std::endl;
	capture_state();
	immediate_instruction_exec(I_JMP, distByte(rng));
	jmp_instruction_exec(I_JMP, distWord(rng));
	expect_register_changes(0);
	expect_flag_changes(0);
	capture_state();
	jmp_instruction_exec(I_NOP_IMM, distWord(rng));
	expect_register_changes(0);
	expect_flag_changes(0);
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	immediate_instruction_exec(I_JMP_INDIR, distByte(rng));
	std::cout << "JMP (a16)" << std::endl;
	capture_state();
	jmp_indir_instruction_exec(I_NOP_IMM, distWord(rng), distWord(rng));
	expect_register_changes(0);
	expect_flag_changes(0);
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
}

void verify_branch_instructions() {
	std::cout << "BPL r8" << std::endl;
	set_register_value(REG_X, 0xFF);
	capture_state();
	immediate_instruction_exec(I_BPL, distByte(rng));
	branch_instruction_exec(I_NOP_IMM, distByte(rng), NOT_TAKEN);
	expect_register_changes(0);
	expect_flag_changes(0);
	set_register_value(REG_X, 0x01);
	capture_state();
	immediate_instruction_exec(I_BPL, distByte(rng));
	branch_instruction_exec(I_BPL, 0, TAKEN);
	branch_instruction_exec(I_CLV, distByte(rng), TAKEN);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "BMI r8" << std::endl;
	capture_state();
	implied_instruction_exec(I_BMI);
	branch_instruction_exec(I_NOP_IMM, distByte(rng), NOT_TAKEN);
	expect_register_changes(0);
	expect_flag_changes(0);
	set_register_value(REG_Y, 0x80);
	capture_state();
	immediate_instruction_exec(I_BMI, distByte(rng));
	branch_instruction_exec(I_NOP_IMM, distByte(rng), TAKEN);
	expect_register_changes(0);
	expect_flag_changes(0);
	top.SOn = 0;
	immediate_instruction_exec(I_BVC, distByte(rng));
	top.SOn = 1;
	std::cout << "BVC r8" << std::endl;
	capture_state();
	branch_instruction_exec(I_CLV, distByte(rng), NOT_TAKEN);
	expect_register_changes(0);
	expect_flag_changes(0);
	implied_instruction_exec(I_BVC);
	capture_state();
	branch_instruction_exec(I_NOP_IMM, distByte(rng), TAKEN);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "BVS r8" << std::endl;
	capture_state();
	branch_instruction_exec(I_NOP_IMM, distByte(rng), NOT_TAKEN);
	expect_register_changes(0);
	expect_flag_changes(0);
	top.SOn = 0;
	immediate_instruction_exec(I_BVS, distByte(rng));
	top.SOn = 1;
	capture_state();
	branch_instruction_exec(I_SEC, distByte(rng), TAKEN);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "BCC r8" << std::endl;
	implied_instruction_exec(I_BCC);
	capture_state();
	branch_instruction_exec(I_CLC, distByte(rng), NOT_TAKEN);
	expect_register_changes(0);
	expect_flag_changes(0);
	implied_instruction_exec(I_BCC);
	capture_state();
	branch_instruction_exec(I_BCS, distByte(rng), TAKEN);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "BCS r8" << std::endl;
	capture_state();
	branch_instruction_exec(I_SEC, distByte(rng), NOT_TAKEN);
	expect_register_changes(0);
	expect_flag_changes(0);
	implied_instruction_exec(I_BCS);
	capture_state();
	branch_instruction_exec(I_NOP_IMM, distByte(rng), TAKEN);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "BNE r8" << std::endl;
	set_register_value(REG_A, 0x00);
	immediate_instruction_exec(I_BNE, distByte(rng));
	capture_state();
	branch_instruction_exec(I_NOP_IMM, distByte(rng), NOT_TAKEN);
	expect_register_changes(0);
	expect_flag_changes(0);
	set_register_value(REG_A, 0x01);
	immediate_instruction_exec(I_BNE, distByte(rng));
	capture_state();
	branch_instruction_exec(I_BEQ, distByte(rng), TAKEN);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "BEQ r8" << std::endl;
	capture_state();
	branch_instruction_exec(I_NOP_IMM, distByte(rng), NOT_TAKEN);
	expect_register_changes(0);
	expect_flag_changes(0);
	set_register_value(REG_X, 0x00);
	immediate_instruction_exec(I_BEQ, distByte(rng));
	capture_state();
	branch_instruction_exec(I_NOP_IMM, distByte(rng), TAKEN);
	expect_register_changes(0);
	expect_flag_changes(0);
}

void verify_call_instructions() {
	std::cout << "JSR a16" << std::endl;
	immediate_instruction_exec(I_JSR, distByte(rng));
	capture_state();
	jsr_instruction_exec(I_NOP_IMM, distWord(rng));
	expect_register_changes(REG_SP);
	expect_flag_changes(0);
	immediate_instruction_exec(I_JSR, distByte(rng));
	capture_state();
	jsr_instruction_exec(I_NOP_IMM, distWord(rng));
	expect_register_changes(REG_SP);
	expect_flag_changes(0);
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	std::cout << "RTS" << std::endl;
	immediate_instruction_exec(I_RTS, distByte(rng));
	capture_state();
	rts_instruction_exec(I_NOP_IMM, distWord(rng));
	expect_register_changes(REG_SP);
	expect_flag_changes(0);
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	immediate_instruction_exec(I_CLC, distByte(rng));
	implied_instruction_exec(I_NOP_IMM);
	immediate_instruction_exec(I_RTS, distByte(rng));
	capture_state();
	rts_instruction_exec(I_NOP_IMM, distWord(rng));
	expect_register_changes(REG_SP);
	expect_flag_changes(0);
	set_register_value(REG_X, distByte(rng));
	immediate_instruction_exec(I_TXS, distByte(rng));
	implied_instruction_exec(I_NOP_IMM);
	expect_SP = top.reg_X;
	std::cout << "BRK" << std::endl;
	immediate_instruction_exec(I_BRK, distByte(rng));
	expect_bus_cycle(expect_PC++, distByte(rng), BUS_STATE_READ, 0);
	expect_vector(0xFFFE, distWord(rng), 1);
	expect_bus_cycle(expect_PC++, I_NOP_IMM, BUS_STATE_READ, 1);
	expect_register_changes(REG_SP);
	expect_flag_changes(0);
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	std::cout << "RTI" << std::endl;
	set_register_value(REG_A, 0x88);
	immediate_instruction_exec(I_CLV, distByte(rng));
	implied_instruction_exec(I_CLC);
	implied_instruction_exec(I_RTI);
	capture_state();
	rti_instruction_exec(I_NOP_IMM, distWord(rng), FLAG_V + FLAG_C + FLAG_I);
	expect_flag_changes(FLAG_V + FLAG_C + FLAG_N);
	expect_flags_set(FLAG_V + FLAG_C + FLAG_I);
	expect_flags_clear(FLAG_N + FLAG_Z);
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	immediate_instruction_exec(I_NOP_IMM, distByte(rng));
	set_register_value(REG_X, distByte(rng));
	immediate_instruction_exec(I_TXS, distByte(rng));
	implied_instruction_exec(I_NOP_IMM);
	expect_SP = top.reg_X;
	set_register_value(REG_Y, distByte(rng));
	set_register_value(REG_A, distByte(rng));
}

void verify_pushpull_instructions() {
	std::cout << "PHP" << std::endl;
	uint8_t orig_SP = top.reg_SP;
	set_register_value(REG_A, 0xC5);
	immediate_instruction_exec(I_CLV, distByte(rng));
	implied_instruction_exec(I_PHP);
	capture_state();
	push_instruction_exec(I_PHP, top.flags);
	push_instruction_exec(I_NOP_IMM, top.flags);
	expect_register_changes(REG_SP);
	expect_flag_changes(0);
	std::cout << "PHA" << std::endl;
	immediate_instruction_exec(I_PHA, distByte(rng));
	capture_state();
	push_instruction_exec(I_PHA, 0xC5);
	push_instruction_exec(I_PLA, 0xC5);
	expect_register_changes(REG_SP);
	expect_flag_changes(0);
	assert_c(top.reg_SP == ((orig_SP - 4) & 0xFF));
	std::cout << "PLA" << std::endl;
	capture_state();
	pull_instruction_exec(I_PLA, 0x33);
	expect_register_changes(REG_A + REG_SP);
	expect_flag_changes(FLAG_N);
	expect_flags_clear(FLAG_N);
	capture_state();
	pull_instruction_exec(I_PLP, 0x00);
	expect_register_changes(REG_A + REG_SP);
	expect_flag_changes(FLAG_Z);
	expect_flags_set(FLAG_Z);
	std::cout << "PLP" << std::endl;
	capture_state();
	pull_instruction_exec(I_PLP, FLAG_V + FLAG_C + FLAG_I);
	expect_register_changes(REG_SP);
	expect_flag_changes(FLAG_Z + FLAG_V);
	expect_flags_set(FLAG_V + FLAG_C + FLAG_I);
	expect_flags_clear(FLAG_Z + FLAG_N);
	capture_state();
	pull_instruction_exec(I_NOP_IMM, FLAG_I);
	expect_register_changes(REG_SP);
	expect_flag_changes(FLAG_V + FLAG_C);
	expect_flags_clear(FLAG_V + FLAG_C);
	assert_c(top.reg_SP == orig_SP);
}

void verify_bittest_instructions() {
	std::cout << "BIT a8" << std::endl;
	set_register_value(REG_A, 0x69);
	immediate_instruction_exec(I_CLV, distByte(rng));
	implied_instruction_exec(I_BIT_A8);
	capture_state();
	zp_instruction_exec(I_BIT_A8, distByte(rng), 0x02);
	expect_flag_changes(FLAG_Z);
	expect_flags_set(FLAG_Z);
	capture_state();
	zp_instruction_exec(I_BIT_A16, distByte(rng), 0x81);
	expect_flag_changes(FLAG_Z + FLAG_N);
	expect_flags_clear(FLAG_Z);
	expect_flags_set(FLAG_N);
	std::cout << "BIT a16" << std::endl;
	capture_state();
	abs_instruction_exec(I_BIT_A16, distWord(rng), 0x60);
	expect_flag_changes(FLAG_N + FLAG_V);
	expect_flags_clear(FLAG_N);
	expect_flags_set(FLAG_V);
	capture_state();
	abs_instruction_exec(I_NOP_IMM, distWord(rng), 0xFF);
	expect_flag_changes(FLAG_N);
	expect_flags_set(FLAG_N + FLAG_V);
}

void verify_store_instructions() {
	std::cout << "STA a8" << std::endl;
	uint8_t value = distByte(rng);
	set_register_value(REG_A, value);
	immediate_instruction_exec(I_STA_A8, distByte(rng));
	capture_state();
	zp_store_instruction_exec(I_NOP_IMM, distByte(rng), value);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "STX a8" << std::endl;
	value = distByte(rng);
	set_register_value(REG_X, value);
	immediate_instruction_exec(I_STX_A8, distByte(rng));
	capture_state();
	zp_store_instruction_exec(I_NOP_IMM, distByte(rng), value);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "STY a8" << std::endl;
	value = distByte(rng);
	set_register_value(REG_Y, value);
	immediate_instruction_exec(I_STY_A8, distByte(rng));
	capture_state();
	zp_store_instruction_exec(I_NOP_IMM, distByte(rng), value);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "SAX a8" << std::endl;
	value = distByte(rng);
	uint8_t value2 = distByte(rng);
	set_register_value(REG_A, value);
	set_register_value(REG_X, value2);
	immediate_instruction_exec(I_SAX_A8, distByte(rng));
	capture_state();
	zp_store_instruction_exec(I_NOP_IMM, distByte(rng), value & value2);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "STA a8,X" << std::endl;
	set_register_value(REG_X, distByte(rng));
	value = distByte(rng);
	set_register_value(REG_A, value);
	immediate_instruction_exec(I_STA_A8X, distByte(rng));
	capture_state();
	zp_x_store_instruction_exec(I_NOP_IMM, distByte(rng), value, REG_X);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "STY a8,X" << std::endl;
	set_register_value(REG_X, distByte(rng));
	value = distByte(rng);
	set_register_value(REG_Y, value);
	immediate_instruction_exec(I_STY_A8X, distByte(rng));
	capture_state();
	zp_x_store_instruction_exec(I_NOP_IMM, distByte(rng), value, REG_X);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "STX a8,Y" << std::endl;
	set_register_value(REG_Y, distByte(rng));
	value = distByte(rng);
	set_register_value(REG_X, value);
	immediate_instruction_exec(I_STX_A8X, distByte(rng));
	capture_state();
	zp_x_store_instruction_exec(I_NOP_IMM, distByte(rng), value, REG_Y);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "SAX a8,Y" << std::endl;
	set_register_value(REG_Y, distByte(rng));
	value = distByte(rng);
	set_register_value(REG_A, value);
	value2 = distByte(rng);
	set_register_value(REG_X, value2);
	immediate_instruction_exec(I_SAX_A8Y, distByte(rng));
	capture_state();
	zp_x_store_instruction_exec(I_NOP_IMM, distByte(rng), value & value2, REG_Y);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "STA (a8,X)" << std::endl;
	set_register_value(REG_X, distByte(rng));
	value2 = distByte(rng);
	set_register_value(REG_A, value2);
	immediate_instruction_exec(I_STA_A8_INDIR_X, distByte(rng));
	capture_state();
	zp_indir_x_store_instruction_exec(I_NOP_IMM, distByte(rng), distWord(rng), value2);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "STA (a8),Y" << std::endl;
	set_register_value(REG_Y, distByte(rng));
	value = distByte(rng);
	set_register_value(REG_A, value);
	immediate_instruction_exec(I_STA_A8_INDIR_Y, distByte(rng));
	capture_state();
	zp_indir_y_store_instruction_exec(I_NOP_IMM, distByte(rng), distWord(rng), value);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "SAX (a8,X)" << std::endl;
	value2 = distByte(rng);
	value = distByte(rng);
	set_register_value(REG_A, value);
	set_register_value(REG_X, value2);
	immediate_instruction_exec(I_SAX_A8_INDIR_X, distByte(rng));
	capture_state();
	zp_indir_x_store_instruction_exec(I_NOP_IMM, distByte(rng), distWord(rng), value2 & value);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "SHA (a8),Y" << std::endl;
	value2 = distByte(rng);
	value = distByte(rng);
	set_register_value(REG_A, value);
	set_register_value(REG_X, value2);
	immediate_instruction_exec(I_SHA_A8_INDIR_Y, distByte(rng));
	uint16_t addr = distWord(rng);
	capture_state();
	zp_indir_y_store_instruction_exec(I_NOP_IMM, distByte(rng), addr, value2 & value & ((addr >> 8) + 1));
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "STA a16" << std::endl;
	value = distByte(rng);
	set_register_value(REG_A, value);
	immediate_instruction_exec(I_STA_A16, distByte(rng));
	capture_state();
	abs_store_instruction_exec(I_NOP_IMM, distWord(rng), value);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "STX a16" << std::endl;
	value = distByte(rng);
	set_register_value(REG_X, value);
	immediate_instruction_exec(I_STX_A16, distByte(rng));
	capture_state();
	abs_store_instruction_exec(I_NOP_IMM, distWord(rng), value);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "STY a16" << std::endl;
	value = distByte(rng);
	set_register_value(REG_Y, value);
	immediate_instruction_exec(I_STY_A16, distByte(rng));
	capture_state();
	abs_store_instruction_exec(I_NOP_IMM, distWord(rng), value);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "SAX a16" << std::endl;
	value = distByte(rng);
	value2 = distByte(rng);
	set_register_value(REG_A, value);
	set_register_value(REG_X, value2);
	immediate_instruction_exec(I_SAX_A16, distByte(rng));
	capture_state();
	abs_store_instruction_exec(I_NOP_IMM, distWord(rng), value & value2);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "STA a16,X" << std::endl;
	value = distByte(rng);
	set_register_value(REG_A, value);
	set_register_value(REG_X, distByte(rng));
	immediate_instruction_exec(I_STA_A16X, distByte(rng));
	capture_state();
	abs_x_store_instruction_exec(I_NOP_IMM, distWord(rng), value, REG_X);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "STA a16,Y" << std::endl;
	value = distByte(rng);
	set_register_value(REG_A, value);
	set_register_value(REG_Y, distByte(rng));
	immediate_instruction_exec(I_STA_A16Y, distByte(rng));
	capture_state();
	abs_x_store_instruction_exec(I_NOP_IMM, distWord(rng), value, REG_Y);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "SHA a16,Y" << std::endl;
	value2 = distByte(rng);
	value = distByte(rng);
	set_register_value(REG_A, value);
	set_register_value(REG_X, value2);
	set_register_value(REG_Y, distByte(rng));
	immediate_instruction_exec(I_SHA_A16Y, distByte(rng));
	addr = distWord(rng);
	capture_state();
	abs_x_store_instruction_exec(I_NOP_IMM, addr, value2 & value & ((addr >> 8) + 1), REG_Y);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "SHX a16,Y" << std::endl;
	value = distByte(rng);
	set_register_value(REG_A, distByte(rng));
	set_register_value(REG_X, value);
	set_register_value(REG_Y, distByte(rng));
	immediate_instruction_exec(I_SHX_A16Y, distByte(rng));
	capture_state();
	addr = distWord(rng);
	abs_x_store_instruction_exec(I_NOP_IMM, addr, value & ((addr >> 8) + 1), REG_Y);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "SHY a16,X" << std::endl;
	value = distByte(rng);
	set_register_value(REG_A, distByte(rng));
	set_register_value(REG_Y, value);
	set_register_value(REG_X, distByte(rng));
	immediate_instruction_exec(I_SHY_A16X, distByte(rng));
	capture_state();
	addr = distWord(rng);
	abs_x_store_instruction_exec(I_NOP_IMM, addr, value & ((addr >> 8) + 1), REG_X);
	expect_register_changes(0);
	expect_flag_changes(0);
	std::cout << "SHS a16,Y" << std::endl;
	value = distByte(rng);
	value2 = distByte(rng);
	set_register_value(REG_A, value2);
	set_register_value(REG_X, value);
	set_register_value(REG_Y, distByte(rng));
	immediate_instruction_exec(I_SHS_A16Y, distByte(rng));
	capture_state();
	addr = distWord(rng);
	abs_x_store_instruction_exec(I_NOP_IMM, addr, value & value2 & ((addr >> 8) + 1), REG_Y);
	expect_register_changes(REG_SP);
	expect_flag_changes(0);
	assert_c(top.reg_SP == (value & value2));
	expect_SP = value & value2;
}

void verify_xaa_instruction() {
	std::cout << "XAA d8" << std::endl;
	uint8_t value1 = distByte(rng);
	uint8_t value2 = distByte(rng);
	uint8_t value3 = distByte(rng);
	set_register_value(REG_A, value1);
	set_register_value(REG_X, value2);
	set_register_value(REG_Y, 0x01);
	immediate_instruction_exec(I_XAA_IMM, distByte(rng));
	capture_state();
	immediate_instruction_exec(I_NOP_IMM, value3);
	expect_register_changes(REG_A);
	uint8_t expected = (value1 | 0xFE) & value2 & value3;
	uint8_t expected_flags = 0;
	if(expected == 0) expected_flags = FLAG_Z;
	else if((expected & 0x80) != 0) expected_flags = FLAG_N;
	expect_flag_changes(expected_flags);
	if(expected == 0) expect_flags_set(FLAG_Z);
	else expect_flags_clear(FLAG_Z);
	if((expected & 0x80) != 0) expect_flags_set(FLAG_N);
	else expect_flags_clear(FLAG_N);
	assert_c(top.reg_A == expected);
}
