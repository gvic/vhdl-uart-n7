-- Time-stamp: <04/04/2011 20:49 paul.bonaud@etu.enseeiht.fr>
library IEEE;
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
  begin

    -- initially txd = 1
    txd <= '1';

    -- purpose: Buffer and Register states
    -- type   : sequential
    process (clk, reset)
      variable state : std_logic_vector(1 downto 0) := "00";
    begin  -- process
      if reset = '0' then               -- asynchronous reset (active low)
        bufE <= '1';
        regE <= '1';
        state := "00";
      elsif clk'event and clk = '1' then  -- rising clock edge
        case state is
          when "00" =>                  -- idle
            if ld = '1' then
              buf <= data;
              bufE <= '0';
              state := "01";
            end if;
          when "01" =>                  -- Buffer filled
            reg <= buf;
            regE <= '0';
            bufE <= '1';
            state := "10";
          when "10" =>                  -- Register filled
            if ld = '1' and bufE = '1' then
              buf <= data;
              bufE <= '0';
            elsif bufE = '0' and regE = '1' then
              state := "01";
            elsif bufE = '1' and regE = '1' then
              state := "00";
            end if;                     
          when others => null;
        end case;
      end if;
    end process;

    -- purpose: Transimition automaton
    -- type   : sequen1tial
    process (enable, reset)
      variable state_tx : std_logic_vector(1 downto 0) := "00";
      variable i : natural range 7 downto 0 := 7;
      variable parity : boolean := false;
    begin  -- process
      if reset = '0' then               -- asynchronous reset (active low)
        txd <= '1';
        state_tx := "00";
        i := 7;
        parity := false;
      elsif enable'event and enable = '1' then  -- rising clock edge
        case state_tx is
          when "00" =>                  -- Start bit = '0' Tx
            txd <= '0';
            state_tx := "01";
          when "01" =>                  -- Data Tx bit per bit
            txd <= reg(i);
            parity := parity xor reg(i);
            if i = 0 then
              i := 7;
              state_tx := "10";
              regE <= '1';              -- The register is now empty!
            else
              i := i-1;              
            end if;
          when "10" =>                  -- Parity Tx
            txd <= parity;
            state := "11";
          when "11" =>                  -- Stop bit = '1' Tx and idle state
            txd <= '1';
            if regE = '0' then
              state_tx := "00";
            end if;            
          when others => null;
        end case;
      end if;
    end process;
    
end TxUnit_impl;

