-- Author: Krzysztof R. Osada, 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.appendix.all;

entity controller is
  port(
    clk: in std_logic;
    reading_done: in std_logic;
    ctrl_pulse: out std_logic := '0';
    conn_bus: inout std_logic_vector(8 downto 0)
  );
end controller;

architecture arch of controller is
  type state_type is (IDLE, CALL_PC, GET_WORD, CALL_RAM, DECODE, EXECUTE, STORE);

  -- Initial state of the entity
  signal current_state, next_state: state_type := IDLE;

  signal end_of_program: std_logic := '0';

  signal address: std_logic_vector(8 downto 0);

  -- A word that came from conn_bus
  signal word: std_logic_vector(8 downto 0) := (others => '0');

  -- clock period definition 
  constant clk_period: time := 10 ns;

begin
  state: process(clk)
  begin
    if rising_edge(clk) and reading_done = '1' then
      word <= conn_bus;
      current_state <= next_state;
    end if;
  end process;

  nextstate: process(current_state)--, word)
  begin
    if reading_done = '1' then
      case current_state is
        when IDLE =>
          if end_of_program = '0' then
            ctrl_pulse <= '1';
            next_state <= CALL_PC;
          else
            next_state <= IDLE;
          end if;
        when CALL_PC =>
          address <= conn_bus;
          ctrl_pulse <= '0';
      
        when others =>
          next_state <= IDLE;
      end case;
    end if;
  end process;
end arch;
