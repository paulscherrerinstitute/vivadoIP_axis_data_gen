------------------------------------------------------------------------------
--  Copyright (c) 2019 by Paul Scherrer Institute, Switzerland
--  All rights reserved.
--  Authors: Oliver Bruendler
------------------------------------------------------------------------------

------------------------------------------------------------
-- Testbench generated by TbGen.py
------------------------------------------------------------
-- see Library/Python/TbGenerator

------------------------------------------------------------
-- Libraries
------------------------------------------------------------
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library work;
	use work.psi_common_math_pkg.all;
	use work.axis_data_gen_reg_pkg.all;

library work;
	use work.psi_tb_txt_util.all;
	use work.psi_tb_compare_pkg.all;
	use work.psi_tb_activity_pkg.all;
	use work.psi_tb_axi_pkg.all;
	use work.axis_data_gen_reg_pkg.all;

------------------------------------------------------------
-- Entity Declaration
------------------------------------------------------------
entity axis_data_gen_vivado_wrp_tb is
	generic (
		RstUseRdy_g : boolean := true ;
		RstCounterWrp_g : integer := 15 ;
		RstDataSpacing_g : integer := 1 ;
		RstTrigSpacing_g : integer := 3 ;
		RstTrigOffs_g : integer := 2 ;
		RstEna_g : boolean := false ;
		UseAxiIf_g : boolean := true 
	);
end entity;

