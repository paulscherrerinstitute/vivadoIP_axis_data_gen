/*############################################################################
#  Copyright (c) 2019 by Paul Scherrer Institute, Switzerland
#  All rights reserved.
#  Authors: Oliver Bruendler
############################################################################*/

#pragma once

//*******************************************************************************
// Includes
//*******************************************************************************
#include <stdint.h>
#include <stdbool.h>

//*******************************************************************************
// Constants
//*******************************************************************************

/// @cond
#define AXIS_DATA_GEN_REG_CFG_ENA			0x00
#define AXIS_DATA_GEN_REG_CFG_USERDY		0x04
#define AXIS_DATA_GEN_REG_DATA_WRP			0x10
#define AXIS_DATA_GEN_REG_DATA_SPAC			0x14
#define AXIS_DATA_GEN_REG_TRIG_OFFS			0x20
#define AXIS_DATA_GEN_REG_TRIG_SPAC			0x24
#define AXIS_DATA_GEN_REG_TRIG_SPOR_EN		0x28
#define AXIS_DATA_GEN_REG_TRIG_SPOR_LD		0x2C
#define AXIS_DATA_GEN_REG_TRIG_SPOR_CNT		0x30
#define AXIS_DATA_GEN_REG_TRIG_RDYLO		0x40
#define AXIS_DATA_GEN_REG_STAT_DATACNT		0x50
#define AXIS_DATA_GEN_REG_STAT_TRIGLEFT		0x54
/// @endcond

//*******************************************************************************
// Types
//*******************************************************************************

/**
 * @brief	Data generator operation mode
*/
typedef enum {
	AxisDataGen_Mode_Continuous,	///< Continuous Generation of Triggers
	AxisDataGen_Mode_Sporadic		///< Sporadic Generation of Triggers (only when requested)
} AxisDataGen_Mode_t;

/**
 * @brief	Internally userd data, not documented, do not change
*/
typedef struct {
	uint32_t baseAddr;
	AxisDataGen_Mode_t mode; 
} AxisDataGen_Inst_t;

/**
 * @brief	Return codes
*/
typedef enum {
	AxisDataGen_RetCode_Success	= 0,						///< Everything OK
	AxisDataGen_RetCode_NotAllowedIfEnabled = -1,			///< Operation not permitted if the IP is enabled
	AxisDataGen_RetCode_TriggerFromLastCommandLeft = -2,	///< Operation not permitted because triggers from the last command are not generated yet
	AxisDataGen_RetCode_NotInSporadicMode = -3,				///< Operation not permitted if not in sporadic mode
} AxisDataGen_RetCode_t;

//*******************************************************************************
// Functions
//*******************************************************************************

/**
* @brief 	Initialize AXI-S data generator driver for an instance
* 			Note that some settings can be made in vivado. For example the core can already be enabled after reset.
*			The initialization does not change this, so a core enabled after reset stays enabled during initialiation. 
*
* @param	inst_p		Pointer to the information struct for this instance of the driver
* @param 	baseAddr	Base address of the IP core to access
* @return	Return Code
*/
AxisDataGen_RetCode_t AxisDataGen_Init(	AxisDataGen_Inst_t* const inst_p,
										const uint32_t baseAddr);

/**
* @brief 	Configure data pattern to generate. This function is only allowed when the data generator is disabled.
*
* @param	inst_p				Pointer to the information struct for this instance of the driver
* @param 	dataWrappingPoint	The TDATA signal contains a counter wrapping at this point. Example: pass 4 to generate data [0, 1, 2, 3, 0, 1, 2, 3, 0, ...]
* @param	dataSpacing			Number of clock cycles between two samples (TVALID low cycles). Use 0 for continuous data generation.
* @param 	trigOffset			The first trigger is generated at the sample with this value.
* @param	trigSpacing			Number of samples between two trigger signals
* @param 	useRdy				True: for AXI-S with back-pressure. \n
*								False: TREADY is ignored
* @param	sporadicTrigger		True: Generate trigger sporadically (@see AxisDataGen_SendSporadicTriggers())
*								False: Generate trigger continuously (trigSpacing is still respected)
* @return	Return Code
*/
AxisDataGen_RetCode_t AxisDataGen_ConfigurePattern(	AxisDataGen_Inst_t* const inst_p,
													const uint32_t dataWrappingPoint,
													const uint16_t dataSpacing,
													const uint32_t trigOffset,
													const uint32_t trigSpacing,
													const bool useRdy,
													const bool sporadicTrigger);

/**
* @brief 	Enable data generator
*
* @param	inst_p		Pointer to the information struct for this instance of the driver
* @return	Return Code
*/
AxisDataGen_RetCode_t AxisDataGen_Enable(	AxisDataGen_Inst_t* const inst_p);

/**
* @brief 	Disable data generator
*
* @param	inst_p		Pointer to the information struct for this instance of the driver
* @return	Return Code
*/
AxisDataGen_RetCode_t AxisDataGen_Disable(	AxisDataGen_Inst_t* const inst_p);	

/**
* @brief 	Send a specified nuber of triggers in sporadic mode
*
* @param	inst_p			Pointer to the information struct for this instance of the driver
* @param	triggerCount	Number of triggers to send
* @return	Return Code
*/

AxisDataGen_RetCode_t AxisDataGen_SendSporadicTriggers(	AxisDataGen_Inst_t* const inst_p,
														const uint32_t triggerCount);

/**
* @brief 	Check if data stream was ever throttled by TREADY-Low 
*
* @param	inst_p			Pointer to the information struct for this instance of the driver
* @param	rdyLow_p		Pointer to write the result in (true = throttling occured)
* @return	Return Code
*/
AxisDataGen_RetCode_t AxisDataGen_WasRdyLow(AxisDataGen_Inst_t* const inst_p,
											bool* const rdyLow_p);

/**
* @brief 	Clear the flag that latches TREADY-Low condistion
*
* @param	inst_p			Pointer to the information struct for this instance of the driver
* @return	Return Code
*/
AxisDataGen_RetCode_t AxisDataGen_ClrRdyLow(AxisDataGen_Inst_t* const inst_p);									

