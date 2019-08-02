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

entity psi_common_status_cc_data2reg is
	port
	(
		-- Clock Domain A
		ClkA			: in 	std_logic;
		RstInA			: in 	std_logic;
		CurrentCntA     : in 	std_logic_vector(31 downto 0);
		RdyWasLowA      : in 	std_logic_vector(0 downto 0);
		TrigLeftA       : in 	std_logic_vector(31 downto 0);
		RstOutA			: out	std_logic;
		
		-- Clock Domain B
		ClkB			: in	std_logic;
		RstInB			: in	std_logic;
		CurrentCntB     : out	std_logic_vector(31 downto 0);
		RdyWasLowB      : out	std_logic_vector(0 downto 0);
		TrigLeftB       : out	std_logic_vector(31 downto 0);
		RstOutB			: out	std_logic
	);
end entity;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture rtl of psi_common_status_cc_data2reg is 
	signal MergedA 	: std_logic_vector(65-1 downto 0);
	signal MergedB 	: std_logic_vector(65-1 downto 0);
begin

	MergedA(31 downto 0) <= CurrentCntA;
	MergedA(32 downto 32) <= RdyWasLowA;
	MergedA(64 downto 33) <= TrigLeftA;

	i_inst : entity work.psi_common_status_cc
		generic map (
			DataWidth_g		=> 65
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
		
	CurrentCntB <= MergedB(31 downto 0);
	RdyWasLowB <= MergedB(32 downto 32);
	TrigLeftB <= MergedB(64 downto 33);

end rtl;
