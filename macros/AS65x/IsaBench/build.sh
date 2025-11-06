#!/bin/bash

set - e

TRACE_FLAGS="--trace-depth 6 --trace -DTRACE_ON -CFLAGS '-DTRACE_ON'"
verilator -DBENCH -CFLAGS '-std=c++20' -Wno-fatal --timing --top-module cpu65_tb -cc -exe ${TRACE_FLAGS} bench.cpp tb.v ../src/cpu.v
cd obj_dir
make -f Vcpu65_tb.mk
cd ..
