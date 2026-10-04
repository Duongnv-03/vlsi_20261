# ==============================================================================
# OpenLane Configuration for Viterbi Decoder
# Target PDK: SKY130
# ==============================================================================

# --- Design Information ---
set ::env(DESIGN_NAME) "system_top"

# --- Verilog Source Files ---
set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]

# --- Clock Configuration ---
set ::env(CLOCK_PORT) "clk"
set ::env(CLOCK_PERIOD) "20.0"
# 20ns = 50MHz clock frequency

# --- Timing Constraints ---
set ::env(BASE_SDC_FILE) "$::env(DESIGN_DIR)/constraints.sdc"

# --- Floorplanning ---
set ::env(FP_CORE_UTIL) 40
# Target core utilization 40% (conservative for first run)

set ::env(FP_SIZING) "absolute"
set ::env(DIE_AREA) "0 0 400 400"
# Die area 400um x 400um (adjust based on synthesis report)

# --- Placement ---
set ::env(PL_TARGET_DENSITY) 0.45
# Placement density slightly higher than core util

# --- Routing ---
set ::env(ROUTING_CORES) 4
# Use 4 CPU cores for routing (adjust based on your system)

# --- Synthesis ---
set ::env(SYNTH_STRATEGY) "AREA 0"
# Optimize for area (options: AREA 0-3, DELAY 0-4)

set ::env(SYNTH_MAX_FANOUT) 10
# Maximum fanout for synthesis

# --- Diode Insertion (Antenna Fix) ---
set ::env(DIODE_INSERTION_STRATEGY) 4
# Strategy 4: Insert diodes during detailed routing

# --- DRC/LVS ---
set ::env(RUN_MAGIC_DRC) 1
set ::env(RUN_LVS) 1

# --- Output ---
set ::env(TAKE_LAYOUT_SCROT) 0
# Take screenshots of final layout
