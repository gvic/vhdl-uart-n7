entity RXUnit is
  
  port (
    clk, reset       : in  std_logic;
    enable           : in  std_logic;
    rd               : in  std_logic;
    rxd              : in  std_logic;
    data             : out std_logic_vector(7 downto 0);
    FErr, OErr, DRdy : out std_logic
  );

end RXUnit;
