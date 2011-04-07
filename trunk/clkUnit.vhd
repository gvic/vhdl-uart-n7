-- Time-stamp: <04/04/2011 19:54 paul.bonaud@etu.enseeiht.fr>
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity clkUnit is
  port (clk, reset  : in std_logic;
        enableTX    : out std_logic;    -- 9.6 kHz
        enableRX    : out std_logic    -- 155 kHz
        );
end clkUnit;

architecture clkUnit_impl of clkUnit is
  signal div : std_logic_vector(3 downto 0) := "0000";
  begin
    -- enableRX receives the clk when reset != 0
    enableRX <= '0' when reset = '0' else clk;

    -- purpose: Clock divider
    -- type   : sequential
    -- inputs : clk, reset
    process (clk, reset)
    begin  -- process
      if reset = '0' then               -- asynchronous reset (active low)
        enableTX <= '0';
        div <= "0000";
      elsif clk'event and clk = '1' then  -- rising clock edge
        div <= div + 1;
        if div = "0000" then
          enableTX <= '1';
        else
          enableTX <= '0';
        end if;        
      end if;
    end process;
    
end clkUnit_impl;

