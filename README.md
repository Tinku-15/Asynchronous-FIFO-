# Asynchronous-FIFO-
Dual-clock asynchronous FIFO in Verilog with CDC-safe Gray pointers, testbench, and Vivado auto-setup
# Dual Clock Asynchronous FIFO (Verilog)

This project implements an industry-style asynchronous FIFO that safely transfers data between two independent clock domains using Gray-coded pointers and CDC-safe synchronization.

The repository includes:

- FIFO RTL
- Self-checking testbench
- Waveform configuration
- Vivado auto-setup script

Everything is automated using `setup.tcl`.

---

## 📁 Project Structure

```
repo/
│
├── setup.tcl                 → auto project + simulation launcher
│
└── code/
    ├── src/                  → FIFO RTL
    │   └── async_fifo.v
    │
    └── sim/
        ├── async_fifo_tb.v   → testbench
        │
        └── wave/
            fifo_wave.wcfg    → waveform config (optional)
```

---

## ▶ How to Run the Project

From the repository root folder:

```bash
vivado -source setup.tcl
```

This will automatically:

- create a Vivado project
- import RTL and testbench
- launch behavioral simulation
- load waveform (if available)
- run simulation

No manual setup needed.

---

## ▶ Running Simulation Manually (inside Vivado)

If you want to rerun simulation:

```
Flow Navigator → Simulation → Run Behavioral Simulation
```

---

## 📊 Waveform

If waveform config exists:

```
code/sim/wave/fifo_wave.wcfg
```

Vivado loads it automatically.

To open manually:

```
File → Simulation Waveform → Open
```

Navigate to:

```
code/sim/wave/
```

Select `.wcfg` file.

If no waveform file is present:

Vivado automatically adds all signals.

---

## ⚙ Customization

You can change simulation length in:

```
code/sim/async_fifo_tb.v
```

Edit:

```verilog
parameter BEATS = 200;
```

Examples:

```
BEATS = 50     → short run
BEATS = 1000   → stress test
BEATS = 10000  → long streaming test
```

No other changes required.

---

## 🧠 Project Overview

This FIFO uses:

- dual clock domains
- Gray-coded pointers
- 2-flop synchronizers
- dual-port memory
- full / empty detection
- overflow / underflow protection

It is safe for FPGA and ASIC designs.

Only pointers cross clock domains — data remains in memory.

This architecture is used in real systems:

- Ethernet MACs
- DMA engines
- PCIe controllers
- streaming pipelines

---

## ✅ Expected Output

Console will print:

```
FIFO PASS — 200 beats verified
Simulation continues running...
```

Simulation continues so waveform can be inspected.

---
---

## 📐 Block Diagram & Simulation Screenshot

The repository also includes:

- Simulation waveform screenshot (5-beat example)

Files:

```
docs/
└── sim_5beats.png
```



The screenshot demonstrates a short 5-beat simulation run to visualize:

- write sequence
- read sequence
- FIFO latency
- data alignment

These files are for documentation and learning reference.

---


## ✨ Notes

- DEPTH must be power-of-2
- Works for any data width
- Fully synthesizable
- BRAM friendly
- CDC safe

---

Enjoy exploring async FIFOs!
