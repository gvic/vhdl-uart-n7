library IEEE;
use IEEE.std_logic_1164.all;
use work.n7.all;

entity testRxUnit0x55 is
 -- test d'une reception OK 
end testRxUnit0x55;

architecture testRxUnit_arch0x55 of testRxUnit0x55 is

  component RxUnit
  
  port (
    clk, reset       : in  std_logic;
    enable           : in  std_logic;
    rd               : in  std_logic;
    rxd              : in  std_logic;
    data             : out std_logic_vector(7 downto 0);
    Ferr, OErr, DRdy : out std_logic);

  end component;

  component clkUnit   
    port (
      clk, reset : in  std_logic;
      enableTX   : out std_logic;
      enableRX   : out std_logic);
    
  end component;
  
  signal clk, reset : std_logic;
  signal enableRX, enableTX: std_logic;
  signal rd, rxd : std_logic;
  signal data : std_logic_vector(7 downto 0);
  signal FErr, OErr, DRdy : std_logic;
  signal message : std_logic_vector(7 downto 0);
  
begin

  C: clock(clk, 25 ns, 0 ns, 15000 ns);

  uniteHorloge: clkUnit port map (clk, reset, enableTX, enableRX);

  uniteRcp: RxUnit port map (clk, reset, enableRX, rd, rxd, data, FErr, OErr, DRdy);

  reset <= '0', '1' after 65 ns;

  process
  begin  -- ce processus simule le comportement d'un emetteur et du processeur
    rd <= '0';
    rxd <= '1';
    wait until reset = '1';
    rxd <= '1';
    
    -- emission du caractere 0x55
    
    wait until enableTX='1';
    rxd <= '0'; -- bit de start
    wait until enableTX='0';
    
    message <= "01010101";
    for i in 7 downto 0 loop
      wait until enableTX = '1';
      rxd <= message(i);
      wait until enableTX = '0';
    end loop; 
 
    wait until enableTX = '1';
    rxd <= '0'; -- bit de parite
    wait until enableTX = '0';
	 
    wait until enableTX = '1';
    rxd <= '1'; -- bit de stop
    wait until enableTX = '0';
    
    wait until (DRdy = '1' or FErr = '1');
    -- lorsque le bit DRdy=1, on peut lire le resultat
    if DRdy = '1' then
      rd <= '1';
    end if;
    wait until (DRdy='0' or FErr = '0');
    
    wait for 100 ns;
    rd <= '0';
    
    wait;

  end process;
  
end testRxUnit_arch0x55;


