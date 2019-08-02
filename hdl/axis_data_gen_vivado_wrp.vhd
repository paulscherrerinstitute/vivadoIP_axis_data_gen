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
	use work.psi_common_math_pkg.all;
	use work.axis_data_gen_reg_pkg.all;
	use work.psi_common_array_pkg.all;

------------------------------------------------------------------------------
-- Entity
------------------------------------------------------------------------------	
-- $$ processes=config,stream $$
-- $$ tbpkg=work.psi_tb_txt_util,work.psi_tb_compare_pkg,work.psi_tb_activity_pkg,work.psi_tb_axi_pkg $$
entity axis_data_gen_vivado_wrp is
	generic
	(
		-- Component Parameters	
		DataWidth_g					: positive				:= 16;				-- $$ constant=16 $$
	
		-- Reset Values
		RstUseRdy_g					: boolean				:= true;			-- $$ export=true $$
		RstCounterWrp_g				: unsigned(31 downto 0)	:= X"0000FFFF";		-- $$ export=true $$
		RstDataSpacing_g			: unsigned(15 downto 0)	:= X"0000";			-- $$ export=true $$
		RstTrigSpacing_g			: unsigned(31 downto 0)	:= X"0000FFFF";		-- $$ export=true $$
		RstTrigOffs_g				: unsigned(31 downto 0)	:= X"00001000";		-- $$ export=true $$
		RstEna_g					: boolean				:= true;			-- $$ export=true $$
		
		-- General Parameters
		UseAxiIf_g					: boolean				:= true;			-- $$ export=true $$
		
		-- Vivado BD Parameters
		C_S00_AXI_ID_WIDTH			: integer				:= 0
	);
	port
	(
		-- Control Signals
		Data_Clk					: in std_logic;														-- $$ type=clk; freq=133e6; proc=stream $$
		Data_Rst					: in std_logic;														-- $$ type=rst; clk=Data_Clk $$
		
		-- AXI-S Interface
		Axis_TData					: out	std_logic_vector(DataWidth_g-1 downto 0);					-- $$ proc=stream $$
		Axis_TReady					: in	std_logic;													-- $$ proc=stream $$
		Axis_TValid					: out	std_logic;													-- $$ proc=stream $$
		Axis_TLast					: out	std_logic;													-- $$ proc=stream $$
		
		-- Trigger
		Trig						: out	std_logic;													-- $$ proc=stream $$
		-----------------------------------------------------------------------------
		-- Axi Slave Bus Interface
		-----------------------------------------------------------------------------
		-- System
		s00_axi_aclk                : in    std_logic						:= '0';   					-- $$ type=clk; freq=100e6; proc=config $$                                         
		s00_axi_aresetn             : in    std_logic						:= '0';                 	-- $$ type=rst; clk=s00_axi_aclk; lowactive=true $$                    
		-- Read address channel  	
		s00_axi_arid				: in	std_logic_vector(C_S00_AXI_ID_WIDTH-1 downto 0)	:= (others => '0');
		s00_axi_araddr              : in    std_logic_vector(7 downto 0)	:= (others => '0');    		-- $$ proc=config $$
		s00_axi_arlen               : in    std_logic_vector(7 downto 0)	:= (others => '0');    		-- $$ proc=config $$                         
		s00_axi_arsize              : in    std_logic_vector(2 downto 0)	:= (others => '0');    		-- $$ proc=config $$                         
		s00_axi_arburst             : in    std_logic_vector(1 downto 0)	:= (others => '0');    		-- $$ proc=config $$                         
		s00_axi_arlock              : in    std_logic						:= '0';      				-- $$ proc=config $$                                          
		s00_axi_arcache             : in    std_logic_vector(3 downto 0)	:= (others => '0');    		-- $$ proc=config $$                         
		s00_axi_arprot              : in    std_logic_vector(2 downto 0)	:= (others => '0');    		-- $$ proc=config $$                         
		s00_axi_arvalid             : in    std_logic						:= '0';           			-- $$ proc=config $$                                     
		s00_axi_arready             : out   std_logic;                                                	-- $$ proc=config $$
		-- Read data channel     
		s00_axi_rid					: out	std_logic_vector(C_S00_AXI_ID_WIDTH-1 downto 0);
		s00_axi_rdata               : out   std_logic_vector(31 downto 0);        						-- $$ proc=config $$
		s00_axi_rresp               : out   std_logic_vector(1 downto 0);         						-- $$ proc=config $$                    
		s00_axi_rlast               : out   std_logic;                          						-- $$ proc=config $$                       
		s00_axi_rvalid              : out   std_logic;                            						-- $$ proc=config $$                    
		s00_axi_rready              : in    std_logic						:= '0';        				-- $$ proc=config $$                                        
		-- Write address channel  
		s00_axi_awid				: in	std_logic_vector(C_S00_AXI_ID_WIDTH-1 downto 0)	:= (others => '0');
		s00_axi_awaddr              : in    std_logic_vector(7 downto 0)	:= (others => '0');   		-- $$ proc=config $$
		s00_axi_awlen               : in    std_logic_vector(7 downto 0)	:= (others => '0');   		-- $$ proc=config $$                     
		s00_axi_awsize              : in    std_logic_vector(2 downto 0)	:= (others => '0');   		-- $$ proc=config $$                     
		s00_axi_awburst             : in    std_logic_vector(1 downto 0)	:= (others => '0');   		-- $$ proc=config $$                     
		s00_axi_awlock              : in    std_logic						:= '0';               		-- $$ proc=config $$                            
		s00_axi_awcache             : in    std_logic_vector(3 downto 0)	:= (others => '0');    		-- $$ proc=config $$                    
		s00_axi_awprot              : in    std_logic_vector(2 downto 0)	:= (others => '0');    		-- $$ proc=config $$                    
		s00_axi_awvalid             : in    std_logic						:= '0';               		-- $$ proc=config $$                            
		s00_axi_awready             : out   std_logic;                                            		-- $$ proc=config $$
		-- Write data channel
		s00_axi_wdata               : in    std_logic_vector(31 downto 0)	:= (others => '0');         -- $$ proc=config $$
		s00_axi_wstrb               : in    std_logic_vector(3 downto 0)	:= (others => '0');         -- $$ proc=config $$
		s00_axi_wlast               : in    std_logic						:= '0';                     -- $$ proc=config $$                        
		s00_axi_wvalid              : in    std_logic						:= '0';                     -- $$ proc=config $$                        
		s00_axi_wready              : out   std_logic;                                                  -- $$ proc=config $$
		-- Write response channel  
		s00_axi_bid					: out	std_logic_vector(C_S00_AXI_ID_WIDTH-1 downto 0);
		s00_axi_bresp               : out   std_logic_vector(1 downto 0);                               -- $$ proc=config $$
		s00_axi_bvalid              : out   std_logic;                                                  -- $$ proc=config $$
		s00_axi_bready              : in    std_logic 						:= '0'                      -- $$ proc=config $$                        
	);

