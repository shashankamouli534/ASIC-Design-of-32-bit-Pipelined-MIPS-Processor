set ::env(DESIGN_NAME) "cpu_top"

set ::env(VERILOG_FILES) "\
$::env(DESIGN_DIR)/src/cpu_top.v"

set ::env(SDC_FILE) "$::env(DESIGN_DIR)/constraints/cpu.sdc"

set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) 10



# ---------- FLOORPLAN ----------
set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 800 800"
set ::env(FP_CORE_UTIL) 35
set ::env(PL_TARGET_DENSITY) 0.55

set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 1
set ::env(ROUTING_OPT_ITERS) 2


# ---------- PDN ----------
set ::env(FP_PDN_CORE_RING) 0
set ::env(PDN_ENABLE_RAILS) 1
set ::env(PDN_HORIZONTAL_LAYER) "met4"
set ::env(PDN_VERTICAL_LAYER)   "met5"

set ::env(FP_PDN_VOFFSET)  10
set ::env(FP_PDN_HOFFSET)  10
set ::env(FP_PDN_VPITCH)   60
set ::env(FP_PDN_HPITCH)   60
set ::env(FP_PDN_VWIDTH)   1.6
set ::env(FP_PDN_HWIDTH)   1.6
