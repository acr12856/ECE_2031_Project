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
		io_data 		: INOUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- io_data config
		io_read		: IN STD_LOGIC; -- io read signal
		nrst  		: IN STD_LOGIC; -- reset signal
		clk	  		: IN STD_LOGIC; -- clock signal
		
		adc_miso		: IN STD_LOGIC; 
		adc_mosi 	: OUT STD_LOGIC;
		adc_sclk		: OUT STD_LOGIC;
		adc_conv		: OUT	STD_LOGIC
	);
END ADCPeripheral;


ARCHITECTURE arch OF ADCPeripheral IS
-- define the LTC_2308_ctrl file as a component of the peripheral
component LTC2308_ctrl
	generic(
	CLK_DIV : integer := 1
	);
	port (
		-- define the same ports from LTC_2308_ctrl.vhd
		-- Control and data for this device
		clk      : in  std_logic;
		nrst     : in  std_logic;
		start    : in  std_logic;
		tx_data	: in	std_logic_vector(11 downto 0);
		rx_data  : out std_logic_vector(11 downto 0);
		busy     : out std_logic;
		
		-- SPI Physical Interface
		sclk     : out std_logic; -- Serial clock
		conv     : out std_logic; -- Conversion start control
		mosi     : out std_logic; -- Data out from this device, in to ADC
		miso     : in  std_logic  -- Data out from ADC, in to this device
	);
	end component;
	
	-- declare signals from the component above
	signal start 			:  STD_LOGIC;
	signal busy				:  STD_LOGIC;
	signal rx_data			:  STD_LOGIC_VECTOR(11 DOWNTO 0);
	
	-- create more signals based on what we need the peripheral to do
	signal latched_SDI	: 	STD_LOGIC_VECTOR(11 DOWNTO 0)	:= "100010000000";
	signal latched_SDO	:  STD_LOGIC_VECTOR(11 DOWNTO 0);
	
	
	BEGIN
	
		-- creating an instance of the controller with a port map
	ADC : LTC2308_ctrl
	port map(
		clk  => clk,
		nrst => nrst,
		start => start,
		tx_data => latched_SDI,
		rx_data=> rx_data,
		busy => busy,
		sclk => adc_sclk,
		conv => adc_conv,
		mosi => adc_mosi,
		miso => adc_miso
	);
	
	-- if we try to read from it, then read the data
	io_data <= "0000" & latched_SDO
	when(io_read = '1' and io_addr = "00011000000")
	else (others => 'Z');
	
	
	-- if we try to write to the peripheral, write data to latched_SDI
	PROCESS(clk)
	BEGIN
		if rising_edge(clk) then
			if io_addr = "00011000000" and io_write = '1' then
				latched_SDI <= io_data(11 DOWNTO 0);
			end if;
		end if;
	END PROCESS;
	
	
	-- if busy flag is on, then start a new conversation and latch the previous values
	PROCESS(clk, nrst)
	BEGIN
		if nrst = '0' then
			start <= '0';
		elsif rising_edge(clk) then
			if busy = '0' then
				start <= '1';
				latched_SDO <= rx_data;
			else
				start <= '0';
			end if;
		end if;
	END PROCESS;
END arch;