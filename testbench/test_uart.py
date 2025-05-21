#!/usr/bin/env python3
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, FallingEdge

@cocotb.test()
async def test_uart_loopback(dut):
    """UART loopback test with FIFO and parity support"""

    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut.rst_n.value = 0
    dut.tx_data_in.value = 0
    dut.tx_wr_en.value = 0
    dut.rx_rd_en.value = 0
    await Timer(2000, units="ns")
    dut.rst_n.value = 1
    await Timer(2000, units="ns")

    test_byte = 0x55  # 01010101 in binary
    dut._log.info(f"Writing 0x{test_byte:02x} to TX FIFO")
    dut.tx_data_in.value = test_byte
    dut.tx_wr_en.value = 1
    await RisingEdge(dut.clk)
    dut.tx_wr_en.value = 0

    # Wait for transmission to start
    timeout = 0
    while timeout < 10000:
        await RisingEdge(dut.clk)
        timeout += 1
        if dut.tx.value == 0:  # Start bit detected
            dut._log.info("Start bit detected on TX")
            break
    assert timeout < 10000, "TX failed to start within timeout"
    
    # Observe TX signal during transmission
    bit_count = 0
    bit_values = []
    prev_tx = 0
    
    # Detect edges in TX signal to monitor the actual bits
    timeout = 0
    while bit_count < 10 and timeout < 600000:  # Start bit + 8 data bits + stop bit
        await RisingEdge(dut.clk)
        timeout += 1
        
        if dut.uart_inst.baud_tick.value == 1:
            cur_tx = dut.tx.value
            bit_values.append(int(cur_tx))
            dut._log.info(f"TX bit {bit_count}: {int(cur_tx)}")
            bit_count += 1
            
            # Add additional delay to ensure we're in the middle of the next bit
            await Timer(100, units="ns")
    
    # Verify proper bit transmission
    dut._log.info(f"Transmitted bits: {bit_values}")
    
    # Wait for full transmission to complete and data to arrive in RX FIFO
    # Need to wait for at least: start bit + 8 data bits + stop bit = 10 bits at 9600 baud
    # 10 bits * (1/9600) seconds = ~1.04ms, but let's wait a bit longer to be safe
    await Timer(3_000_000, units="ns")  # 3ms should be plenty of time
    
    # Check if reception was successful
    rx_empty = dut.rx_empty.value
    dut._log.info(f"RX FIFO empty: {rx_empty}")
    
    # Read data from the RX FIFO
    dut.rx_rd_en.value = 1
    await RisingEdge(dut.clk)
    dut.rx_rd_en.value = 0
    await RisingEdge(dut.clk)  # Wait one more cycle for data to be visible
        
    # Log diagnostic information
    rx_data = dut.rx_data_out.value.integer
    dut._log.info(f"RX data: 0x{rx_data:02x}")
        
    # Verify the data was received correctly
    assert rx_data == test_byte, f"Mismatch: Sent 0x{test_byte:02x}, Received 0x{rx_data:02x}"
    dut._log.info("Test passed!")