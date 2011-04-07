library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity RxUnit is
  
  port (
    clk, reset       : in  std_logic;
    enable           : in  std_logic;
    rd               : in  std_logic;
    rxd              : in  std_logic;
    data             : out std_logic_vector(7 downto 0);
    FErr, OErr, DRdy : out std_logic
  );

end RXUnit;


architecture RxUnit_impl of RXUnit is

begin  -- RxUnit_impl


  process (enable, reset)

  begin  -- process
    if reset = '0' then                 -- asynchronous reset (active low)
      
    elsif enable'event and enable = '1' then  -- rising clock edge
      
    end if;
  end process;

end RxUnit_impl;
