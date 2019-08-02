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

------------------------------------------------------------------------------
-- Package
------------------------------------------------------------------------------	
package axis_data_gen_reg_pkg is
	
	constant ADDR_CFG_ENA		: integer		:= 16#00#;
	constant ADDR_CFG_USERDY	: integer		:= 16#04#;
	constant ADDR_DATA_WRP		: integer		:= 16#10#;
	constant ADDR_DATA_SPAC		: integer		:= 16#14#; 
	constant ADDR_TRIG_OFFS		: integer		:= 16#20#;
	constant ADDR_TRIG_SPAC		: integer		:= 16#24#;
	constant ADDR_TRIG_SPOR_EN	: integer		:= 16#28#;
	constant ADDR_TRIG_SPOR_LD	: integer		:= 16#2C#;
	constant ADDR_TRIG_SPOR_CNT	: integer		:= 16#30#;
	constant ADDR_RDYLO			: integer		:= 16#40#;
	constant ADDR_STAT_DATACNT	: integer		:= 16#50#;
	constant ADDR_STAT_TRIGLEFT	: integer		:= 16#54#;
	
	function AddrToRegNr(	addr : integer) return integer;
	
end package;

------------------------------------------------------------------------------
-- Package Body
------------------------------------------------------------------------------	
package body axis_data_gen_reg_pkg is
	function AddrToRegNr(	addr : integer) return integer is
	begin
		return addr/4;
	end function;
end;


