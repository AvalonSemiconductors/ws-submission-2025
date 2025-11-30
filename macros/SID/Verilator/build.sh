#!/bin/bash

export RTL_DIR=$PWD/../src/
set -e

#TRACE_FLAGS="--trace-depth 3 --trace -DTRACE_ON -CFLAGS '-DTRACE_ON'"
verilator -DBENCH -Wno-fatal --timing --top-module tb -cc -exe ${TRACE_FLAGS} bench.cpp ./tb.v ./MCP4921.v ${RTL_DIR}/SID_top.v ${RTL_DIR}/spi_dac_i.v ${RTL_DIR}/SID_channels.v ${RTL_DIR}/SID_filter.v ${RTL_DIR}/wrapped_sid.v
cd obj_dir
make -f Vtb.mk
cd ..
