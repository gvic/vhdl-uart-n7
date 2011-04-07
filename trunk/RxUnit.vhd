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

begin  -- RxUnit_impl

  -- purpose: automaton of reception control
  -- type   : combinational
  -- inputs : tmpclk
  -- outputs: 
  reception_control: process (tmpclk,reset)

    signal control_state : std_logic_vector(1 downto 0) := "00";
    signal compteur : integer := 7;     -- needed for counting the 8 bits on tmprxd
    variable parity_calc : std_logic := '0';
    variable parity_recieved : std_logic;
  begin  -- process reception_control
    if reset = '0' then                 -- asynchronous reset (active low)
      parity_calc := '0';      
    elsif tmpclk'event and tmpclk = '1' then  -- rising clock edge
      case control_state is
        when "00" =>                      -- Waiting for start bit
          if tmprxd = '0' then
            control_state <= "01";      -- Switch to datas reception state
          end if;
        when "01" =>                    -- Reception of data bits and parity bit state
          if compteur = -1 then
          parity_recieved := rxd;
          control_state <= "10";        -- Handling finished
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
  end process reception_control;

end RxUnit_impl;


