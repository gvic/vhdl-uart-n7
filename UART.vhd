library IEEE;
use IEEE.std_logic_1164.all;

entity UARTunit is
  port (
    clk, reset : in  std_logic;
    cs, rd, wr : in  std_logic;
    RxD        : in  std_logic;
    TxD        : out std_logic;
    IntR       : out std_logic;        
    IntT       : out std_logic;         
    addr       : in  std_logic_vector(1 downto 0);
    data_in    : in  std_logic_vector(7 downto 0);
    data_out   : out std_logic_vector(7 downto 0);
	 state_tx   : out std_logic_vector(1 downto 0));
end UARTunit;
architecture UARTunit_arch of UARTunit is

  -- interface des differents composants
  -- de l'UART
  component TxUnit
    port (
      clk, reset : in   std_logic;
      enable     : in   std_logic;
      ld         : in   std_logic;
      txd        : out  std_logic;
      regE       : out  std_logic;
      bufE       : out  std_logic;
      data       : in   std_logic_vector(7 downto 0);
		state_tx2   : out std_logic_vector(1 downto 0)
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

  component ctrlUnit is
    port (
      clk, reset       : in  std_logic;
      rd, wr           : in  std_logic;
      DRdy, FErr, OErr : in  std_logic;
      BufE, RegE       : in  std_logic;
      IntR             : out std_logic;
      IntT             : out std_logic;
      ctrlReg          : out std_logic_vector(7 downto 0));
  end component;
  -- ----------------------
  
  signal lecture, ecriture : std_logic;
  signal donnees_recues : std_logic_vector(7 downto 0);
  signal registre_controle : std_logic_vector(7 downto 0);

  signal enableTX   :    std_logic;
  signal enableRX   :    std_logic;
  signal regE       :    std_logic;
  signal bufE       :    std_logic;
  signal FErr, OErr, DRdy : std_logic;  
  
begin  -- UARTunit_arch

  lecture <= '1' when cs = '0' and rd = '0' else '0';
  ecriture <= '1' when cs = '0' and wr = '0' else '0';
  data_out <= donnees_recues when lecture = '1' and addr = "00"
              else registre_controle when lecture = '1' and addr = "01"
              else "00000000";
  
  -- Connect and assemble all Units
  uniteHorloge: clkUnit port map (clk, reset, enableTX, enableRX);
  uniteEmission: TxUnit port map (clk, reset, enableTX, ecriture, TxD, regE, bufE, data_in,state_tx);
  uniteReception: RxUnit port map (clk, reset, enableRX, rd, RxD, donnees_recues, FErr, OErr, DRdy);
  uniteControl: ctrlUnit port map (clk, reset, rd, wr, DRdy, FErr, OErr, bufE, regE, IntR, IntT, registre_controle);


end UARTunit_arch;
