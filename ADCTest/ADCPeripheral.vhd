-- ADCPeripheral.vhd
--
-- This file defines a peripheral that utilizes the LTC2308 file
-- to get data from the ADC and samples the ADC frequently to get
-- analog values. It returns a latched value to SCOMP when a read 
-- instruction is called, and changes the latched value each time 
-- the ADC is sampled. It also does something similar to rewrite 
-- the SDI signal based on user input during a write instruction.
--

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;


entity ADCPeripheral IS 
	PORT(
		io_addr 		: IN STD_LOGIC_VECTOR(10 DOWNTO 0); -- address
		io_write		: IN STD_LOGIC; -- write enable to set SDI config
		io_data 		: IN STD_LOGIC_VECTOR(11 DOWNTO 0); -- io_data config
		resetn  		: IN STD_LOGIC; -- reset signal
		clk	  		: IN STD_LOGIC; -- clock signal
		digitalRes	: OUT STD_LOGIC_VECTOR(11 DOWNTO 0) -- resolution of the peripheral
	);
END ADCPeripheral;


ARCHITECTURE arch OF ADCPeripheral IS
-- define the LTC_2308_ctrl file as a component of the peripheral
component LTC2308_ctrl
	generic(
	CTRL_DIV : integer := 1
	);
	port (
		-- define the same ports from LTC_2308_ctrl.vhd
		-- Control and data for this device
		clk      : in  std_logic;
		nrst     : in  std_logic;
		start    : in  std_logic;
		rx_data  : out std_logic_vector(11 downto 0);
		busy     : out std_logic;
		
		-- SPI Physical Interface
		sclk     : out std_logic; -- Serial clock
		conv     : out std_logic; -- Conversion start control
		mosi     : out std_logic; -- Data out from this device, in to ADC
		miso     : in  std_logic  -- Data out from ADC, in to this device
	);
	
	-- creating an instance of the controller with a port map
	ADC : LTC2308_ctrl
	port map(
		clk  => clk,
		nrst => nrst,
		start => start,
		rx_data=> rx_data,
		busy => busy,
		sclk => sclk,
		conv => conv,
		mosi => mosi,
		miso => miso
	);
	
	-- create more signals based on what we need the peripheral to do
	signal latched_SDI	: 	STD_LOGIC_VECTOR(11 DOWNTO 0)
	signal latched_SDO	:  STD_LOGIC_VECTOR(11 DOWNTO 0)
	
	-- define a state machine to interact with controller and SCOMP
	TYPE MODE_TYPE IS (IDLE, RUNNING);
	signal mode				: MODE_TYPE; -- define a signal to control state
	
	-- create a process block to define the peripheral
	PROCESS(clk)
	BEGIN
		-- write lines to make the controller sample data 
		-- from ADC by toggling start and checking busy flag
		-- check busy flag and update the data in MOSI
		-- check busy flag and get data to update Latched SDO
		
	END
	
	-- create a process block to define the read instruction of SCOMP
	PROCESS(clk, nrst, busy)
		--  nrst is on but busy is on dont reset, else reset
		-- if IO_READ is true return data from latched,SDO at datares
	BEGIN
	END
	-- create a process to define the write instruction of the SCOMP
	PROCESS(clk, nrst, busy)
	BEGIN
		-- if nrst is on but busy is on dont reset, else reset
		-- if IO_WRITE is true rewrite data in latched_SDO
	END
END arch;