end entity axis_data_gen_vivado_wrp;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture rtl of axis_data_gen_vivado_wrp is 

	-- Array of desired number of chip enables for each address range
	constant USER_SLV_NUM_REG               : integer              := 32; 
	function GetRegInit return t_aslv32 is
		variable Init_v : t_aslv32(0 to USER_SLV_NUM_REG-1) := (others => (others => '0'));
	begin
		Init_v(AddrToRegNr(ADDR_CFG_ENA))		:= choose(RstEna_g, X"00000001", X"00000000");
		Init_v(AddrToRegNr(ADDR_CFG_USERDY))	:= choose(RstUseRdy_g, X"00000001", X"00000000");
		Init_v(AddrToRegNr(ADDR_DATA_WRP))		:= std_logic_vector(RstCounterWrp_g);
		Init_v(AddrToRegNr(ADDR_DATA_SPAC))		:= std_logic_vector(resize(RstDataSpacing_g, 32));
		Init_v(AddrToRegNr(ADDR_TRIG_OFFS))		:= std_logic_vector(RstTrigOffs_g);
		Init_v(AddrToRegNr(ADDR_TRIG_SPAC))		:= std_logic_vector(RstTrigSpacing_g);
		return Init_v;
	end function;
	constant RegInit_c						: t_aslv32(0 to USER_SLV_NUM_REG-1) := GetRegInit;																
	
	-- IP Interconnect (IPIC) signal declarations
	signal reg_rd                    		: std_logic_vector(USER_SLV_NUM_REG-1 downto  0);
	signal reg_rdata                 		: t_aslv32(0 to USER_SLV_NUM_REG-1) := (others => (others => '0'));
	signal reg_wr                    		: std_logic_vector(USER_SLV_NUM_REG-1 downto  0);
	signal reg_wdata                 		: t_aslv32(0 to USER_SLV_NUM_REG-1);
	
	-- Pulse Signals
	signal Pulse_ClrRdyLow		: std_logic;
	signal Pulse_TrigSporLd		: std_logic;
	
	-- Axi Signals
	signal AxiRst				: std_logic;
	signal AxiRstn				: std_logic;
	
	

