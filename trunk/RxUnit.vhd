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
  signal fin_transmission : std_logic_vector(1 downto 0) := "00";
  signal cpt_state : std_logic_vector(2 downto 0) := "000";  -- code les etats de l'automate

  signal DRdyPerso : std_logic := '0';
  signal FErrPerso : std_logic := '0';
  
  signal control_state : std_logic_vector(1 downto 0) := "00";
  signal compteur : integer := 7;     -- needed for counting the 8 bits on tmprxd

  signal ask_for_enable_edge : std_logic := '0';
  signal top_enable : std_logic := '0';

  signal sd : std_logic_vector(7 downto 0) := "00000000";  -- on stock le message recu dans ce signal avant de le transmettre au pocesseur
begin  -- RxUnit_impl

  -- Because I wan't to read DRdy
  DRdy <= DRdyPerso;
  FErr <= FErrPerso;
  
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
      DRdyPerso <= '0';
      OErr <= '0';
      FErrPerso <= '0';
      data <= "00000000";
    elsif enable'event and enable = '1' then  -- rising clock edge
      cptClk := cptClk + 1;
      case cpt_state is
        
        when "000" =>
          FErrPerso <= '0';
          DRdyPerso <= '0';
          OErr <= '0';
          
          if rxd = '0' then
            cpt_state <= "001";
            cptClk := 0;
          end if;
          
        when "001" =>                   -- start bit reception
          if cptClk > 7 then
            cpt_state <= "010";
            tmpclk <= '1';
            cptClk := 0;
          else
            tmpclk <= '0';
          end if;
          
        when "010" =>                   -- Etat fin transmission
          OErr <= '0';
          if cptClk > 15 then           
            tmprxd <= rxd; -- Receive bit
            tmpclk <= '1';
            cptClk := 0;
          else
            tmpclk <= '0';
          end if;
          
          if fin_transmission = "01" then
            FErrPerso <= '0';
            DrdyPerso <= '1';            
          elsif fin_transmission = "11" then
            FErrPerso <= '1';
            DrdyPerso <= '0';                        
          end if;
          
          if DRdyPerso = '1' then            -- Data received  without errors
            DRdyPerso <= '0';
            -- waiting for rd!
            if rd = '1' then
              data <= sd;               -- Tranfer data to CPU
              cpt_state <= "000";
				  
				  cptBit := 0;
				  tmprxd <= '0';
              tmpclk <= '0';
				  OErr <= '0';
				  
            elsif rd = '0' then
              OErr <= '1';
              cpt_state <= "000";
            end if;
          end if;

          if FErrPerso = '1' then
            FErrPerso <= '0';
            cpt_state <= "000";
          end if;
          
        when "011" =>                   
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
    variable parity_recieved : std_logic := '0';
  begin  -- process p_control
    if reset = '0' then                 -- asynchronous reset (active low)
      parity_calc := '0';
      parity_recieved := '0';
      compteur <= 7;
      control_state <= "00";
      fin_transmission <= "00";
    elsif tmpclk'event and tmpclk = '1' then  -- rising clock edge
      case control_state is
        when "00" =>                      -- Waiting for start bit
          fin_transmission <= "00";
          if tmprxd = '0' and compteur = 7 then
            control_state <= "01";      -- Switch to datas reception control_state
            -- on ne garde pas le bit de start, on conserve que les données réellement utiles
          end if;
          
        when "01" =>                    -- Reception of data bits and parity bit control_state
          if compteur = -1 then
            parity_recieved := tmprxd;  -- on recupere le bit de parité envoyé
            control_state <= "10";
          else                -- Handled data reception
            sd(compteur) <= tmprxd;
            parity_calc := parity_calc xor tmprxd;
            compteur <= compteur - 1;
          end if;
          
        when "10" =>                    -- Stop bit reception control_state
          if parity_recieved = parity_calc and tmprxd = '1' then
            fin_transmission <= "01";          
            -- FErr <= '0';
            -- Drdy <= '1';
          else
            --FErr <= '1';
            --Drdy <= '0';
            fin_transmission <= "11";
          end if;
          control_state <= "00";
          compteur <= 7;
			 parity_calc := '0';
			 parity_recieved := '0';
          
        when others => null;
                       
      end case;
    end if;
  end process p_control;
end RxUnit_impl;
