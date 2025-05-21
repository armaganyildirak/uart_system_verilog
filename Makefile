TOPLEVEL = tb_uart_top
MODULE = testbench.test_uart
VERILOG_SOURCES = \
    src/baud_gen.v \
    src/fifo.v \
    src/uart_tx.v \
    src/uart_rx.v \
    src/uart_top.v \
    testbench/tb_uart_top.v

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: wave clean

wave:
	gtkwave uart_wave.vcd &

clean::
	rm -rf sim_build results.xml uart_wave.vcd testbench/__pycache__
