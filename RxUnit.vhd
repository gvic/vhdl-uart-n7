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
  signal active_controller : std_logic := '0';  -- booleen pour demarer l'automate du controller
  signal cpt_state : std_logic_vector(2 downto 0) := "000";  -- code les etats de l'automate

  signal control_state : std_logic_vector(1 downto 0) := "00";
  signal compteur : integer := 7;     -- needed for counting the 8 bits on tmprxd


begin  -- RxUnit_impl
  
  p_compteur16: process (enable, reset)
    variable cptBit : integer := 0;     -- compte le nombre de bit recu
    variable cptClk : integer := 0;     -- compte le nombre de top de enable
  begin  -- process p_compteur16
    if reset = '0' then                 -- asynchronous reset (active low)
      cptClk := 0;
      cptBit := 0;
      cpt_state <= "000";
      tmprxd <= '0';
      tmpclk <= '0';
      active_controller <= '0';
    elsif enable'event and enable = '1' then  -- rising clock edge
      cptClk := cptClk + 1;
      active_controller <= '0';
      case cpt_state is
        when "000" =>
          if rxd = '0' then
            cpt_state <= "001";
            cptClk := 0;
          else
            cpt_state <= "000";
          end if;
        when "001" =>                   -- start bit reception
          if cptClk > 7 then
            cpt_state <= "010";
            tmpclk <= '1';
            cptClk := 0;
            active_controller <= '1';
          else
            tmpclk <= '0';
            cpt_state <= "001";
          end if;
        when "010" =>                   -- Etat fin transmission
          if cptClk > 15 then           
            tmpclk <= '1';
            cptClk := 0;
            if rd = '0' and compteur = -1 then -- si rd=0 et que les 8 bits on été recu
              cpt_state <= "011";
            elsif rd = '1' then
              DRdy <= '0';
              tmprxd <= rxd;
            end if;
          else
            tmpclk <= '0';
          end if;
          if fin_transmission = "11" then
            cpt_state <= "000";
          end if;
        when "011" =>                   -- on attent un front montant d'horloge
          if rd = '0' then              -- avant de mettre OErr a 1
            OErr <= '1';
          end if;
          cpt_state <= "000";
        when others => null;
      end case;

      
    end if;
  end process p_compteur16;

  
  -- purpose: automaton of reception control
  -- type   : sequential
  -- inputs : tmpclk
  -- outputs: 
  p_control: process (tmpclk,reset)
    variable parity_calc : std_logic := '0';
    variable parity_recieved : std_logic;
  begin  -- process p_control
    if reset = '0' then                 -- asynchronous reset (active low)
      parity_calc := '0';
      parity_recieved := '0';
      compteur <= 7;
      control_state <= "00";
    elsif tmpclk'event and tmpclk = '1' then  -- rising clock edge
      case control_state is
        when "00" =>                      -- Waiting for start bit
          if tmprxd = '0' and compteur = 7 then
            control_state <= "01";      -- Switch to datas reception control_state, on ne garde
                                -- pas le bit de start, on conserve que les
                                -- réelles données
          end if;
        when "01" =>                    -- Reception of data bits and parity bit control_state
          if compteur = -1 then
            parity_recieved := rxd;
            control_state <= "10";        -- Handling finished
          else                -- Handled data reception
            data(compteur) <= rxd;
            parity_calc := parity_calc xor rxd;
            compteur <= compteur - 1;
          end if;
        when "10" =>                    -- Stop bit reception control_state
          if parity_recieved = parity_calc and rxd = '1' then
            Drdy <= '1';
          else
            FErr <= '1';
          end if;
          control_state <= "11";
        when "11" =>
          fin_transmission <= "11";
          control_state <= "00";
          compteur <= 7;
        when others => null;
      end case;
    end if;
  end process p_control;

end RxUnit_impl;


