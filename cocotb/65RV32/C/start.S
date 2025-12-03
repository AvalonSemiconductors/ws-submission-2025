
.section .initial_jump
.global _start
.global _nmivec
.type _nmivec, @function
.global _intvec
.type _intvec, @function

.align 4
_start:
	# For simulation stability
	li x1, 0
	li x2, 0
	li x3, 0
	li x4, 0
	li x5, 0
	li x6, 0
	li x7, 0
	li x8, 0
	li x9, 0
	li x10, 0
	li x11, 0
	li x12, 0
	li x13, 0
	li x14, 0
	li x15, 0
	li x16, 0
	li x17, 0
	# Extend address bus to 32-bits
	csrwi 0xBC2, 4
	li x18, 0
	li x19, 0
	li x20, 0
	li x21, 0
	li x22, 0
	li x23, 0
	li x24, 0
	li x25, 0
	li x26, 0
	li x27, 0
	li x28, 0
	li x29, 0
	li x30, 0
	li x31, 0

	la	sp, _sstack
	addi	sp,sp,-16
	sw	ra,12(sp)
	li ra, 0xFFFFFFF4
	la t0, _nmivec
	sw t0,0(ra)
	li ra, 0xFFFFFFF8
	la t0, _intvec
	sw t0,0(ra)
	csrwi 0x744, 8
	li t0, (1<<7)|(1<<11)
	csrw 0x304, t0
	csrwi 0x300, 8
	csrw 0xBC3, 0
	li t0, 10000
	csrw 0xBC4, t0
	
	# Atomic tests begin
	li t0, 0x69696969
	li t1, 33
	sw t1,0(t0)
	lr.w t2,(t0)
	addi t1, t2, 1
	sc.w t0,t1,(t0)
	
	jal	ra, main
	ebreak

halt:
	nop
	j halt

_nmivec:
	nop
	addi sp,sp,-33*4
	sw x1, 1*4(sp)
	sw x3, 3*4(sp)
	sw x4, 4*4(sp)
	sw x5, 5*4(sp)
	sw x6, 6*4(sp)
	sw x7, 7*4(sp)
	sw x10, 10*4(sp)
	sw x11, 11*4(sp)
	sw x12, 12*4(sp)
	sw x13, 13*4(sp)
	sw x14, 14*4(sp)
	sw x15, 15*4(sp)
	sw x16, 16*4(sp)
	sw x17, 17*4(sp)
	sw x28, 28*4(sp)
	sw x29, 29*4(sp)
	sw x30, 30*4(sp)
	sw x31, 31*4(sp)
	call nmiisr
	lw x1, 1*4(sp)
	lw x3, 3*4(sp)
	lw x4, 4*4(sp)
	lw x5, 5*4(sp)
	lw x6, 6*4(sp)
	lw x7, 7*4(sp)
	lw x10, 10*4(sp)
	lw x11, 11*4(sp)
	lw x12, 12*4(sp)
	lw x13, 13*4(sp)
	lw x14, 14*4(sp)
	lw x15, 15*4(sp)
	lw x16, 16*4(sp)
	lw x17, 17*4(sp)
	lw x28, 28*4(sp)
	lw x29, 29*4(sp)
	lw x30, 30*4(sp)
	lw x31, 31*4(sp)
	addi sp,sp,33*4
	nop
.word 0x70200073 #nmret

_intvec:
	nop
	addi sp,sp,-33*4
	sw x1, 1*4(sp)
	sw x3, 3*4(sp)
	sw x4, 4*4(sp)
	sw x5, 5*4(sp)
	sw x6, 6*4(sp)
	sw x7, 7*4(sp)
	sw x10, 10*4(sp)
	sw x11, 11*4(sp)
	sw x12, 12*4(sp)
	sw x13, 13*4(sp)
	sw x14, 14*4(sp)
	sw x15, 15*4(sp)
	sw x16, 16*4(sp)
	sw x17, 17*4(sp)
	sw x28, 28*4(sp)
	sw x29, 29*4(sp)
	sw x30, 30*4(sp)
	sw x31, 31*4(sp)
	call intisr
	lw x1, 1*4(sp)
	lw x3, 3*4(sp)
	lw x4, 4*4(sp)
	lw x5, 5*4(sp)
	lw x6, 6*4(sp)
	lw x7, 7*4(sp)
	lw x10, 10*4(sp)
	lw x11, 11*4(sp)
	lw x12, 12*4(sp)
	lw x13, 13*4(sp)
	lw x14, 14*4(sp)
	lw x15, 15*4(sp)
	lw x16, 16*4(sp)
	lw x17, 17*4(sp)
	lw x28, 28*4(sp)
	lw x29, 29*4(sp)
	lw x30, 30*4(sp)
	lw x31, 31*4(sp)
	addi sp,sp,33*4
	nop
	mret

.section .data

.section .text