------------------------------------------------------------
-- Architecture
------------------------------------------------------------
architecture sim of axis_data_gen_vivado_wrp_tb is
	-- *** Fixed Generics ***
	constant DataWidth_g : positive := 16;
	
	-- *** Not Assigned Generics (default values) ***
	
	-------------------------------------------------------------------------
	-- AXI Definition
	-------------------------------------------------------------------------
	constant ID_WIDTH 		: integer 	:= 1;
	constant ADDR_WIDTH 	: integer	:= 8;
	constant USER_WIDTH		: integer	:= 1;
	constant DATA_WIDTH		: integer	:= 32;
	constant BYTE_WIDTH		: integer	:= DATA_WIDTH/8;
	
	subtype ID_RANGE is natural range ID_WIDTH-1 downto 0;
	subtype ADDR_RANGE is natural range ADDR_WIDTH-1 downto 0;
	subtype USER_RANGE is natural range USER_WIDTH-1 downto 0;
	subtype DATA_RANGE is natural range DATA_WIDTH-1 downto 0;
	subtype BYTE_RANGE is natural range BYTE_WIDTH-1 downto 0;
	
	signal axi_ms : axi_ms_r (	arid(ID_RANGE), awid(ID_RANGE),
								araddr(ADDR_RANGE), awaddr(ADDR_RANGE),
								aruser(USER_RANGE), awuser(USER_RANGE), wuser(USER_RANGE),
								wdata(DATA_RANGE),
								wstrb(BYTE_RANGE));
	
	signal axi_sm : axi_sm_r (	rid(ID_RANGE), bid(ID_RANGE),
								ruser(USER_RANGE), buser(USER_RANGE),
								rdata(DATA_RANGE));	
	
	-- *** TB Control ***
	signal TbRunning : boolean := True;
	signal NextCase : integer := -1;
	signal ProcessDone : std_logic_vector(0 to 1) := (others => '0');
	constant AllProcessesDone_c : std_logic_vector(0 to 1) := (others => '1');
	constant TbProcNr_config_c : integer := 0;
	constant TbProcNr_stream_c : integer := 1;
	signal TestCase	: integer := -1;
	signal CaseDone : integer := -1;
	
	
	-- *** DUT Signals ***
	signal ClkData : std_logic := '1';
	signal RstData : std_logic := '1';
	signal Axis_TData : std_logic_vector(DataWidth_g-1 downto 0) := (others => '0');
	signal Axis_TReady : std_logic := '0';
	signal Axis_TValid : std_logic := '0';
	signal Axis_TLast : std_logic := '0';
	signal Trig : std_logic := '0';
	signal s00_axi_aclk : std_logic := '1';
	signal s00_axi_aresetn : std_logic := '0';
	
	signal s_axi_aresetn_muxed : std_logic;
	
	procedure WaitCase(nr : integer) is
	begin
		while TestCase /= nr loop
			wait until rising_edge(ClkData);
		end loop;
	end procedure;
	
	procedure WaitDone(nr : integer) is
	begin
		while CaseDone /= nr loop
			if UseAxiIf_g then
				wait until rising_edge(s00_axi_aclk);
			else
				wait until rising_edge(ClkData);
			end if;
		end loop;
	end procedure;	
	
	-- *** Test Procedure ***
	procedure CheckStream(	Samples		: in	integer;
							UseRdy		: in	boolean;
							DataWrp		: in	integer;
							DataSpac	: in	integer;
							TrigOffs	: in	integer;
							TrigSpac	: in	integer;
					signal	Axis_TReady	: out	std_logic) is
	begin
		for SampleNr in 0 to Samples-1 loop
			Axis_TReady <= '1';
			wait until rising_edge(ClkData) and Axis_TValid = '1';
			if UseRdy then
				Axis_TReady <= '0';
			end if;
			-- Check Data
			StdlvCompareInt (SampleNr mod (DataWrp+1), Axis_TData, "Wrong TData");
			-- Check Trigger
			if SampleNr >= TrigOffs then
				if (SampleNr-TrigOffs) mod (TrigSpac+1) = 0 then		
					StdlCompare(1, Trig, "Did not get Trigger");
				else
					StdlCompare(0, Trig, "Unexpected Trigger");
				end if;
			else
				StdlCompare(0, Trig, "Unexpected Trigger before Offs");
			end if;
			-- Check data spacing
			for i in 0 to DataSpac-1 loop
				wait until rising_edge(ClkData);
				StdlCompare(0, Axis_TValid, "Data Spacing not correct");
			end loop;
			-- Pull Ready low
			if UseRdy then
				for i in 0 to 3 loop
					wait until rising_edge(ClkData);
				end loop;
			end if;					
		end loop;
	end procedure;
	
	procedure Config(	UseRdy		: in	boolean;
						DataWrp		: in	integer;
						DataSpac	: in	integer;
						TrigOffs	: in	integer;
						TrigSpac	: in	integer;
				signal	axi_ms		: out	axi_ms_r;
				signal 	axi_sm		: in	axi_sm_r) is
	begin
		axi_single_write(ADDR_CFG_ENA, 0, axi_ms, axi_sm, s00_axi_aclk);
		axi_single_write(ADDR_CFG_USERDY, choose(UseRdy, 1, 0), axi_ms, axi_sm, s00_axi_aclk);
		axi_single_write(ADDR_DATA_WRP, DataWrp, axi_ms, axi_sm, s00_axi_aclk);
		axi_single_write(ADDR_DATA_SPAC, DataSpac, axi_ms, axi_sm, s00_axi_aclk);
		axi_single_write(ADDR_TRIG_OFFS, TrigOffs, axi_ms, axi_sm, s00_axi_aclk);
		axi_single_write(ADDR_TRIG_SPAC, TrigSpac, axi_ms, axi_sm, s00_axi_aclk);
		axi_single_write(ADDR_CFG_ENA, 1, axi_ms, axi_sm, s00_axi_aclk);
	end procedure;
	
	
