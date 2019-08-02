# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set General_Configuration [ipgui::add_page $IPINST -name "General Configuration"]
  ipgui::add_param $IPINST -name "DataWidth_g" -parent ${General_Configuration}
  ipgui::add_param $IPINST -name "UseAxiIf_g" -parent ${General_Configuration}
  ipgui::add_param $IPINST -name "UseSingleCycleTrigger" -parent ${General_Configuration}
  ipgui::add_param $IPINST -name "UseTLast" -parent ${General_Configuration}

  #Adding Page
  set Reset_Values [ipgui::add_page $IPINST -name "Reset Values"]
  ipgui::add_param $IPINST -name "RstUseRdy_g" -parent ${Reset_Values}
  ipgui::add_param $IPINST -name "RstCounterWrp_g" -parent ${Reset_Values}
  ipgui::add_param $IPINST -name "RstDataSpacing_g" -parent ${Reset_Values}
  ipgui::add_param $IPINST -name "RstTrigSpacing_g" -parent ${Reset_Values}
  ipgui::add_param $IPINST -name "RstTrigOffs_g" -parent ${Reset_Values}
  ipgui::add_param $IPINST -name "RstEna_g" -parent ${Reset_Values}


}

proc update_PARAM_VALUE.C_S00_AXI_ID_WIDTH { PARAM_VALUE.C_S00_AXI_ID_WIDTH } {
	# Procedure called to update C_S00_AXI_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ID_WIDTH { PARAM_VALUE.C_S00_AXI_ID_WIDTH } {
	# Procedure called to validate C_S00_AXI_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.DataWidth_g { PARAM_VALUE.DataWidth_g } {
	# Procedure called to update DataWidth_g when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DataWidth_g { PARAM_VALUE.DataWidth_g } {
	# Procedure called to validate DataWidth_g
	return true
}

proc update_PARAM_VALUE.RstCounterWrp_g { PARAM_VALUE.RstCounterWrp_g } {
	# Procedure called to update RstCounterWrp_g when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RstCounterWrp_g { PARAM_VALUE.RstCounterWrp_g } {
	# Procedure called to validate RstCounterWrp_g
	return true
}

proc update_PARAM_VALUE.RstDataSpacing_g { PARAM_VALUE.RstDataSpacing_g } {
	# Procedure called to update RstDataSpacing_g when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RstDataSpacing_g { PARAM_VALUE.RstDataSpacing_g } {
	# Procedure called to validate RstDataSpacing_g
	return true
}

proc update_PARAM_VALUE.RstEna_g { PARAM_VALUE.RstEna_g } {
	# Procedure called to update RstEna_g when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RstEna_g { PARAM_VALUE.RstEna_g } {
	# Procedure called to validate RstEna_g
	return true
}

proc update_PARAM_VALUE.RstTrigOffs_g { PARAM_VALUE.RstTrigOffs_g } {
	# Procedure called to update RstTrigOffs_g when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RstTrigOffs_g { PARAM_VALUE.RstTrigOffs_g } {
	# Procedure called to validate RstTrigOffs_g
	return true
}

proc update_PARAM_VALUE.RstTrigSpacing_g { PARAM_VALUE.RstTrigSpacing_g } {
	# Procedure called to update RstTrigSpacing_g when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RstTrigSpacing_g { PARAM_VALUE.RstTrigSpacing_g } {
	# Procedure called to validate RstTrigSpacing_g
	return true
}

proc update_PARAM_VALUE.RstUseRdy_g { PARAM_VALUE.RstUseRdy_g } {
	# Procedure called to update RstUseRdy_g when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RstUseRdy_g { PARAM_VALUE.RstUseRdy_g } {
	# Procedure called to validate RstUseRdy_g
	return true
}

proc update_PARAM_VALUE.UseAxiIf_g { PARAM_VALUE.UseAxiIf_g } {
	# Procedure called to update UseAxiIf_g when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UseAxiIf_g { PARAM_VALUE.UseAxiIf_g } {
	# Procedure called to validate UseAxiIf_g
	return true
}

proc update_PARAM_VALUE.UseSingleCycleTrigger { PARAM_VALUE.UseSingleCycleTrigger } {
	# Procedure called to update UseSingleCycleTrigger when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UseSingleCycleTrigger { PARAM_VALUE.UseSingleCycleTrigger } {
	# Procedure called to validate UseSingleCycleTrigger
	return true
}

proc update_PARAM_VALUE.UseTLast { PARAM_VALUE.UseTLast } {
	# Procedure called to update UseTLast when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.UseTLast { PARAM_VALUE.UseTLast } {
	# Procedure called to validate UseTLast
	return true
}


proc update_MODELPARAM_VALUE.DataWidth_g { MODELPARAM_VALUE.DataWidth_g PARAM_VALUE.DataWidth_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DataWidth_g}] ${MODELPARAM_VALUE.DataWidth_g}
}

proc update_MODELPARAM_VALUE.RstUseRdy_g { MODELPARAM_VALUE.RstUseRdy_g PARAM_VALUE.RstUseRdy_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RstUseRdy_g}] ${MODELPARAM_VALUE.RstUseRdy_g}
}

proc update_MODELPARAM_VALUE.RstCounterWrp_g { MODELPARAM_VALUE.RstCounterWrp_g PARAM_VALUE.RstCounterWrp_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RstCounterWrp_g}] ${MODELPARAM_VALUE.RstCounterWrp_g}
}

proc update_MODELPARAM_VALUE.RstDataSpacing_g { MODELPARAM_VALUE.RstDataSpacing_g PARAM_VALUE.RstDataSpacing_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RstDataSpacing_g}] ${MODELPARAM_VALUE.RstDataSpacing_g}
}

proc update_MODELPARAM_VALUE.RstTrigSpacing_g { MODELPARAM_VALUE.RstTrigSpacing_g PARAM_VALUE.RstTrigSpacing_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RstTrigSpacing_g}] ${MODELPARAM_VALUE.RstTrigSpacing_g}
}

proc update_MODELPARAM_VALUE.RstTrigOffs_g { MODELPARAM_VALUE.RstTrigOffs_g PARAM_VALUE.RstTrigOffs_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RstTrigOffs_g}] ${MODELPARAM_VALUE.RstTrigOffs_g}
}

proc update_MODELPARAM_VALUE.RstEna_g { MODELPARAM_VALUE.RstEna_g PARAM_VALUE.RstEna_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RstEna_g}] ${MODELPARAM_VALUE.RstEna_g}
}

proc update_MODELPARAM_VALUE.UseAxiIf_g { MODELPARAM_VALUE.UseAxiIf_g PARAM_VALUE.UseAxiIf_g } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.UseAxiIf_g}] ${MODELPARAM_VALUE.UseAxiIf_g}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ID_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ID_WIDTH PARAM_VALUE.C_S00_AXI_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ID_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ID_WIDTH}
}

