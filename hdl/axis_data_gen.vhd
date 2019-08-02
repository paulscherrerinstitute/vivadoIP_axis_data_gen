------------------------------------------------------------------------------
--  Copyright (c) 2019 by Paul Scherrer Institute, Switzerland
--  All rights reserved.
--  Authors: Oliver Bruendler
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Libraries
------------------------------------------------------------------------------

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	
library work;
	use work.psi_common_array_pkg.all;
	use work.psi_common_math_pkg.all;
	use work.axis_data_gen_reg_pkg.all;

------------------------------------------------------------------------------
-- Entity
------------------------------------------------------------------------------	
entity axis_data_gen is
	generic
	(
		-- Component Parameters			
		DataWidth_g					: positive				:= 16;
		UseRegCc_g					: boolean				:= true
	);
	port
	(
		-- Control Signals
		ClkData						: in 	std_logic;
		RstData						: in 	std_logic;
		ClkReg						: in 	std_logic;
		RstReg						: in 	std_logic;
			
		-- Register Inputs	
		InReg_UseRdy				: in 	std_logic;
		InReg_Ena					: in 	std_logic;
		InReg_CounterWrp			: in 	std_logic_vector(31 downto 0);
		InReg_DataSpacing			: in	std_logic_vector(15 downto 0);	
		InReg_TrigSpacing			: in 	std_logic_vector(31 downto 0);
		InReg_TrigOffs				: in 	std_logic_vector(31 downto 0);
		InReg_TrigSporadic			: in	std_logic;
		InReg_TrigCount				: in	std_logic_vector(31 downto 0);
		InReg_ClrRdyWasLow			: in	std_logic;
		InReg_StartTrigSporadic		: in	std_logic;
		
		-- Register Outputs
		OutReg_CurrentCnt			: out	std_logic_vector(31 downto 0);
		OutReg_TrigLeft				: out	std_logic_vector(31 downto 0);
		OutReg_RdyWasLow			: out	std_logic;
		
		-- AXI-S Interface
		Axis_TData					: out	std_logic_vector(DataWidth_g-1 downto 0);
		Axis_TReady					: in	std_logic;
		Axis_TValid					: out	std_logic;
		Axis_TLast					: out	std_logic;
		
		-- Trigger (single cycle)
		Trig						: out	std_logic
	);

end entity;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture rtl of axis_data_gen is 


	-- Two Process Method
	type two_process_r is record	
		DataCounter			: std_logic_vector(31 downto 0);
		RdyWasLow			: std_logic;
		TrigLeft			: std_logic_vector(31 downto 0);
		First				: std_logic;
		DataSpacingCnt		: std_logic_vector(15 downto 0);
		TrigSpacCnt			: std_logic_vector(31 downto 0);
		Vld					: std_logic;
		TrigOffsMin1		: std_logic_vector(31 downto 0);
		TrigOn				: std_logic;
		TrigSpl				: std_logic;
		TrigSuppress		: std_logic;
	end record;	
	signal r, r_next : two_process_r;
	
	signal Int_Rst					: std_logic;
	signal Int_UseRdy				: std_logic;
	signal Int_Ena					: std_logic;
	signal Int_CounterWrp			: std_logic_vector(31 downto 0);
	signal Int_DataSpacing			: std_logic_vector(15 downto 0);
	signal Int_TrigSpacing			: std_logic_vector(31 downto 0);
	signal Int_TrigOffs				: std_logic_vector(31 downto 0);
	signal Int_TrigSporadic			: std_logic;
	signal Int_TrigCount			: std_logic_vector(31 downto 0);
	signal Int_ClrRdyWasLow			: std_logic;
	signal Int_StartTrigSporadic	: std_logic;

