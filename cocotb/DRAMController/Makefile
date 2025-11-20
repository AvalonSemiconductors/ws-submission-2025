PWD=$(shell pwd)
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
PDK_ROOT ?= $(PWD)/../../gf180mcu_pdk
WAVES = 1

COMPILE_ARGS += -DSIM
VERILOG_SOURCES += $(PWD)/tb.v
VERILOG_SOURCES += $(PDK_ROOT)/gf180mcuD/libs.ref/gf180mcu_fd_io/verilog/gf180mcu_fd_io.v
VERILOG_SOURCES += $(PDK_ROOT)/gf180mcuD/libs.ref/gf180mcu_fd_io/verilog/gf180mcu_ws_io.v
VERILOG_SOURCES += $(PDK_ROOT)/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/gf180mcu_fd_sc_mcu7t5v0.v
VERILOG_SOURCES += $(PWD)/../../ip/gf180mcu_ws_ip__id/vh/gf180mcu_ws_ip__id.v
VERILOG_SOURCES += $(PWD)/../../ip/gf180mcu_ws_ip__logo/vh/gf180mcu_ws_ip__logo.v

COMPILE_ARGS += -DUSE_POWER_PINS

ifneq ($(GL),yes)
VERILOG_SOURCES += $(PWD)/../includes.rtl.v
else
COMPILE_ARGS += -DGL_TEST
COMPILE_ARGS += -DFUNCTIONAL
VERILOG_SOURCES += $(PWD)/../includes.gl.v
endif

COCOTB_TOPLEVEL = tb

COCOTB_TEST_MODULES = test

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: clean sim
