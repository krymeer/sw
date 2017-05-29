-- Author: Krzysztof R. Osada, 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.appendix.all;

entity ram_tb is
end ram_tb;

architecture behaviour of ram_tb is
  component ram is
  port (
    conn_bus: inout std_logic_vector(8 downto 0);
    clk: in std_logic
  );
  end component;

  -- inout bus
  signal conn_bus: std_logic_vector(8 downto 0) := (others => 'Z');

  -- input clock
  signal clk: std_logic := '0';

  -- clock period definition 
  constant clk_period: time := 10 ns;

begin

  -- Instatiating the UUT
  uut: ram
  port map(
    conn_bus => conn_bus,
    clk => clk
  );

  -- clock process definition
  clk_process: process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  -- Testing the RAM entity...
  read_file: process
    variable line_r: line;
    variable ctr: integer := 0;
    variable data_v: std_logic_vector(8 downto 0);
    variable data_s: string(1 to 9);
    file marie_file: text;
  begin
    wait for 100 ns;

    -- Reading contents of a given file
    file_open(marie_file, "marie_input.txt", read_mode);
    while not endfile(marie_file) loop
      readline(marie_file, line_r);
      read(line_r, data_s);
      -- Converting a string to a std_logic_vector
      data_v := string_to_std_logic_vector(data_s);

      -- Storing a value at an address in the memory
      conn_bus <= "111100001";
      wait for clk_period;
      conn_bus <= std_logic_vector(to_unsigned(ctr, conn_bus'length));
      wait for clk_period;
      conn_bus <= data_v;
      wait for clk_period;

      ctr := ctr+1;
    end loop;

    wait for clk_period;

    new_line;
    write_s("Displaying contents of the RAM entity:");
    new_line;
    for i in 0 to ctr-1 loop
      -- Reading a value stored at a given address in the memory
      conn_bus <= "111100000";
      wait for clk_period;
      conn_bus <= std_logic_vector(to_unsigned(i, conn_bus'length));
      wait for clk_period;
      -- Enabling the RAM entity to write on the bus
      conn_bus <= (others => 'Z');
      wait for clk_period;
      write_v(conn_bus);
      wait for clk_period;
      
    end loop;
    new_line;

    wait;

  end process;
end;