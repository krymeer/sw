-- Author: Krzysztof R. Osada, 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity ram is
  port (
    conn_bus: inout std_logic_vector(8 downto 0);
    clk: in std_logic
  );
end ram;

-- A simple implementation of the RAM architecture
architecture arch of ram is
  -- Building the array for the RAM
  constant address_width: integer := 5;
  type ram_arr is array(natural(2 ** address_width - 1) downto 0) 
    of std_logic_vector(8 downto 0);

  -- Declaring the RAM signal
  signal ram_s: ram_arr;

  -- A "bool" signal which says if the data is being sent at the moment
  signal sending: std_logic := '0';

  -- Possible states of the RAM entity
  type state_type is (IDLE, ASSIGN, LOAD, STORE);
  -- IDLE: when nothing new happens;
  -- ASSIGN: when there's an address to be assigned;
  -- LOAD: when the master needs a value stored at the specified address;
  -- STORE: when the master needs to store a value at the given adddress

  -- Initial state of the RAM entity
  signal current_state, next_state: state_type := IDLE;

  -- An address signal
  signal addr: std_logic_vector(4 downto 0) := (others => '0');

  -- A word that came from conn_bus and a possible memory output
  signal word, result: std_logic_vector(8 downto 0) := (others => '0');

begin
  
  -- Catching changes of the clock signal
  -- The current state of the RAM entity has to be updated
  state: process(clk)
  begin
    if rising_edge(clk) then
      word <= conn_bus;
      current_state <= next_state;
    end if;
  end process;

  nextstate: process(current_state, word)
    -- Ids of the RAM enitity's operations
    variable id_load: std_logic_vector(8 downto 0) := "111100000";
    variable id_store: std_logic_vector(8 downto 0) := "111100001";
    variable op: std_logic_vector(8 downto 0) := (others => '0');
  begin
    case current_state is
      -- Nothing new happens
      when IDLE =>
        if sending /= '1' and (word = id_load or word = id_store) then
          op := word;
          next_state <= ASSIGN;
        else
          next_state <= IDLE;
        end if;
        sending <= '0';
      -- There's an address to be used
      when ASSIGN =>
        addr <= conn_bus(4 downto 0);
        if op = id_load then
          next_state <= LOAD;
        else
          next_state <= STORE;
        end if;
      -- The value from the memory is going to be loaded on the bus
      when LOAD =>
        result <= ram_s(to_integer(unsigned(addr)));
        sending <= '1';
        next_state <= IDLE;
      -- The value given by the master is going to be stored
      when STORE =>
        ram_s(to_integer(unsigned(addr))) <= conn_bus;
        next_state <= IDLE;
      end case;
  end process;

  -- A value from the memory is loaded on the bus (if there's such a need)
  conn_bus <= result when sending = '1' else "ZZZZZZZZZ";
end arch;