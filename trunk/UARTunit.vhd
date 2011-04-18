-- Time-stamp: <18/04/2011 09:24 paul.bonaud@etu.enseeiht.fr>
Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity UARTunit is
  port (
    clk, reset  : in    std_logic;
    cs, rd, wr  : in    std_logic;
    RxD         : in    std_logic;
    TxD         : out   std_logic;
    IntR, IntT  : out   std_logic;
    addr        : in    std_logic_vector(1 downto 0);
    data_in     : in    std_logic_vector(7 downto 0);
    data_out    : out   std_logic_vector(7 downto 0)
    );    
end UARTunit;
