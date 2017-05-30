-- Author: Krzysztof R. Osada, 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc is
  port (
    ctrl_pulse: in std_logic;
    conn_bus: inout std_logic_vector(8 downto 0)
  );
end pc;

-- A simple implementation of the PC architecture
architecture arch of pc is

  -- A PC register that holds a currently pointed instruction
  signal pc_reg: unsigned(8 downto 0) := (others => '0');

  -- A "bool" signal used when a program jump is going to be made
  signal to_jump: std_logic := '0';

begin
  -- The PC waits for a signal from the controller
  process(ctrl_pulse)
    -- Ids of operations that may be executed
    variable jump: std_logic_vector(8 downto 0) := "111100010";
    variable skipcond: std_logic_vector(8 downto 0) := "111100011";
  begin
    if rising_edge(ctrl_pulse) then
      if conn_bus = jump then
      -- The PC register is going to be changed (completely) in next pulse
        to_jump <= '1';
      elsif conn_bus = skipcond then
      -- Skip one program instruction, more precisely: an address where it is stored
        pc_reg <= pc_reg + 1;
      elsif to_jump = '1' then
      -- Change the value [here: address] of the PC register 
        pc_reg <= unsigned(conn_bus);
        to_jump <= '0';
      else
      -- If a request from the controller comes, start a transmission
        conn_bus <= std_logic_vector(pc_reg);
        pc_reg <= pc_reg + 1;
      end if;
    else
    -- Stop transmitting data immediately
      conn_bus <= (others => 'Z');
    end if;
  end process;
end arch;