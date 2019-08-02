/*############################################################################
#  Copyright (c) 2019 by Paul Scherrer Institute, Switzerland
#  All rights reserved.
#  Authors: Oliver Bruendler
############################################################################*/

#include "axis_data_gen.h"
#include <xil_io.h>

//*******************************************************************************
// Private Functions
//*******************************************************************************
uint32_t AxisDataGen_ReadReg(	AxisDataGen_Inst_t* const inst_p,
								const uint32_t addr)
{
	return Xil_In32(inst_p->baseAddr + addr);
}

void AxisDataGen_WriteReg(	AxisDataGen_Inst_t* const inst_p,
							const uint32_t addr,
							const uint32_t data)
{
	Xil_Out32(inst_p->baseAddr + addr, data);						
}

//*******************************************************************************
// Public Functions
//*******************************************************************************
AxisDataGen_RetCode_t AxisDataGen_Init(	AxisDataGen_Inst_t* const inst_p,
										const uint32_t baseAddr)
{
	inst_p->baseAddr = baseAddr;
	//Read values from registers because the reset value can be configures in Vivado
	if (AxisDataGen_ReadReg(inst_p, AXIS_DATA_GEN_REG_TRIG_SPOR_EN)) {
		inst_p->mode = AxisDataGen_Mode_Sporadic;
	}
	else {
		inst_p->mode = AxisDataGen_Mode_Continuous;
	}
	//Clear Rdy-Latch
	AxisDataGen_WriteReg(inst_p, AXIS_DATA_GEN_REG_TRIG_RDYLO, 1);
	//Done
	return AxisDataGen_RetCode_Success;
}

AxisDataGen_RetCode_t AxisDataGen_ConfigurePattern(	AxisDataGen_Inst_t* const inst_p,
													const uint32_t dataWrappingPoint,
													const uint16_t dataSpacing,
													const uint32_t trigOffset,
													const uint32_t trigSpacing,
													const bool useRdy,
													const bool sporadicTrigger)
{
	//Checks
	if (AxisDataGen_ReadReg(inst_p, AXIS_DATA_GEN_REG_CFG_ENA)) {
		return AxisDataGen_RetCode_NotAllowedIfEnabled;
	}
	//Implementation
	AxisDataGen_WriteReg(inst_p, AXIS_DATA_GEN_REG_DATA_WRP, dataWrappingPoint-1);
	AxisDataGen_WriteReg(inst_p, AXIS_DATA_GEN_REG_DATA_SPAC, dataSpacing);
	AxisDataGen_WriteReg(inst_p, AXIS_DATA_GEN_REG_TRIG_OFFS, trigOffset);
	AxisDataGen_WriteReg(inst_p, AXIS_DATA_GEN_REG_TRIG_SPAC, trigSpacing);
	AxisDataGen_WriteReg(inst_p, AXIS_DATA_GEN_REG_CFG_USERDY, useRdy ? 1 : 0);
	AxisDataGen_WriteReg(inst_p, AXIS_DATA_GEN_REG_TRIG_SPOR_EN, sporadicTrigger ? 1 : 0);
	if (sporadicTrigger) {
		inst_p->mode = AxisDataGen_Mode_Sporadic;
	}
	else {
		inst_p->mode = AxisDataGen_Mode_Continuous;
	}
	//Done
	return AxisDataGen_RetCode_Success;	
}

AxisDataGen_RetCode_t AxisDataGen_Enable(	AxisDataGen_Inst_t* const inst_p)
{
	//Implementation
	AxisDataGen_WriteReg(inst_p, AXIS_DATA_GEN_REG_CFG_ENA, 1);
	//Done
	return AxisDataGen_RetCode_Success;
}

AxisDataGen_RetCode_t AxisDataGen_Disable(	AxisDataGen_Inst_t* const inst_p)
{
	//Implementation
	AxisDataGen_WriteReg(inst_p, AXIS_DATA_GEN_REG_CFG_ENA, 0);
	//Clear remaining triggers
	AxisDataGen_WriteReg(inst_p, AXIS_DATA_GEN_REG_TRIG_SPOR_CNT, 0);
	__sync_synchronize(); //Ensure trigger count is written before LD is set
	AxisDataGen_WriteReg(inst_p, AXIS_DATA_GEN_REG_TRIG_SPOR_LD, 1);
	//Done
	return AxisDataGen_RetCode_Success;	
}

AxisDataGen_RetCode_t AxisDataGen_SendSporadicTriggers(	AxisDataGen_Inst_t* const inst_p,
														const uint32_t triggerCount)
{
	//Checks
	if (0 != AxisDataGen_ReadReg(inst_p, AXIS_DATA_GEN_REG_STAT_TRIGLEFT)) {
		return AxisDataGen_RetCode_TriggerFromLastCommandLeft;
	}
	if (AxisDataGen_Mode_Sporadic != inst_p->mode) {
		return AxisDataGen_RetCode_NotInSporadicMode;
	}
	//Implementation
	AxisDataGen_WriteReg(inst_p, AXIS_DATA_GEN_REG_TRIG_SPOR_CNT, triggerCount);
	__sync_synchronize(); //Ensure trigger count is written before LD is set
	AxisDataGen_WriteReg(inst_p, AXIS_DATA_GEN_REG_TRIG_SPOR_LD, 1);
	//Done
	return AxisDataGen_RetCode_Success;		
}

AxisDataGen_RetCode_t AxisDataGen_WasRdyLow(AxisDataGen_Inst_t* const inst_p,
											bool* const rdyLow_p)
{
	//Implementation
	*rdyLow_p = (0 != AxisDataGen_ReadReg(inst_p, AXIS_DATA_GEN_REG_TRIG_RDYLO));
	//Done
	return AxisDataGen_RetCode_Success;													
}

AxisDataGen_RetCode_t AxisDataGen_ClrRdyLow(AxisDataGen_Inst_t* const inst_p)
{
	//Implementation
	AxisDataGen_WriteReg(inst_p, AXIS_DATA_GEN_REG_TRIG_RDYLO, 1);
	//Done
	return AxisDataGen_RetCode_Success;	
}
										


