-- TODO: HEADER COMMENTS HERE 

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;

entity ADCPeripheral IS 
	PORT(
		io_addr 		: IN STD_LOGIC_VECTOR(10 DOWNTO 0); -- address
		io_write		: IN STD_LOGIC; -- write enable to set SDI config
		io_data 		: IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- io_data config
		resetn  		: IN STD_LOGIC; -- reset signal
		clk	  		: IN STD_LOGIC; -- clock signal
		digitalRes	: OUT STD_LOGIC_VECTOR(11 DOWNTO 0) -- resolution of the peripheral
	);
END ADCPeripheral;


ARCHITECTURE arch OF ADCPeripheral IS
	-- define state machine
	TYPE mode_type IS (); -- TODO: define states
	
	-- signal to track modes and output
	SIGNAL mode		  : mode_type; -- tracks current state
	SIGNAL digitalRes: STD_LOGIC_VECTOR(11 DOWNTO 0);

	-- signals from register map of ADC
	SIGNAL odd			: STD_LOGIC := '0'; -- can modify
	SIGNAL single		: STD_LOGIC := '1';
	SIGNAL selectOne	: STD_LOGIC := '0'; -- can modify
	SIGNAL SelectZero	: STD_LOGIC := '0'; -- can modify
	SIGNAL unipolar	: STD_LOGIC := '1';
	SIGNAL sleep		: STD_LOGIC := '0';
	
	-- describe a signal for SDI
	SIGNAL SDI			: STD_LOGIC_VECTOR(5 DOWNTO 0);
	
	-- buffer to store temporary value
	SIGNAL latched_SDO: STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL latched_SDI: STD_LOGIC_VECTOR(5 DOWNTO 0);
	
	-- internal signal to update latched_SDO
	SIGNAL updateSDO	: STD_LOGIC:= '0';
	SIGNAL updateSDI	: STD_LOGIC:= '0';
	SIGNAL toggleWrite: STD_logic:= '0';
	
	
	BEGIN
	-- control signal for latching SDO value
	updateSDO <= '1' -- TODO: complete this definition
	
	-- assign SDI based on input (io_data)
	odd <= io_data(2);
	selectZero <= io_data(1);
	selectOne <= io_data(0);
	
	-- TODO: write a process block to define how the peripheral works
	
	
	-- define SDI 
	SDI <= single & odd & selectOne & selectZero & unipolar & sleep;
END arch;