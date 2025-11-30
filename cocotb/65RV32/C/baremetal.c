#include <stdint.h>
#include <stdarg.h>
#include <stdbool.h>

#include "tholinstd.h"

#define DDR 0xBC0
#define PORT 0xBC1
#define UDIV 0x142
#define UTX 0x139
#define URX 0x140

__attribute__((always_inline)) inline int read_csr(const unsigned int csr_num) {
	int result;
	if(csr_num >= 2048) asm volatile("csrr %0, %1+2048" : "=r"(result) : "I"(csr_num-2048));
	else asm volatile("csrr %0, %1" : "=r"(result) : "I"(csr_num));
	return result;
}

__attribute__((always_inline)) inline void write_csr(const unsigned int csr_num, unsigned int value) {
	if(csr_num >= 2048) asm volatile("csrw %1+2048, %0" : : "r"(value), "I"(csr_num-2048));
	else asm volatile("csrw %1, %0" : : "r"(value), "I"(csr_num));
}

int putchar(int c) {
	volatile uint32_t a = 1;
	while(1) {
		a = read_csr(UTX);
		if(a == 0) break;
	}
	write_csr(UTX, c);
	*((volatile uint8_t*)0xFFFF) = c;
	return 0;
}

float absd(float x) {
	if(x < 0) return -x;
	return x;
}

void main(void) {
	write_csr(DDR, 0x0F);
	write_csr(PORT, 0x05);
	write_csr(UDIV, 0x02);
	puts("Hello from Tholin's RISC-V Core!\r\n");
	uint32_t a = read_csr(0xFC5);
	putchar(a & 0xFF);
	putchar((a >> 8) & 0xFF);
	putchar((a >> 16) & 0xFF);
	putchar((a >> 24) & 0xFF);
	a = read_csr(0xFC6);
	putchar(a & 0xFF);
	putchar((a >> 8) & 0xFF);
	puts("\r\n");
	printf("ab%c %d \"%s\" hex=%x unsigned=%u\n", 'c', 219581, "another string", 219582, 3070660541U);
	printf("longs: %ld hex=%lx unsigned=%lu\n", 2704080616701578000UL, 2704080616701578001UL, 17137082711761398313UL);
	float ratio1,ratio2;
	long fiba,fibb,t;
	float epsilon;
	int fibCntr;
	fiba = 1;
	fibb = 1;
	epsilon = 1e-32;
	fibCntr = 0;
	printf("Aproximating golden ratio\n");
	while(1) {
		putchar('-');
		fibCntr++;
		t = fiba;
		fiba = fibb;
		fibb = fiba + t;
		ratio1 = (float)fibb / (float)fiba;
		ratio2 = (float)(fiba + fibb) / (float)fibb;
		if(absd(ratio1 - ratio2) < epsilon) break;
	}
	printf("\r\n%d\r\n", (int)(ratio1 * 1000));
	printf("%d\r\n", fibCntr);
	*((volatile uint8_t*)0xFFFF) = 0;
	while(1);
}
