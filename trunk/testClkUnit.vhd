--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:27:56 04/07/2011
-- Design Name:   
-- Module Name:   /home/pbonaud/Travail/2A/VHDL/VHDL/SOURCES/UART8bits/testClkUnit.vhd
-- Project Name:  UART8bits
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: clkUnit
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY testClkUnit IS
END testClkUnit;
 
ARCHITECTURE behavior OF testClkUnit IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT clkUnit
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         enableTX : OUT  std_logic;
         enableRX : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal enableTX : std_logic;
   signal enableRX : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: clkUnit PORT MAP (
          clk => clk,
          reset => reset,
          enableTX => enableTX,
          enableRX => enableRX
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		reset <= '1';

      wait for clk_period*10;

      -- insert stimulus here 
		

      wait;
   end process;

END;
