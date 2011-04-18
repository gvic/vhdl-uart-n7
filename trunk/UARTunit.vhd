-- Time-stamp: <18/04/2011 09:30 paul.bonaud@etu.enseeiht.fr>
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

architecture UARTunit_impl of UARTunit is

begin  -- UARTunit_impl

  component TxUnit
    port (
      clk, reset : in   std_logic;
      enable     : in   std_logic;
      ld         : in   std_logic;
      txd        : out  std_logic;
      regE       : out  std_logic;
      bufE       : out  std_logic;
      data       : in   std_logic_vector(7 downto 0)
      );
  end component;

  component RxUnit
    port (
      clk, reset       : in  std_logic;
      enable           : in  std_logic;
      rd               : in  std_logic;
      rxd              : in  std_logic;
      data             : out std_logic_vector(7 downto 0);
      FErr, OErr, DRdy : out std_logic
      );    
  end component;
  
  component clkUnit
    port (
      clk, reset : in  std_logic;
      enableTX   : out std_logic;
      enableRX   : out std_logic
      );
  end component;
  

end UARTunit_impl;
