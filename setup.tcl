# ==========================================
# Async FIFO Vivado Project + Simulation
# with Waveform Auto Load
# ==========================================

# Get script directory
set script_dir [file dirname [info script]]

set proj_name fifo_project
set proj_dir  "$script_dir/project"

# Paths
set rtl_path "$script_dir/code/src"
set sim_path "$script_dir/code/sim"
set wave_path "$script_dir/code/sim/waves"

# Create project
create_project $proj_name $proj_dir -force

# Import RTL
set rtl_files [glob -nocomplain "$rtl_path/*.v"]
import_files -fileset sources_1 $rtl_files

# Import simulation files
set sim_files [glob -nocomplain "$sim_path/*.v"]
import_files -fileset sim_1 $sim_files

# Set simulation top
set_property top async_fifo_tb [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

save_project

puts "Project created."

# Launch simulation
launch_simulation

# Load waveform if exists
set wave_files [glob -nocomplain "$wave_path/*.wcfg"]

if {[llength $wave_files] > 0} {
    open_wave_config [lindex $wave_files 0]
    puts "Waveform loaded: [lindex $wave_files 0]"
} else {
    puts "No waveform file found in $wave_path"
}

puts "Simulation ready."

start_gui
