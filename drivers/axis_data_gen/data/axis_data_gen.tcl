

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" axis_data_gen "NUM_INSTANCES" "DEVICE_ID"  "C_BASEADDR" "C_HIGHADDR"
}
