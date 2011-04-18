-- Time-stamp: <18/04/2011 09:09 paul.bonaud@etu.enseeiht.fr>
Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity TxUnit is
  port (clk, reset  : in std_logic;
        enable      : in std_logic;
        ld          : in std_logic;     -- load
        txd         : out std_logic;
        
        regE        : out std_logic;    -- Register Empty?
        bufE        : out std_logic;    -- Buffer Empty?
        data        : in std_logic_vector(7 downto 0)
        );
end TxUnit;

architecture TxUnit_impl of TxUnit is
  signal buf : std_logic_vector(7 downto 0);
  signal reg : std_logic_vector(7 downto 0);
  signal bufEPerso : std_logic := '1';
  signal regEPerso : std_logic := '1';
  signal startTx : std_logic := '0';
  signal once, started : std_logic := '0';
  signal finished : std_logic_vector(1 downto 0) := "00";
  
  signal state : std_logic_vector(1 downto 0) := "11";
  signal state_tx : std_logic_vector(1 downto 0) := "00";
begin

  -- initiate personnal signals
  bufE <= bufEPerso;
  regE <= regEPerso;
  
  -- purpose: Buffer and Register states
  -- type   : sequential
  process (clk, reset)
  begin  -- process
    if reset = '0' then               -- asynchronous reset (active low)
      bufEPerso <= '1';
      regEPerso <= '1';
      state <= "11";
      startTx <= '0';
      once <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      case state is
        when "00" =>                  -- load Buffer
          buf <= data;
          bufEPerso <= '0';            
          state <= "01";
        when "01" =>                  -- Buffer Filled, load reg
          if regEPerso = '1' then
            reg <= buf;
            startTx <= '1';
            regEPerso <= '0';
            bufEPerso <= '1';
            once <= '1';
          end if;

          state <= "11";
          
        when "11" =>                    -- Wait other automate (idle)
          if ld = '1' and bufEPerso = '1' then
            state <= "00";
          end if;

          if bufEPerso = '0' then
            state <= "01";
          end if;          

          if started = '1' then
            once <= '0';
          end if;

          if once = '0' and finished = "11" then  -- after communication
                                                  -- between the two automatons
                                                  -- really finish the TX
            regEPerso <= '1';
            startTx <= '0';
            once <= '1';
          end if;          
                      
        when others => null;
      end case;
    end if;
  end process;

  -- purpose: Transimition automaton
  -- type   : sequential
  process (enable, reset)
    variable i : natural range 7 downto 0 := 7;
    variable parity : std_logic := '0';
  begin  -- process
    if reset = '0' then               -- asynchronous reset (active low)
      txd <= '1';
      state_tx <= "00";
      i := 7;
      parity := '0';
      finished <= "00";
      started <= '0';
    elsif enable'event and enable = '1' then  -- rising clock edge
      if startTx = '1' then           -- Do we have to send something?
        case state_tx is
          when "00" =>                  -- Start bit = '0' Tx
            finished <= "00";
            txd <= '0';
            state_tx <= "01";
            started <= '1';
          when "01" =>                  -- Data Tx bit per bit
            txd <= reg(i);
            parity := parity xor reg(i);
            if i = 0 then
              i := 7;
              state_tx <= "10";
            else
              i := i-1;              
            end if;
          when "10" =>                  -- Parity Tx
            finished <= "01";           
            txd <= parity;
            state_tx <= "11";
          when "11" =>                  -- Stop bit = '1' Tx and idle state
            txd <= '1';
            state_tx <= "00";
            finished <= "11";
            started <= '0';
          when others => null;
        end case;
      end if;
    end if;
  end process;
  
end TxUnit_impl;

