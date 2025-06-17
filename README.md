# UART Communication System 🚀  
**VHDL Implementation of UART Transmitter and Receiver**

![VHDL-UART](https://img.shields.io/badge/VHDL-UART-blue) ![License](https://img.shields.io/github/license/RoyIndr/VHDL_UART)

A complete UART (Universal Asynchronous Receiver/Transmitter) system implemented in VHDL!
---
## Features ✨
- **Full UART Implementation**  
  - Baud rate: 115200 bps (configurable)
  - 8-bit data format
  - 1 stop bit, no parity
- **Automatic Test Mode** 🔁  
  - Periodically transmits "S" (01010011 binary) every second
  - Verifies loopback functionality
- **Robust Sampling**  
  - 16x oversampling for noise immunity
  - Majority voting on data bits
- **Ready for FPGA Deployment** 🧩  
  - Generic clock frequency parameter
  - Synchronous design

## Repository Structure 📂
```bash
uart-vhdl/
├── Module_Rx.vhd          # UART Receiver
├── uart_tx.vhd            # UART Transmitter
├── top_module.vhd         # Top-level integration
├── modul_delay.vhd        # Transmission trigger (1-second interval)
└── README.md
```
---
## Component Overview 🔍
---
### 1. UART Receiver (`Module_Rx.vhd`)
- **Sampling**: 16x oversampling with majority voting  
- **States**: Idle → Start bit → Data bits → Stop bit  
- **Outputs**:  
  - `rx_data` (8-bit)  
  - `rx_done` pulse  

### 2. UART Transmitter (`uart_tx.vhd`)
- **Baud Generator**: Configurable via generics  
- **States**: Idle → Start bit → Data bits → Stop bit  
- **Inputs**:  
  - `tx_start` trigger  
  - `tx_data` (8-bit)  

### 3. Test Controller (`modul_delay.vhd`)
- **Function**: Generates 1-second transmission pulses  
- **Configurable**: Adjustable via `CLK_FREQ` generic  

### 4. Top Module (`top_module.vhd`)
- **Integration**: Instantiates RX, TX, and delay modules  
- **Loopback Test**: Automatically transmits → receives → verifies  

## Configuration ⚙️
Set parameters in `top_module.vhd`:
```vhdl
generic (
    clk_FREQ : integer := 125_000_000  -- Set your FPGA clock frequency
);
constant BAUD_RATE : integer := 115200; -- Change baud rate here
```

## License 📄

MIT License - Free for personal and commercial use. See LICENSE for details.
