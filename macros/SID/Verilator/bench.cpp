#include "Vtb.h"
#include "verilated.h"
#include <iostream>
#include <fstream>

static Vtb top;

void clocks(int c) {
	for(int i = 0; i < c * 2; i++) {
		Verilated::timeInc(1);
		top.clk = !top.clk;
		top.eval();
		if(Verilated::gotFinish()) return;
	}
}

void sid_reg_write(int reg, int val) {
	top.address = reg;
	top.data = val;
	clocks(1);
	top.WEb = 0;
	clocks(2);
	top.WEb = 1;
	clocks(2);
}

void wait_secs(int secs) {
	float cycs = secs * 44100 * 90.7f;
	clocks((int)cycs);
}

int main(int argc, char** argv, char** env) {
#ifdef TRACE_ON
	printf("Warning: tracing is ON!\r\n");
	Verilated::traceEverOn(true);
#endif
	top.rst_n = 0;
	top.WEb = 1;
	clocks(2);
	top.rst_n = 1;
	clocks(24);
	/*sid_reg_write(0, 0x25);
	sid_reg_write(1, 0x11);
	sid_reg_write(2, 0x00);
	sid_reg_write(3, 0x08);
	sid_reg_write(5, 0xA9);
	sid_reg_write(6, 0x99);
	sid_reg_write(24, 0x0F);
	sid_reg_write(4, 17);
	wait_secs(1);
	sid_reg_write(4, 16);
	wait_secs(2);*/
	
	std::ifstream infile("../tunes/Lost_in_Love.regs.txt");
	
	long lastClocks = 555;
	long diff;
	std::string token;
	std::string line;
	int args[3];
	double lastPrintTime = 0;
	double currTime = 0;
	while(std::getline(infile, line)) {
		size_t pos = 0;
		for(int i = 0; i < 3; i++) {
			pos = line.find("-");
			token = line.substr(0, pos);
			line.erase(0, pos + 1);
			args[i] = std::stoi(token);
		}
		if(lastClocks == 555) diff = 0;
		else diff = args[0] - lastClocks;
		sid_reg_write(args[1], args[2]);
		if(diff > 0) {
			clocks(diff * 8);
			currTime += (double)(diff * 8) / 8000000.0;
		}
		if(currTime - lastPrintTime >= 10) {
			lastPrintTime = currTime;
			int secs = (int)lastPrintTime;
			int mins = secs / 60;
			secs -= mins * 60;
			printf("%d:%02d\r\n", mins, secs);
		}
		lastClocks = args[0];
	}
	
	top.final();
}