begin

	--------------------------------------------------------------------------
	-- Combinatorial Process
	--------------------------------------------------------------------------
	p_comb : process(	r, Int_Rst, Int_UseRdy, Int_Ena, Int_CounterWrp, Int_TrigSpacing, Int_TrigOffs, Int_TrigSporadic, Int_TrigCount, Int_ClrRdyWasLow, Int_StartTrigSporadic, Int_DataSpacing,
						Axis_TReady)	
		variable v : two_process_r;
		variable IsRdy_v		: boolean;
		variable TrigPulse_v	: boolean;
		variable AxiTrans_v		: boolean;
	begin
		-- *** hold variables stable ***
		v := r;
		
		-- *** Simplification Variables ***
		IsRdy_v			:= (Axis_TReady = '1') or (Int_UseRdy = '0');
		AxiTrans_v		:= (r.Vld = '1') and IsRdy_v;
		TrigPulse_v		:= (r.TrigSpl = '1') and AxiTrans_v; 
		
		
		-- *** Generate Data ***
		if Int_Ena = '1' then
			-- Handle first sample
			if r.First = '1' then
				v.DataSpacingCnt	:= (others => '0');
				v.DataCounter		:= (others => '0');
				v.Vld				:= '1';
				v.First				:= '0';
			-- Handle other samples
			else
				-- Clear Vld after transaction and update data
				if AxiTrans_v then
					v.Vld	:= '0';
					if unsigned(r.DataCounter) = unsigned(Int_CounterWrp) then	
						v.DataCounter	:= (others => '0');
					else
						v.DataCounter		:= std_logic_vector(unsigned(r.DataCounter) + 1);
					end if;
				end if;
				
				-- Data Spacing
				if unsigned(r.DataSpacingCnt) = unsigned(Int_DataSpacing) then
					v.Vld				:= '1';
					v.DataSpacingCnt	:= (others => '0');	
				else
					v.DataSpacingCnt	:= std_logic_vector(unsigned(r.DataSpacingCnt) + 1);
				end if;
				
			end if;
		end if;
		
		-- *** Generate Trigger ***
		-- Calculate sample before asserting trigger
		v.TrigOffsMin1	:= std_logic_vector(unsigned(Int_TrigOffs)-1);
		
		-- Generate
		if Int_Ena = '1' then
			-- Wait for offset until generating trigger
			if r.TrigOn = '0' then
				if unsigned(Int_TrigOffs) = 0 then
					v.TrigSpl	:= '1';
					v.TrigOn	:= '1';
				elsif (unsigned(r.DataCounter) = unsigned(r.TrigOffsMin1)) and AxiTrans_v then
					v.TrigSpl	:= '1';
					v.TrigOn	:= '1';					
				end if;
			-- Generate trigger periodic
			else
				-- Clear Trigger if sent
				if TrigPulse_v then
					v.TrigSpl	:= '0';
				end if;
				
				-- Set new trigger event
				if AxiTrans_v then
					if unsigned(r.TrigSpacCnt) = unsigned(Int_TrigSpacing) then
						v.TrigSpl		:= '1';
						v.TrigSpacCnt	:= (others => '0');
					else
						v.TrigSpacCnt	:= std_logic_vector(unsigned(r.TrigSpacCnt)+1);
					end if;
				end if;
			end if;
		end if;
		
		-- Handle sporadic triggering
		-- continuous
		if Int_TrigSporadic = '0' then
			v.TrigSuppress	:= '0';
		-- start sporadic
		elsif Int_StartTrigSporadic = '1' then
			if unsigned(Int_TrigCount) /= 0 then
				v.TrigSuppress	:= '0';
			else
				v.TrigSuppress	:= '1';
			end if;
			v.TrigLeft		:= Int_TrigCount;
		-- no triggers left
		elsif unsigned(r.TrigLeft) = 0 then
			v.TrigSuppress	:= '1';
		-- do sporadic
		elsif (r.TrigSuppress = '0') and (Int_Ena = '1') then
			if TrigPulse_v then
				v.TrigLeft	:= std_logic_vector(unsigned(r.TrigLeft)-1);
				if unsigned(r.TrigLeft) = 1 then
					v.TrigSuppress := '1';
				end if;
			end if;
		end if;
		-- 
		
		-- *** Ready Low Latching ***
		if Int_ClrRdyWasLow = '1' then
			v.RdyWasLow	:= '0';
		elsif (r.Vld = '1') and (Axis_TReady = '0') and (Int_Ena = '1') then
			v.RdyWasLow	:= '1';
		end if;	
		
		
		-- *** Disabled Case ***
		if Int_Ena = '0' then
			v.First			:= '1';
			v.TrigSpacCnt	:= (others => '0');
			v.TrigOn		:= '0';
			v.TrigSpl		:= '0';
			v.Vld			:= '0';
		end if;
		
		-- *** Outputs ***
		Axis_TData 	<= r.DataCounter(DataWidth_g-1 downto 0);
		Axis_TValid	<= r.Vld;
		Axis_TLast	<= r.TrigSpl and not r.TrigSuppress;
		if TrigPulse_v and (r.TrigSuppress = '0') then
			Trig		<= '1';
		else
			Trig		<= '0';
		end if;
		
		
		-- *** Apply to record ***
		r_next <= v;
		
	end process;
	
	
	--------------------------------------------------------------------------
	-- Sequential Process
	--------------------------------------------------------------------------	
	p_seq : process(ClkData)
	begin	
		if rising_edge(ClkData) then
			r <= r_next;
			if Int_Rst = '1' then
				r.First			<= '1';
				r.Vld			<= '0';
				r.TrigOn		<= '0';
				r.RdyWasLow		<= '0';
				r.TrigLeft		<= (others => '0');
				r.TrigSpacCnt	<= (others => '0');
				r.TrigSpl		<= '0';
			end if;
		end if;
	end process;
	
	--------------------------------------------------------------------------
	-- Component Instantiation
	--------------------------------------------------------------------------	
	g_regcc : if UseRegCc_g generate
		i_cc_reg2data_status : entity work.psi_common_status_cc_reg2data
			port map  (
				-- Clock Domain A
				ClkA				=> ClkReg,
				RstInA				=> RstReg,
				CounterWrpA     	=> InReg_CounterWrp,
				DataSpacingA		=> InReg_DataSpacing,
				EnaA(0)         	=> InReg_Ena,
				TrigCountA      	=> InReg_TrigCount,
				TrigOffsA       	=> InReg_TrigOffs,
				TrigSpacingA    	=> InReg_TrigSpacing,
				TrigSporadicA(0)	=> InReg_TrigSporadic,
				UseRdyA(0)			=> InReg_UseRdy,		
				-- Clock Domain B
				ClkB				=> ClkData,
				RstInB				=> RstData,
				CounterWrpB    		=> Int_CounterWrp,
				DataSpacingB		=> Int_DataSpacing,
				EnaB(0)            	=> Int_Ena,
				TrigCountB      	=> Int_TrigCount,
				TrigOffsB       	=> Int_TrigOffs,
				TrigSpacingB   		=> Int_TrigSpacing,
				TrigSporadicB(0)   	=> Int_TrigSporadic,
				UseRdyB(0)        	=> Int_UseRdy,
				RstOutB				=> Int_Rst
			);
			
		i_cc_reg2data_pulse : entity work.psi_common_pulse_cc
			generic map (
				NumPulses_g		=> 2
			)
			port map (
				-- Clock Domain A
				ClkA		=> ClkReg,
				RstInA		=> RstReg,
				PulseA(0)	=> InReg_ClrRdyWasLow,
				PulseA(1)	=> InReg_StartTrigSporadic,			
				-- Clock Domain B
				ClkB		=> ClkData,
				RstInB		=> RstData,
				PulseB(0)	=> Int_ClrRdyWasLow,
				PulseB(1)	=> Int_StartTrigSporadic
			);
			
		i_cc_data2reg_status : entity work.psi_common_status_cc_data2reg
			port map (
				-- Clock Domain A
				ClkA			=> ClkData,
				RstInA			=> RstData,
				CurrentCntA     => r.DataCounter,
				RdyWasLowA(0)   => r.RdyWasLow,
				TrigLeftA       => r.TrigLeft,			
				-- Clock Domain B
				ClkB			=> ClkReg,
				RstInB			=> RstReg,
				CurrentCntB     => OutReg_CurrentCnt,
				RdyWasLowB(0)   => OutReg_RdyWasLow,
				TrigLeftB       => OutReg_TrigLeft
			);
		end generate;
		
		-- Implementation without clock crossings
		g_nregcc : if not UseRegCc_g generate
			Int_CounterWrp			<= InReg_CounterWrp;
			Int_DataSpacing			<= InReg_DataSpacing;
			Int_Ena					<= InReg_Ena;
			Int_TrigCount			<= InReg_TrigCount;
			Int_TrigOffs			<= InReg_TrigOffs;
			Int_TrigSpacing			<= InReg_TrigSpacing;
			Int_TrigSporadic		<= InReg_TrigSporadic;
			Int_UseRdy				<= InReg_UseRdy;
			Int_ClrRdyWasLow		<= InReg_ClrRdyWasLow;
			Int_StartTrigSporadic	<= InReg_StartTrigSporadic;
			OutReg_CurrentCnt		<= r.DataCounter;
			OutReg_RdyWasLow		<= r.RdyWasLow;
			OutReg_TrigLeft			<= r.TrigLeft;
			Int_Rst					<= RstData;
		end generate;
	
 
end rtl;
