#include <stdint.h>
#include <stdarg.h>
#include <stdbool.h>

#include "tholinstd.h"

int puts(const char *str) {
	while(*str != 0) {
		putchar(*str);
		str++;
	}
	return 0;
}

uint32_t strlen(const char *str) {
	uint32_t slen = 0 ;
	while(*str != 0) {
		slen++;
		str++;
	}
	return slen;
}

char* strcpy(char *dest, const char *src) {
	while(*src) {
		*dest = *src;
		dest++;
		src++;
	}
	return dest;
}

const uint32_t itoa_divs[] = {1000000000, 100000000, 10000000, 1000000, 100000, 10000, 1000, 100, 10, 1};
char* itoa(int32_t s, char *buffer){
	uint32_t r,n;
	uint8_t k;
	bool flag = 0;
	char *bptr = buffer;
	if(s < 0) {
		*bptr = '-';
		bptr++;
		n =- s;
	}else n = s;
	k = 0;
	while(k != 10){
		r = n / itoa_divs[k];
		//for(r=0;k<=n;r++,n-=k);
		if(flag || r > 0 || k == 9){
			*bptr = ('0' + r);
			bptr++;
			flag = true;
		}
		n = n - r * itoa_divs[k];
		k++;
	}

	*bptr='\0';
	return buffer;
}

char* ltoa(int64_t s, char *buffer){
	uint64_t r,k,n;
	bool flag = 0;
	char *bptr = buffer;
	if(s < 0) {
		*bptr = '-';
		bptr++;
		n =- s;
	}else n = s;
	k = 10000000000000000000UL;
	while(k > 0) {
		r = n / k;
		if(flag || r > 0 || k == 1) {
			*bptr = ('0' + r);
			bptr++;
			flag = true;
		}
		n = n - r * k;
		k = k / 10;
	}
	
	*bptr = '\0';
	return buffer;
}

char* uitoa(uint32_t s, char *buffer){
	uint32_t r,k,n;
	bool flag = 0;
	char *bptr = buffer;
	n = s;
	k = 1000000000;
	while(k > 0){
		r = n / k;
		//for(r=0;k<=n;r++,n-=k);
		if(flag || r > 0||k == 1){
			*bptr = ('0'+r);bptr++;
			flag = true;
		}
		n=n-r*k;
		k = k/10;
	}

	*bptr='\0';
	return buffer;
}

char* ultoa(uint64_t s, char *buffer){
	uint64_t r,k,n;
	bool flag = 0;
	char *bptr = buffer;
	n = s;
	k = 10000000000000000000UL;
	while(k > 0) {
		r = n / k;
		if(flag || r > 0 || k == 1) {
			*bptr = ('0' + r);
			bptr++;
			flag = true;
		}
		n = n - r * k;
		k = k / 10;
	}
	
	*bptr = '\0';
	return buffer;
}

char* ftoa(float flt, char *outbfr) {
	if(flt < 0) {
		*outbfr = '-';
		outbfr++;
		flt = -flt;
	}
	uint64_t fixed = (uint64_t)(((double)flt + 1e-6) * (double)0xFFFFFF);
	uint32_t whole = fixed >> 24;
	uint64_t fract = fixed & 0xFFFFFFUL;
	uitoa(whole, outbfr);
	while(*outbfr) outbfr++;
	*outbfr = '.';
	outbfr++;
	for(char i = 0; i < 6; i++) {
		fract *= 10;
		*outbfr = (fract >> 24) + '0';
		fract &= 0xFFFFFFUL;
		outbfr++;
	}
	*outbfr = 0;
	return outbfr;
}

static const char hexchars[] = "0123456789ABCDEF";

void printf(const char* format, ...) {
	const char *traverse;
	unsigned int i;
	char *s;
	
	char tbuff[64];
	int32_t si;
	uint32_t ui;
	int64_t lsi;
	uint64_t lui;
	float sf;
	
	va_list arg;
	va_start(arg, format);
	for(traverse = format; *traverse != 0; traverse++) {
		if(*traverse == '%') {
			traverse++;
			char type = *traverse;
			
			switch(type) {
				case '%':
					putchar('%');
					break;
				case 'c':
					putchar(va_arg(arg, int32_t));
					break;
				case 'i': case 'd':
					si = va_arg(arg, int32_t);
					itoa(si, tbuff);
					puts(tbuff);
					break;
				case 's':
					puts(va_arg(arg, char *));
					break;
				case 'u':
					ui = va_arg(arg, uint32_t);
					uitoa(ui, tbuff);
					puts(tbuff);
					break;
				case 'x': case 'X':
					ui = va_arg(arg, uint32_t);
					for(uint8_t i = 0; i < 8; i++) {
						uint8_t x = (uint8_t)(ui >> 28);
						putchar(hexchars[x]);
						ui <<= 4;
					}
					break;
				case 'f':
					sf = (float)va_arg(arg, double);
					ftoa(sf, tbuff);
					puts(tbuff);
					break;
			}
			
			if(type == 'l') {
				traverse++;
				type = *traverse;
				switch(type) {
					case 'i': case 'd':
						lsi = va_arg(arg, int64_t);
						ltoa(lsi, tbuff);
						puts(tbuff);
						break;
					case 'u':
						lui = va_arg(arg, uint64_t);
						ultoa(lui, tbuff);
						puts(tbuff);
						break;
					case 'x': case 'X':
						lui = va_arg(arg, uint64_t);
						for(uint8_t i = 0; i < 16; i++) {
							uint8_t x = (uint8_t)(lui >> 60);
							putchar(hexchars[x]);
							lui <<= 4UL;
						}
						break;
				}
			}
		}else putchar(*traverse);
	}
}
