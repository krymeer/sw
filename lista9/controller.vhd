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
  type state_type is (IDLE, CALL_PC, CALL_RAM, SET_RAM_ADDR, GET_RAM_WORD, SET_OUTREG, OUTPUT_GET_AC, DECODE);

  -- Initial state of the entity
  signal current_state, next_state: state_type := IDLE;

  -- "Booleans" allowing or forbidding the entity to perform an action 
  signal end_of_program, sending: std_logic := '0';

  -- An address at the memory (RAM)
  signal address, value: std_logic_vector(8 downto 0);

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
            next_state <= CALL_RAM;
          -- Nothing new happened, go on
          else
            next_state <= IDLE;
          end if;
        -- Get the address and call the RAM entity
        when CALL_RAM =>
          address <= conn_bus;
          ctrl_pulse <= '0';
          ctrl_reg <= "111100000";
          sending <= '1';
          next_state <= SET_RAM_ADDR;
        -- Send the address to the RAM entity
        when SET_RAM_ADDR =>
          ctrl_reg <= address;
          next_state <= GET_RAM_WORD;
        -- Wait until a word from the RAM arrives
        when GET_RAM_WORD =>
          sending <= '0';
          if conn_bus /= address then
            next_state <= DECODE;
          end if;
        -- Decode the word
        when DECODE =>
          write_v(conn_bus);
          opcode := conn_bus(8 downto 5);
          -- Perform an operation depending on the opcode
          case opcode is
            when "0110" =>
              ctrl_reg <= "111101001";
              sending <= '1';
              next_state <= OUTPUT_GET_AC;
            when "0111" =>
              end_of_program <= '1';
              next_state <= IDLE;
            when others =>
              next_state <= IDLE;
          end case;
        -- When the value of the accumulator comes, call the outREG
        when OUTPUT_GET_AC =>
          sending <= '0';
          if conn_bus /= "ZZZZZZZZZ" and conn_bus /= "111101001" then
            value <= conn_bus;
            ctrl_reg <= "111101100"; 
            sending <= '1';           
            next_state <= SET_OUTREG;
          end if;
        -- Update the value of the outREG
        when SET_OUTREG =>
          if conn_bus = "ZZZZZZZZZ" then
            next_state <= IDLE;
          elsif conn_bus = "111101100" then
            ctrl_reg <= value;
          else
            sending <= '0';
          end if;
        when others =>
          next_state <= IDLE;
      end case;
    end if;
  end process;

  conn_bus <= ctrl_reg when sending = '1' else (others => 'Z');  
end arch;