begin

	g_axi_sig : if UseAxiIf_g generate
		AxiRst <= not s00_axi_aresetn;
		AxiRstn <= s00_axi_aresetn;
	end generate;
	g_n_axi_sig : if not UseAxiIf_g generate
		AxiRst	<= Data_Rst;
		AxiRstn <= not Data_Rst;
	end generate;

   -----------------------------------------------------------------------------
   -- AXI decode instance
   -----------------------------------------------------------------------------
   g_axiif : if UseAxiIf_g generate
	   axi_slave_reg_mem_inst : entity work.psi_common_axi_slave_ipif
		   generic map (
			  -- Users parameters
			  NumReg_g								=> USER_SLV_NUM_REG,
			  ResetVal_g(0 to USER_SLV_NUM_REG-1)	=> RegInit_c,
			  UseMem_g								=> false,
			  -- Parameters of Axi Slave Bus Interface
			  AxiIdWidth_g							=> C_S00_AXI_ID_WIDTH,
			  AxiAddrWidth_g			         	=> 8
		   )
		   port map
		   (
			  --------------------------------------------------------------------------
			  -- Axi Slave Bus Interface
			  --------------------------------------------------------------------------
			  -- System
			  s_axi_aclk                  => s00_axi_aclk,
			  s_axi_aresetn               => AxiRstn,
			  -- Read address channel
			  s_axi_arid                  => s00_axi_arid,
			  s_axi_araddr                => s00_axi_araddr,
			  s_axi_arlen                 => s00_axi_arlen,
			  s_axi_arsize                => s00_axi_arsize,
			  s_axi_arburst               => s00_axi_arburst,
			  s_axi_arlock                => s00_axi_arlock,
			  s_axi_arcache               => s00_axi_arcache,
			  s_axi_arprot                => s00_axi_arprot,
			  s_axi_arvalid               => s00_axi_arvalid,
			  s_axi_arready               => s00_axi_arready,
			  -- Read data channel
			  s_axi_rid					  => s00_axi_rid,
			  s_axi_rdata                 => s00_axi_rdata,
			  s_axi_rresp                 => s00_axi_rresp,
			  s_axi_rlast                 => s00_axi_rlast,
			  s_axi_rvalid                => s00_axi_rvalid,
			  s_axi_rready                => s00_axi_rready,
			  -- Write address channel
			  s_axi_awid                  => s00_axi_awid,
			  s_axi_awaddr                => s00_axi_awaddr,
			  s_axi_awlen                 => s00_axi_awlen,
			  s_axi_awsize                => s00_axi_awsize,
			  s_axi_awburst               => s00_axi_awburst,
			  s_axi_awlock                => s00_axi_awlock,
			  s_axi_awcache               => s00_axi_awcache,
			  s_axi_awprot                => s00_axi_awprot,
			  s_axi_awvalid               => s00_axi_awvalid,
			  s_axi_awready               => s00_axi_awready,
			  -- Write data channel
			  s_axi_wdata                 => s00_axi_wdata,
			  s_axi_wstrb                 => s00_axi_wstrb,
			  s_axi_wlast                 => s00_axi_wlast,
			  s_axi_wvalid                => s00_axi_wvalid,
			  s_axi_wready                => s00_axi_wready,
			  -- Write response channel
			  s_axi_bid					  => s00_axi_bid,
			  s_axi_bresp                 => s00_axi_bresp,
			  s_axi_bvalid                => s00_axi_bvalid,
			  s_axi_bready                => s00_axi_bready,
			  --------------------------------------------------------------------------
			  -- Register Interface
			  --------------------------------------------------------------------------
			  o_reg_rd                    => reg_rd,
			  i_reg_rdata                 => reg_rdata,
			  o_reg_wr                    => reg_wr,
			  o_reg_wdata                 => reg_wdata
		   );
	end generate;
	
	g_naxiif : if not UseAxiIf_g generate
		reg_wdata 		<= RegInit_c;
		s00_axi_rdata	<= (others => '0');
		s00_axi_arready	<= '0';
		s00_axi_rresp	<= (others => '0');
		s00_axi_rlast	<= '0';
		s00_axi_rvalid	<= '0';
		s00_axi_awready	<= '0';
		s00_axi_wready	<= '0';
		s00_axi_bresp	<= (others => '0');
		s00_axi_bvalid	<= '0';
		s00_axi_bid 	<= (others => '0');
		s00_axi_rid		<= (others => '0');
	end generate;
	
	

	-----------------------------------------------------------------------------
	-- Register Decoding
	----------------------------------------------------------------------------   
	-- Pulse Signals
	Pulse_ClrRdyLow		<= reg_wr(AddrToRegNr(ADDR_RDYLO)) and reg_wdata(AddrToRegNr(ADDR_RDYLO))(0);
	Pulse_TrigSporLd	<= reg_wr(AddrToRegNr(ADDR_TRIG_SPOR_LD)) and reg_wdata(AddrToRegNr(ADDR_TRIG_SPOR_LD))(0);
	
	-- Readback 
	reg_rdata(AddrToRegNr(ADDR_CFG_USERDY))(0)			<= reg_wdata(AddrToRegNr(ADDR_CFG_USERDY))(0);
	reg_rdata(AddrToRegNr(ADDR_CFG_ENA))(0)				<= reg_wdata(AddrToRegNr(ADDR_CFG_ENA))(0);
	reg_rdata(AddrToRegNr(ADDR_DATA_WRP))				<= reg_wdata(AddrToRegNr(ADDR_DATA_WRP));
	reg_rdata(AddrToRegNr(ADDR_DATA_SPAC))(15 downto 0)	<= reg_wdata(AddrToRegNr(ADDR_DATA_SPAC))(15 downto 0);
	reg_rdata(AddrToRegNr(ADDR_TRIG_SPAC))				<= reg_wdata(AddrToRegNr(ADDR_TRIG_SPAC));
	reg_rdata(AddrToRegNr(ADDR_TRIG_OFFS))				<= reg_wdata(AddrToRegNr(ADDR_TRIG_OFFS));
	reg_rdata(AddrToRegNr(ADDR_TRIG_SPOR_EN))(0)		<= reg_wdata(AddrToRegNr(ADDR_TRIG_SPOR_EN))(0);
	reg_rdata(AddrToRegNr(ADDR_TRIG_SPOR_CNT))			<= reg_wdata(AddrToRegNr(ADDR_TRIG_SPOR_CNT));

	-----------------------------------------------------------------------------
	-- Component Instantiations
	----------------------------------------------------------------------------   	
	i_data_gen : entity work.axis_data_gen
		generic map (
			DataWidth_g					=> DataWidth_g,
			UseRegCc_g					=> UseAxiIf_g
		)
		port map (
			ClkData						=> Data_Clk,
			RstData						=> Data_Rst,
			ClkReg						=> s00_axi_aclk,
			RstReg						=> AxiRst,
			InReg_UseRdy				=> reg_wdata(AddrToRegNr(ADDR_CFG_USERDY))(0),
			InReg_Ena					=> reg_wdata(AddrToRegNr(ADDR_CFG_ENA))(0),
			InReg_CounterWrp			=> reg_wdata(AddrToRegNr(ADDR_DATA_WRP)),
			InReg_DataSpacing			=> reg_wdata(AddrToRegNr(ADDR_DATA_SPAC))(15 downto 0),
			InReg_TrigSpacing			=> reg_wdata(AddrToRegNr(ADDR_TRIG_SPAC)),
			InReg_TrigOffs				=> reg_wdata(AddrToRegNr(ADDR_TRIG_OFFS)),
			InReg_TrigSporadic			=> reg_wdata(AddrToRegNr(ADDR_TRIG_SPOR_EN))(0),
			InReg_TrigCount				=> reg_wdata(AddrToRegNr(ADDR_TRIG_SPOR_CNT)),
			InReg_ClrRdyWasLow			=> Pulse_ClrRdyLow,
			InReg_StartTrigSporadic		=> Pulse_TrigSporLd,
			OutReg_CurrentCnt			=> reg_rdata(AddrToRegNr(ADDR_STAT_DATACNT)),
			OutReg_TrigLeft				=> reg_rdata(AddrToRegNr(ADDR_STAT_TRIGLEFT)),
			OutReg_RdyWasLow			=> reg_rdata(AddrToRegNr(ADDR_RDYLO))(0),
			Axis_TData					=> Axis_TData,
			Axis_TReady					=> Axis_TReady,
			Axis_TValid					=> Axis_TValid,
			Axis_TLast					=> Axis_TLast,
			Trig						=> Trig
		);
  
end rtl;
