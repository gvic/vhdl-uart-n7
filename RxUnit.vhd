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

  signal tmpclk : std_logic;
  signal tmprxd : std_logic;
  signal fin_transmission : std_logic_vector(1 downto 0);
  
begin  -- RxUnit_impl
  
  p_compteur16: process (enable, reset)
    variable cptBit : integer := 0;     -- compte le nombre de bit recu
    variable cptClk : integer := 0;     -- compte le nombre de top de enable
    signal state : std_logic_vector(3 downto 0) := 000;  -- code les etats de l'automate
  begin  -- process p_compteur16
    if reset = '0' then                 -- asynchronous reset (active low)
      cptClk := 0;
      cptBit := 0;
      state <= "000";
    elsif enable'event and enable = '1' then  -- rising clock edge
      cptClk <= cptClk + 1;
      case state is
        when "000" =>
          if rxd = '0' then
            state <= "001";
            cptClk := '0';        
          end if;
        when "001" =>
          if cptClk > 7 then
            state <= "010";
            tmpclk <= '1';
            cptClk := '0';
          end if;
        when "010" =>                   -- Etat fin transmission
          if cptClk > 15 then           
            tmpclk <= '1';
            cptClk := '0';
          end if;
          if fin_transmission = "11" then
            state <= "000";
          end if;
        when others => null;
      end case;

      
    end if;
  end process p_compteur16;

  
  -- purpose: automaton of reception control
  -- type   : combinational
  -- inputs : tmpclk
  -- outputs: 
  p_control: process (tmpclk,reset)

    signal state : std_logic_vector(1 downto 0) := "00";
    signal compteur : integer := 7;     -- needed for counting the 8 bits on tmprxd
    variable parity_calc : std_logic := '0';
    variable parity_recieved : std_logic;
  begin  -- process p_control
    if reset = '0' then                 -- asynchronous reset (active low)
      parity_calc := '0';
      parity_recieved := '0';
      compteur <= 0;
      state <= "00";
    elsif tmpclk'event and tmpclk = '1' then  -- rising clock edge
      case state is
        when "00" =>                      -- Waiting for start bit
          if tmprxd = '0' then
            state <= "01";      -- Switch to datas reception state
          end if;
        when "01" =>                    -- Reception of data bits and parity bit state
          if compteur = -1 then
          parity_recieved := rxd;
          state <= "10";        -- Handling finished
          elsif compteur < 0 then       -- Handled data reception
            data(compteur) <= rxd;
            parity_calc := parity_calc xor rxd;
            compteur <= compteur - 1;
          end if;
        when "10" =>                    -- Stop bit reception state
          if parity_recieved /= parity_calc or rxd = '0' then
            FErr <= '1';
          else
            Drdy <= '1';
          end if;

          if Drdy = '1' and rd = '1' then
            -- Datas transfered to the processor
          elsif "to be defined" then
            
            OErr <= '1';
          end if;
          
        when "11" =>
          
        when others => null;
      end case;
    end if;
  end process p_control;

end RxUnit_impl;


