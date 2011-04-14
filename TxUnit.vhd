-- Time-stamp: <11/04/2011 09:46 paul.bonaud@etu.enseeiht.fr>
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

  signal state : std_logic_vector(1 downto 0) := "00";
  signal com_state : std_logic_vector(1 downto 0) := "11"; -- meant to be the same as above, but to communicate between the two process
  signal state_tx : std_logic_vector(1 downto 0) := "00";
begin

  -- initially txd = 1
  --txd <= '1';

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
      state <= "00";
      startTx <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      case state is
        when "00" =>                  -- idle
          startTx <= '0';
          if ld = '1' then
            buf <= data;
            bufEPerso <= '0';
            state <= "01";
          end if;
        when "01" =>                  -- Buffer Filled
          reg <= buf;
          regEPerso <= '0';
          bufEPerso <= '1';
          state <= "10";
        when "10" =>                  -- Register Filled
          startTx <= '1';
          state <= "11";
        when "11" =>                    -- Wait other automate
          if com_state = "01" then
            regEPerso <= '1';            -- Finished Transmission
            state <= "00";
          --elsif com_state = "10" then
          --  regEPerso <= '1';
          --  state <= "10";
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
      com_state <= "11";
    elsif enable'event and enable = '1' then  -- rising clock edge
      if startTx = '1' then           -- Do we have to send something?
        case state_tx is
          when "00" =>                  -- Start bit = '0' Tx
            com_state <= "11";
            txd <= '0';
            state_tx <= "01";
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
            txd <= parity;
            state_tx <= "11";
          when "11" =>                  -- Stop bit = '1' Tx and idle state
            txd <= '1';
            if regEPerso = '0' then     -- Should always be done
              state_tx <= "00";
              com_state <= "01";
            end if;            
          when others => null;
        end case;
      end if;
    end if;
  end process;
  
end TxUnit_impl;