begin

	s_axi_aresetn_muxed <= s00_axi_aresetn when UseAxiIf_g else '0';

	------------------------------------------------------------
	-- DUT Instantiation
	------------------------------------------------------------
	i_dut : entity work.axis_data_gen_vivado_wrp
		generic map (
			C_S00_AXI_ID_WIDTH => 1,
			RstUseRdy_g => RstUseRdy_g,
			RstCounterWrp_g => to_unsigned(RstCounterWrp_g, 32),
			RstDataSpacing_g => to_unsigned(RstDataSpacing_g, 16),
			RstTrigSpacing_g => to_unsigned(RstTrigSpacing_g, 32),
			RstTrigOffs_g => to_unsigned(RstTrigOffs_g, 32),
			RstEna_g => RstEna_g,
			UseAxiIf_g => UseAxiIf_g,
			DataWidth_g => DataWidth_g
		)
		port map (
			Data_Clk => ClkData,
			Data_Rst => RstData,
			Axis_TData => Axis_TData,
			Axis_TReady => Axis_TReady,
			Axis_TValid => Axis_TValid,
			Axis_TLast => Axis_TLast,
			Trig => Trig,
			s00_axi_aclk => s00_axi_aclk,
			s00_axi_aresetn => s_axi_aresetn_muxed,
			s00_axi_arid => axi_ms.arid,
			s00_axi_araddr => axi_ms.araddr,
			s00_axi_arlen => axi_ms.arlen,
			s00_axi_arsize => axi_ms.arsize,
			s00_axi_arburst => axi_ms.arburst,
			s00_axi_arlock => axi_ms.arlock,
			s00_axi_arcache => axi_ms.arcache,
			s00_axi_arprot => axi_ms.arprot,
			s00_axi_arvalid => axi_ms.arvalid,
			s00_axi_arready => axi_sm.arready,
			s00_axi_rid => axi_sm.rid,
			s00_axi_rdata => axi_sm.rdata,
			s00_axi_rresp => axi_sm.rresp,
			s00_axi_rlast => axi_sm.rlast,
			s00_axi_rvalid => axi_sm.rvalid,
			s00_axi_rready => axi_ms.rready,
			s00_axi_awaddr => axi_ms.awaddr,
			s00_axi_awlen => axi_ms.awlen,
			s00_axi_awsize => axi_ms.awsize,
			s00_axi_awid => axi_ms.awid,
			s00_axi_awburst => axi_ms.awburst,
			s00_axi_awlock => axi_ms.awlock,
			s00_axi_awcache => axi_ms.awcache,
			s00_axi_awprot => axi_ms.awprot,
			s00_axi_awvalid => axi_ms.awvalid,
			s00_axi_awready => axi_sm.awready,
			s00_axi_wdata => axi_ms.wdata,
			s00_axi_wstrb => axi_ms.wstrb,
			s00_axi_wlast => axi_ms.wlast,
			s00_axi_wvalid => axi_ms.wvalid,
			s00_axi_wready => axi_sm.wready,
			s00_axi_bid => axi_sm.bid,
			s00_axi_bresp => axi_sm.bresp,
			s00_axi_bvalid => axi_sm.bvalid,
			s00_axi_bready => axi_ms.bready
		);
	
	------------------------------------------------------------
	-- Testbench Control !DO NOT EDIT!
	------------------------------------------------------------
	p_tb_control : process
	begin
		wait until RstData = '0' and (s00_axi_aresetn = '1' or not UseAxiIf_g);
		wait until ProcessDone = AllProcessesDone_c;
		TbRunning <= false;
		wait;
	end process;
	
	------------------------------------------------------------
	-- Clocks !DO NOT EDIT!
	------------------------------------------------------------
	p_clock_ClkData : process
		constant Frequency_c : real := real(133e6);
	begin
		while TbRunning loop
			wait for 0.5*(1 sec)/Frequency_c;
			ClkData <= not ClkData;
		end loop;
		wait;
	end process;
	
	g_axi_if1 : if UseAxiIf_g generate
		p_clock_s00_axi_aclk : process
			constant Frequency_c : real := real(100e6);
		begin
			while TbRunning loop
				wait for 0.5*(1 sec)/Frequency_c;
				s00_axi_aclk <= not s00_axi_aclk;
			end loop;
			wait;
		end process;
	end generate;
	
	
	------------------------------------------------------------
	-- Resets
	------------------------------------------------------------
	p_rst_RstData : process
	begin
		wait for 1 us;
		-- Wait for two clk edges to ensure reset is active for at least one edge
		wait until rising_edge(ClkData);
		wait until rising_edge(ClkData);
		RstData <= '0';
		wait;
	end process;
	
	g_axi_if2 : if UseAxiIf_g generate
		p_rst_s00_axi_aresetn : process
		begin
			wait for 1 us;
			-- Wait for two clk edges to ensure reset is active for at least one edge
			wait until rising_edge(s00_axi_aclk);
			wait until rising_edge(s00_axi_aclk);
			s00_axi_aresetn <= '1';
			wait;
		end process;
	end generate;
	
	
	------------------------------------------------------------
	-- Processes
	------------------------------------------------------------
	-- *** config ***
	p_config : process
		variable Read_v	: integer;
	begin
		axi_master_init(axi_ms);
	
		-- start of process !DO NOT EDIT
		wait until RstData = '0' and (s00_axi_aresetn = '1' or not UseAxiIf_g);
		if UseAxiIf_g then
			wait until rising_edge (s00_axi_aclk);
		end if;
		
		-- *** Test Reset Behavior ***
		print(">> Reset Behavior");
		TestCase <= 0;
		-- Cannot do tests if always disabled
		if (not RstEna_g) and (not UseAxiIf_g) then
			print("###ERROR###: Either Reset Ena must be set or AXI IF must be enabled");
		end if;
		-- Enable actively if not enabled after reset anyway
		if (not RstEna_g) and UseAxiIf_g then
			axi_single_write(ADDR_CFG_ENA, 1, axi_ms, axi_sm, s00_axi_aclk);
		end if;
		-- No other configuration required for reset tests
		WaitDone(0);
		if UseAxiIf_g then
			axi_single_write(ADDR_CFG_ENA, 0, axi_ms, axi_sm, s00_axi_aclk);
		end if;
		wait for 1 us;
		
		-- Other tests can only be executed if axi IF is enabled
		if UseAxiIf_g then
		
			-- *** Normal ***
			print(">> Normal");
			TestCase <= 1;
			Config(	UseRdy => false, 
					DataWrp => 12, 
					DataSpac => 2, 
					TrigOffs => 4, 
					TrigSpac => 5, 
					axi_ms => axi_ms, axi_sm => axi_sm);
			WaitDone(1);
			axi_single_write(ADDR_CFG_ENA, 0, axi_ms, axi_sm, s00_axi_aclk);
			wait for 1 us;
		
			-- *** No Spacing / No Ready ***
			print(">> No Spacing / No Ready");
			TestCase <= 2;
			Config(	UseRdy => false, 
					DataWrp => 12, 
					DataSpac => 0, 
					TrigOffs => 4, 
					TrigSpac => 5, 
					axi_ms => axi_ms, axi_sm => axi_sm);
			WaitDone(2);
			axi_single_write(ADDR_CFG_ENA, 0, axi_ms, axi_sm, s00_axi_aclk);
			wait for 1 us;	

			-- *** No Spacing / Ready ***
			print(">> No Spacing / Ready");
			TestCase <= 3;
			Config(	UseRdy => true, 
					DataWrp => 12, 
					DataSpac => 0, 
					TrigOffs => 4, 
					TrigSpac => 5, 
					axi_ms => axi_ms, axi_sm => axi_sm);
			WaitDone(3);
			axi_single_write(ADDR_CFG_ENA, 0, axi_ms, axi_sm, s00_axi_aclk);
			wait for 1 us;				
			
			-- *** Trigger Offs 0 ***
			print(">> No Spacing / No Ready");
			TestCase <= 4;
			Config(	UseRdy => false, 
					DataWrp => 12, 
					DataSpac => 0, 
					TrigOffs => 0, 
					TrigSpac => 5, 
					axi_ms => axi_ms, axi_sm => axi_sm);
			WaitDone(4);
			axi_single_write(ADDR_CFG_ENA, 0, axi_ms, axi_sm, s00_axi_aclk);
			wait for 1 us;				
			
			-- *** Ready Low Latching 1 ***
			print(">> Ready Low Latching 1");
			TestCase <= 5;
			axi_single_write(ADDR_RDYLO, 1, axi_ms, axi_sm, s00_axi_aclk);
			Config(	UseRdy => false, 
					DataWrp => 12, 
					DataSpac => 0, 
					TrigOffs => 0, 
					TrigSpac => 5, 
					axi_ms => axi_ms, axi_sm => axi_sm);
			WaitDone(5);
			axi_single_expect(ADDR_RDYLO, 0, axi_ms, axi_sm, s00_axi_aclk, "Rdy latch set A");
			axi_single_write(ADDR_CFG_ENA, 0, axi_ms, axi_sm, s00_axi_aclk);
			axi_single_expect(ADDR_RDYLO, 0, axi_ms, axi_sm, s00_axi_aclk, "Rdy latch set B");
			wait for 1 us;	

			-- *** Ready Low Latching 2 ***
			print(">> Ready Low Latching 2");
			TestCase <= 6;
			axi_single_write(ADDR_RDYLO, 1, axi_ms, axi_sm, s00_axi_aclk);
			Config(	UseRdy => true, 
					DataWrp => 12, 
					DataSpac => 0, 
					TrigOffs => 0, 
					TrigSpac => 5, 
					axi_ms => axi_ms, axi_sm => axi_sm);
			WaitDone(6);
			axi_single_expect(ADDR_RDYLO, 1, axi_ms, axi_sm, s00_axi_aclk, "Rdy latch no set A");
			axi_single_write(ADDR_CFG_ENA, 0, axi_ms, axi_sm, s00_axi_aclk);
			axi_single_expect(ADDR_RDYLO, 1, axi_ms, axi_sm, s00_axi_aclk, "Rdy latch not set B");
			wait for 1 us;				
			
			-- *** Sporadic Trigger ***
			print(">> Sporadic Trigger");
			Read_v := 0;
			TestCase <= 7;
			axi_single_write(ADDR_RDYLO, 1, axi_ms, axi_sm, s00_axi_aclk);
			axi_single_write(ADDR_TRIG_SPOR_CNT, 10, axi_ms, axi_sm, s00_axi_aclk);
			axi_single_write(ADDR_TRIG_SPOR_EN, 1, axi_ms, axi_sm, s00_axi_aclk);
			Config(	UseRdy => true, 
					DataWrp => 16#3FFFFFFF#, 
					DataSpac => 0, 
					TrigOffs => 0, 
					TrigSpac => 9, 
					axi_ms => axi_ms, axi_sm => axi_sm);
			while Read_v < 500 loop
				axi_single_read(ADDR_STAT_DATACNT, Read_v, axi_ms, axi_sm, s00_axi_aclk);
			end loop;
			axi_single_write(ADDR_TRIG_SPOR_LD, 1, axi_ms, axi_sm, s00_axi_aclk);
			WaitDone(7);
			wait for 1 us;			
			
		end if;
		
		
		-- end of process !DO NOT EDIT!
		wait for 1 us;
		ProcessDone(TbProcNr_config_c) <= '1';		
		wait;
	end process;
	
	-- *** stream ***
	p_stream : process
		variable TrigCnt_v : integer;
	begin
		-- start of process !DO NOT EDIT
		wait until RstData = '0' and (s00_axi_aresetn = '1' or not UseAxiIf_g);
		wait until rising_edge (ClkData);
		
		-- Test Reset Behavior
		WaitCase(0);
		CheckStream(Samples		=> 3*(RstCounterWrp_g+1),
					UseRdy		=> RstUseRdy_g,
					DataWrp		=> RstCounterWrp_g,
					DataSpac	=> RstDataSpacing_g,
					TrigOffs	=> RstTrigOffs_g,
					TrigSpac	=> RstTrigSpacing_g,
					Axis_TReady	=> Axis_TReady);
		CaseDone <= 0;
		
		-- Other tests can only be executed if axi IF is enabled
		if UseAxiIf_g then
		
			-- *** Normal ***
			WaitCase(1);
			CheckStream(Samples		=> 30,
						UseRdy		=> false,
						DataWrp		=> 12,
						DataSpac	=> 2,
						TrigOffs	=> 4,
						TrigSpac	=> 5,
						Axis_TReady	=> Axis_TReady);			
			CaseDone <= 1;
		
			-- *** No Spacing / No Ready ***
			WaitCase(2);
			CheckStream(Samples		=> 30,
						UseRdy		=> false,
						DataWrp		=> 12,
						DataSpac	=> 0,
						TrigOffs	=> 4,
						TrigSpac	=> 5,
						Axis_TReady	=> Axis_TReady);			
			CaseDone <= 2;
			
			-- *** No Spacing / Ready ***
			WaitCase(3);
			CheckStream(Samples		=> 30,
						UseRdy		=> true,
						DataWrp		=> 12,
						DataSpac	=> 0,
						TrigOffs	=> 4,
						TrigSpac	=> 5,
						Axis_TReady	=> Axis_TReady);			
			CaseDone <= 3;			
			
			-- *** Trigger Offs 0 ***
			WaitCase(4);
			CheckStream(Samples		=> 30,
						UseRdy		=> false,
						DataWrp		=> 12,
						DataSpac	=> 0,
						TrigOffs	=> 0,
						TrigSpac	=> 5,
						Axis_TReady	=> Axis_TReady);			
			CaseDone <= 4;
			
			-- *** Ready Low Latching  1 ***
			WaitCase(5);
			CheckStream(Samples		=> 30,
						UseRdy		=> false,
						DataWrp		=> 12,
						DataSpac	=> 0,
						TrigOffs	=> 0,
						TrigSpac	=> 5,
						Axis_TReady	=> Axis_TReady);			
			CaseDone <= 5;	

			-- *** Ready Low Latching  2 ***
			WaitCase(6);
			CheckStream(Samples		=> 30,
						UseRdy		=> true,
						DataWrp		=> 12,
						DataSpac	=> 0,
						TrigOffs	=> 0,
						TrigSpac	=> 5,
						Axis_TReady	=> Axis_TReady);			
			CaseDone <= 6;				
			
			-- *** Sporadic Trigger ***
			WaitCase(7);
			Axis_TReady <= '1';
			wait until rising_edge(ClkData) and Axis_TValid = '1';
			while unsigned(Axis_TData) <= 500 loop
				StdlCompare(0, Trig, "Unexpected trigger");
				wait until rising_edge(ClkData) and Axis_TValid = '1';
			end loop;
			TrigCnt_v := 0;
			while (unsigned(Axis_TData) <= 1000) and (TrigCnt_v < 10) loop
				wait until rising_edge(ClkData) and Axis_TValid = '1';
				if Trig = '1' then
					assert unsigned(Axis_TData) mod 10 = 0 report "###ERROR###: Trigger not in modulo 10 spacing" severity error;
					TrigCnt_v := TrigCnt_v + 1;
				end if;
			end loop;
			IntCompare(10, TrigCnt_v, "Triggers not received");
			CheckNoActivity(Trig, 10 us, 0, "Unexpected additional trigger");
			CaseDone <= 7;
			
		end if;
	
		
		-- end of process !DO NOT EDIT!
		ProcessDone(TbProcNr_stream_c) <= '1';
		wait;
	end process;
	
	
end;
