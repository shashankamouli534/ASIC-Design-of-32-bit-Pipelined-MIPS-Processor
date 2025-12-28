 ASIC Design of 32-bit Pipelined MIPS Processor

This project implements a **32-bit 5-stage pipelined MIPS processor** and takes it all the way through the ASIC flow using the SkyWater 130nm (Sky130) PDK.  
The design supports forwarding, hazard detection, stalls, load/use handling, and basic memory support.  
The flow is completed from RTL → Synthesis → PnR → STA → GDS → Gate-Level Simulation with SDF.

 Architecture

Standard **5-Stage Pipeline**
- IF → Instruction Fetch  
- ID → Decode & Register Read  
- EX → ALU / Execution  
- MEM → Memory Access  
- WB → Write Back  

Additional logic:
- Hazard Detection Unit  
- Forwarding Unit  
- Pipeline Registers  
- Register File  
- Instruction & Data Memory (simulation)



 ASIC Flow Results (OpenLane + Sky130)

**Clock Period:** 10 ns  
**Timing Status:** MET

| Metric | Result |
|--------|--------|
| Worst Setup Slack | **+0.96 ns** |
| Worst Hold Slack | **+0.33 ns** |
| TNS | **0** |
| Core Area | ~0.64 mm² |
| Utilization | ~35% |

---

 Power (Typical Corner)

| Type | Power |
|------|--------|
| Internal | ~4.16 mW |
| Switching | ~5.96 mW |
| Total | **~10 mW** |

---

 Gate-Level Simulation (GLS)

Performed with:
- Post-layout netlist
- SDF back-annotation
- Sky130 standard cells



Waveform verified in GTKWave.

---

 Physical Layout

Generated files:
- `cpu_top.gds` → Final tape-out ready layout
- `cpu_top.mag` → Magic view
- `cpu_top.lef`

Screenshots are included in the repo.

Open in Magic:
magic -T sky130A.tech cpu_top.mag

Open in KLayout:
klayout cpu_top.gds

 Re-Run Instructions

### OpenLane

flow.tcl -design mips_cpu

iverilog -g2012 -o gls_sim \
  -DFUNCTIONAL -DUSE_POWER_PINS -DGLS -DUNIT_DELAY=#1 \
  cpu_top.v tb_cpu.v \
  path/to/sky130_fd_sc_hd/primitives.v \
  path/to/sky130_fd_sc_hd.v

vvp gls_sim
gtkwave gls.vcd

 Tools Used

* OpenLane / OpenROAD
* Yosys + ABC
* Magic
* KLayout
* Netgen
* Icarus Verilog
* GTKWave
* SkyWater 130nm PDK


 Summary

This project demonstrates a complete, timing-clean ASIC implementation of a pipelined MIPS processor on Sky130, verified at RTL and post-layout levels with functional GLS and physical layout completion.

