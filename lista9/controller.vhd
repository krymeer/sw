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
  -- Possible states of the controller
  -- THe list includes a few "dirty" workarounds, unfortunalely
  type state_type is (IDLE, CALL_PC, GET_ADDR, SET_ADDR, STOP_SEND, GET_WORD, DECODE);

  -- Initial state of the entity
  signal current_state, next_state: state_type := IDLE;

  -- "Booleans" allowing or forbidding the entity to perform an action 
  signal end_of_program, sending: std_logic := '0';

  -- An address at the memory (RAM)
  signal address: std_logic_vector(8 downto 0);

  -- Bus words: the first one which arrives, and the second one that could be returned
  signal word, ctrl_reg: std_logic_vector(8 downto 0) := (others => '0');

begin

  -- Note: both of processes peform actions only when reading a file is done

  state: process(clk)
  begin
    if rising_edge(clk) and reading_done = '1' then
      word <= conn_bus;
      current_state <= next_state;
    end if;
  end process;

  nextstate: process(current_state, word)
    variable opcode: std_logic_vector(3 downto 0);
  begin
    if reading_done = '1' then
      case current_state is
        when IDLE =>
          -- Get an address from the PC entity
          if end_of_program = '0' then
            ctrl_pulse <= '1';
            next_state <= GET_ADDR;
          -- Nothing new happened, go on
          else
            next_state <= IDLE;
          end if;
        -- Get the address and call the RAM entity
        when GET_ADDR =>
          address <= conn_bus;
          ctrl_pulse <= '0';
          ctrl_reg <= "111100000";
          sending <= '1';
          next_state <= SET_ADDR;
        -- Send the address to the RAM entity
        when SET_ADDR =>
          ctrl_reg <= address;
          next_state <= STOP_SEND;
        -- Stop sending the address
        when STOP_SEND =>
          sending <= '0';
          next_state <= GET_WORD;
        -- Wait for the value from the RAM entity
        when GET_WORD =>
          next_state <= DECODE;       
        -- Decode the word
        when DECODE =>
          write_v(conn_bus);
          opcode := conn_bus(8 downto 5);
          if opcode = "0111" then
            end_of_program <= '1';
          end if;
          next_state <= IDLE;
        -- Otherwise stay idle
        when others =>
          next_state <= IDLE;
      end case;
    end if;
  end process;

  conn_bus <= ctrl_reg when sending = '1' else (others => 'Z');  
end arch;
