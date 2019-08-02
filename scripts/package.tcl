##############################################################################
#  Copyright (c) 2019 by Paul Scherrer Institute, Switzerland
#  All rights reserved.
#  Authors: Oliver Bruendler
##############################################################################

###############################################################
# Include PSI packaging commands
###############################################################
source ../../../TCL/PsiIpPackage/PsiIpPackage.tcl
namespace import -force psi::ip_package::latest::*

###############################################################
# General Information
###############################################################
set IP_NAME axis_data_gen
set IP_VERSION 1.2
set IP_REVISION "auto"
set IP_LIBRARY PSI
set IP_DESCIRPTION "AXI-S data generator (counter based, with trigger capability)"

init $IP_NAME $IP_VERSION $IP_REVISION $IP_LIBRARY
set_description $IP_DESCIRPTION
set_logo_relative "../doc/psi_logo_150.gif"
set_datasheet_relative "../doc/$IP_NAME.pdf"

###############################################################
# Add Source Files
###############################################################

#Relative Source Files
add_sources_relative { \
	../hdl/axis_data_gen_reg_pkg.vhd \
	../hdl/psi_common_status_cc_data2reg.vhd \
	../hdl/psi_common_status_cc_reg2data.vhd \
	../hdl/axis_data_gen.vhd \
	../hdl/axis_data_gen_vivado_wrp.vhd \
}

#Relative Library Files
add_lib_relative \
	"../../.."	\
	{ \
		VHDL/psi_common/hdl/psi_common_array_pkg.vhd \
		VHDL/psi_common/hdl/psi_common_math_pkg.vhd \
		VHDL/psi_common/hdl/psi_common_logic_pkg.vhd \
		VHDL/psi_common/hdl/psi_common_pulse_cc.vhd \
		VHDL/psi_common/hdl/psi_common_simple_cc.vhd \
		VHDL/psi_common/hdl/psi_common_status_cc.vhd \
		VHDL/psi_common/hdl/psi_common_pl_stage.vhd \
		VHDL/psi_common/hdl/psi_common_axi_slave_ipif.vhd \
	}	
	
###############################################################
# Driver Files
###############################################################	

add_drivers_relative ../drivers/axis_data_gen { \
	src/axis_data_gen.c \
	src/axis_data_gen.h \
}
	

###############################################################
# GUI Parameters
###############################################################

#General Configuration
gui_add_page "General Configuration"

gui_create_parameter "DataWidth_g" "AXI-S Data Width"
gui_parameter_set_range 1 32
gui_add_parameter

gui_create_parameter "UseAxiIf_g" "Implement AXI-MM Configuration Interface"
gui_parameter_set_widget_checkbox
gui_add_parameter	

gui_create_user_parameter "UseSingleCycleTrigger" bool true
gui_parameter_set_widget_checkbox
gui_add_parameter	

gui_create_user_parameter "UseTLast" bool true
gui_parameter_set_widget_checkbox
gui_add_parameter	

#Reset Values
gui_add_page "Reset Values"

gui_create_parameter "RstUseRdy_g" "Throttle data if TREADY is low (otherwise TREADY is ignored)"
gui_parameter_set_widget_checkbox
gui_add_parameter	

gui_create_parameter "RstCounterWrp_g" "Last value before wrapping TDATA counter back to zero"
gui_add_parameter	

gui_create_parameter "RstDataSpacing_g" "Idle cycles between two TVALID assertions"
gui_add_parameter	

gui_create_parameter "RstTrigSpacing_g" "AXI-S transactions between two triggers"
gui_add_parameter	

gui_create_parameter "RstTrigOffs_g" "Start generating triggers at this TDATA counter vlaue"
gui_add_parameter

gui_create_parameter "RstEna_g" "Start generating data immediately after reset"
gui_parameter_set_widget_checkbox
gui_add_parameter

###############################################################
# Interfaces
###############################################################
set_interface_clock Axis Data_Clk


###############################################################
# Optional Ports
###############################################################

add_port_enablement_condition "s00_axi_*" "\$UseAxiIf_g"
add_port_enablement_condition "s00_axi_aclk" "\$UseAxiIf_g"
add_port_enablement_condition "Trig" "\$UseSingleCycleTrigger"
add_port_enablement_condition "Axis_TLast" "\$UseTLast"
add_interface_enablement_condition "s00_axi" "\$UseAxiIf_g"



###############################################################
# Package Core
###############################################################
set TargetDir ".."
#											Edit  Synth	Part
package_ip $TargetDir 						false  true	xczu9eg-ffvb1156-2-e




