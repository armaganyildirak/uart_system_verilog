# UART Implementation with FIFO Buffers

A simple UART (Universal Asynchronous Receiver/Transmitter) implementation in Verilog with TX/RX FIFO buffers.

## Features
- 9600 baud rate (configurable in `baud_gen.v`)
- 8-bit data, no parity, 1 stop bit
- 16-byte TX and RX FIFO buffers
- Loopback testbench for verification

## Files
- `src/baud_gen.v` - Baud rate generator
- `src/fifo.v` - FIFO buffer implementation
- `src/uart_tx.v` - UART transmitter
- `src/uart_rx.v` - UART receiver  
- `src/uart_top.v` - Top-level module
- `testbench/tb_uart_top.v` - Testbench
- `testbench/test_uart.py` - Cocotb test script

## Requirements
- Icarus Verilog (or other Verilog simulator)
- Python
- Cocotb
- GTKWave (optional, for viewing waveforms)

## Usage
1. Run the test:
```bash
make
```
2. View waveforms (after running tests):
```
make wave
```
3. Clean generated files:
```
make clean
```

## Test Result

The testbench sends 0x55 and verifies the received data matches in the loopback test.

```
  4000.00ns INFO     cocotb.tb_uart_top                 Writing 0x55 to TX FIFO
  4010.00ns INFO     cocotb.tb_uart_top                 Start bit detected on TX
 47450.00ns INFO     cocotb.tb_uart_top                 TX bit 0: 0
 94795.00ns INFO     cocotb.tb_uart_top                 TX bit 1: 1
142140.00ns INFO     cocotb.tb_uart_top                 TX bit 2: 0
189485.00ns INFO     cocotb.tb_uart_top                 TX bit 3: 1
236830.00ns INFO     cocotb.tb_uart_top                 TX bit 4: 0
284175.00ns INFO     cocotb.tb_uart_top                 TX bit 5: 1
331520.00ns INFO     cocotb.tb_uart_top                 TX bit 6: 0
378865.00ns INFO     cocotb.tb_uart_top                 TX bit 7: 1
426210.00ns INFO     cocotb.tb_uart_top                 TX bit 8: 0
473555.00ns INFO     cocotb.tb_uart_top                 TX bit 9: 1
473655.00ns INFO     cocotb.tb_uart_top                 Transmitted bits: [0, 1, 0, 1, 0, 1, 0, 1, 0, 1]
Received data: 0x55
3473655.00ns INFO     cocotb.tb_uart_top                 RX FIFO empty: 0
3473665.00ns INFO     cocotb.tb_uart_top                 RX data: 0x55
3473665.00ns INFO     cocotb.tb_uart_top                 Test passed!
3473665.00ns INFO     cocotb.regression                  test_uart_loopback passed
3473665.00ns INFO     cocotb.regression                  ************************************************************************************************
                                                         ** TEST                                    STATUS  SIM TIME (ns)  REAL TIME (s)  RATIO (ns/s) **
                                                         ************************************************************************************************
                                                         ** testbench.test_uart.test_uart_loopback   PASS     3473665.00           4.08     851968.95  **
                                                         ************************************************************************************************
                                                         ** TESTS=1 PASS=1 FAIL=0 SKIP=0                      3473665.00           4.30     808189.09  **
                                                         ************************************************************************************************
```