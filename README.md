**32-bit Pipelined MIPS Processor (ASIC-Oriented)**

This project implements a 5-stage pipelined 32-bit MIPS processor designed with ASIC implementation in mind.
The design follows a fully synchronous, STA-clean RTL style and is taken through synthesis and physical design.

**Features**

**5-stage pipeline: IF / ID / EX / MEM / WB**
Hazard detection and data forwarding
Branch handling in ID stage
Clean register file (async read, sync write)
Performance counters (cycles, instructions, branches)

**Verification**
Self-checking SystemVerilog testbench
Directed and random instruction tests
Assertions for protocol and pipeline safety

**ASIC Flow**
RTL → Synthesis → STA → Floorplan → Place & Route
SDC-based timing constraints
Area, timing, and power reports included

**Tools**
Verilog / SystemVerilog
Yosys (synthesis), OpenSTA
OpenLane / OpenROAD
