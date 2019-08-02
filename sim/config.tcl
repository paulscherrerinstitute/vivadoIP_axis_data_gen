##############################################################################
#  Copyright (c) 2019 by Paul Scherrer Institute, Switzerland
#  All rights reserved.
#  Authors: Oliver Bruendler
##############################################################################

#Constants
set LibPath "../../../VHDL"

#Import psi::sim
namespace import psi::sim::*

#Set library
add_library axis_data_gen

#suppress messages
compile_suppress 135,1236,1073,1246
run_suppress 8684,3479,3813,8009,3812

# Library
add_sources $LibPath {
	psi_tb/hdl/psi_tb_txt_util.vhd \
	psi_tb/hdl/psi_tb_compare_pkg.vhd \
	psi_tb/hdl/psi_tb_activity_pkg.vhd \
	psi_common/hdl/psi_common_array_pkg.vhd \
	psi_common/hdl/psi_common_math_pkg.vhd \
	psi_tb/hdl/psi_tb_axi_pkg.vhd \
	psi_common/hdl/psi_common_logic_pkg.vhd \
	psi_common/hdl/psi_common_pulse_cc.vhd \
	psi_common/hdl/psi_common_simple_cc.vhd \
	psi_common/hdl/psi_common_status_cc.vhd \
	psi_common/hdl/psi_common_pl_stage.vhd \
	psi_common/hdl/psi_common_axi_slave_ipif.vhd \
} -tag lib

# project sources
add_sources "../hdl" {
	axis_data_gen_reg_pkg.vhd \
	psi_common_status_cc_data2reg.vhd \
	psi_common_status_cc_reg2data.vhd \
	axis_data_gen.vhd \
	axis_data_gen_vivado_wrp.vhd \
} -tag src

# testbenches
add_sources "../testbench" {
	axis_data_gen_vivado_wrp_tb.vhd \
} -tag tb
	
#TB Runs
create_tb_run "axis_data_gen_vivado_wrp_tb"
tb_run_add_arguments \
	"-gRstUseRdy_g=true -gRstCounterWrp_g=15 -gRstDataSpacing_g=1 -gRstTrigSpacing_g=3 -gRstTrigOffs_g=2 -gRstEna_g=true -gUseAxiIf_g=false" \
	"-gRstEna_g=false -gUseAxiIf_g=true"
add_tb_run









