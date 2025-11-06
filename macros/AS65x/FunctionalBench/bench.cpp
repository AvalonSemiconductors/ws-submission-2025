#include "Vcpu65_tb.h"
#include "verilated.h"
#include <iostream>

static Vcpu65_tb top;
double sc_time_stamp() { return 0; }

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
	Verilated::timeInc(1);
	top.eval();
	for(int i = 0; i < 8; i++) {
		top.clk_i = 0;
		Verilated::timeInc(5);
		top.eval();
		top.clk_i = 1;
		Verilated::timeInc(5);
		top.eval();
	}
	top.rst_n = 1;
	unsigned long cycles = 0;
	while(!Verilated::gotFinish()) {
		Verilated::timeInc(5);
		top.clk_i = !top.clk_i;
		top.eval();
		if(top.clk_i) cycles++;
	}
	std::cout << "Finished after " << cycles << " clock cycles" << std::endl;
	std::cout << "Exit code " << (int)top.D_OUT << std::endl;
	if(top.D_OUT == 9) std::cout << "BIG W!" << std::endl;
	else std::cout << "MASSIVE L!" << std::endl;
	
	Verilated::timeInc(5);
	top.eval();
	Verilated::timeInc(25);
	top.eval();
	top.final();
	return 0;
}
