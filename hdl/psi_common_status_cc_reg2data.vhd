------------------------------------------------------------------------------
--  Copyright (c) 2019 by Paul Scherrer Institute, Switzerland
--  All rights reserved.
--  Authors: Oliver Bruendler
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Entity
------------------------------------------------------------------------------	
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

entity psi_common_status_cc_reg2data is
	port
	(
		-- Clock Domain A
		ClkA			: in 	std_logic;
		RstInA			: in 	std_logic;
		CounterWrpA     : in 	std_logic_vector(31 downto 0);
		DataSpacingA    : in 	std_logic_vector(15 downto 0);
		EnaA            : in 	std_logic_vector(0 downto 0);
		TrigCountA      : in 	std_logic_vector(31 downto 0);
		TrigOffsA       : in 	std_logic_vector(31 downto 0);
		TrigSpacingA    : in 	std_logic_vector(31 downto 0);
		TrigSporadicA   : in 	std_logic_vector(0 downto 0);
		UseRdyA         : in 	std_logic_vector(0 downto 0);
		RstOutA			: out	std_logic;
		
		-- Clock Domain B
		ClkB			: in	std_logic;
		RstInB			: in	std_logic;
		CounterWrpB     : out	std_logic_vector(31 downto 0);
		DataSpacingB    : out	std_logic_vector(15 downto 0);
		EnaB            : out	std_logic_vector(0 downto 0);
		TrigCountB      : out	std_logic_vector(31 downto 0);
		TrigOffsB       : out	std_logic_vector(31 downto 0);
		TrigSpacingB    : out	std_logic_vector(31 downto 0);
		TrigSporadicB   : out	std_logic_vector(0 downto 0);
		UseRdyB         : out	std_logic_vector(0 downto 0);
		RstOutB			: out	std_logic
	);
end entity;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture rtl of psi_common_status_cc_reg2data is 
	signal MergedA 	: std_logic_vector(147-1 downto 0);
	signal MergedB 	: std_logic_vector(147-1 downto 0);
begin

	MergedA(31 downto 0) <= CounterWrpA;
	MergedA(47 downto 32) <= DataSpacingA;
	MergedA(48 downto 48) <= EnaA;
	MergedA(80 downto 49) <= TrigCountA;
	MergedA(112 downto 81) <= TrigOffsA;
	MergedA(144 downto 113) <= TrigSpacingA;
	MergedA(145 downto 145) <= TrigSporadicA;
	MergedA(146 downto 146) <= UseRdyA;

	i_inst : entity work.psi_common_status_cc
		generic map (
			DataWidth_g		=> 147
		)
		port map (
			ClkA		=> ClkA,
			RstInA		=> RstInA,			
			DataA		=> MergedA,
			RstOutA		=> RstOutA,
			ClkB		=> ClkB,
			RstInB		=> RstInB,
			DataB		=> MergedB,
			RstOutB		=> RstOutB
		);
		
	CounterWrpB <= MergedB(31 downto 0);
	DataSpacingB <= MergedB(47 downto 32);
	EnaB <= MergedB(48 downto 48);
	TrigCountB <= MergedB(80 downto 49);
	TrigOffsB <= MergedB(112 downto 81);
	TrigSpacingB <= MergedB(144 downto 113);
	TrigSporadicB <= MergedB(145 downto 145);
	UseRdyB <= MergedB(146 downto 146);

end rtl;
