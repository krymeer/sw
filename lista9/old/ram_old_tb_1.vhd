-- Author: Krzysztof R. Osada, 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.appendix.all;

entity ram_old_tb is
end ram_old_tb;

architecture behaviour of ram_old_tb is
  component ram_2805 is
  port(
    clk: in std_logic;
    to_write: in std_logic;
    address: in std_logic_vector(4 downto 0);
    data_in: in std_logic_vector(8 downto 0);
    data_out: out std_logic_vector(8 downto 0)
  );
  end component;

  -- inputs
  signal clk: std_logic := '0';
  signal to_write: std_logic := '0';
  signal address: std_logic_vector(4 downto 0) := (others => '0');
  signal data_in: std_logic_vector(8 downto 0) := (others => '0');

  -- output
  signal data_out: std_logic_vector(8 downto 0);

  -- clock period definition 
  constant clk_period: time := 10 ns;

begin

  -- Instatiating the UUT
  uut: ram_2805
  port map(
    clk => clk,
    to_write => to_write,
    address => address,
    data_in => data_in,
    data_out => data_out
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

    file_open(marie_file, "marie_input.txt", read_mode);
    while not endfile(marie_file) loop
      readline(marie_file, line_r);
      read(line_r, data_s);
      data_v := string_to_std_logic_vector(data_s);

      to_write <= '1';
      address <= std_logic_vector(to_unsigned(ctr, address'length));
      data_in <= data_v;

      wait for clk_period;

      ctr := ctr+1;
    end loop;

    to_write <= '0';
    data_in <= (others => '0');
    wait for clk_period;

    new_line;
    write_s("Displaying the content of the RAM entity:");
    new_line;
    for i in 0 to ctr-1 loop
      address <= std_logic_vector(to_unsigned(i, address'length));
      wait for clk_period;
      write_v(data_out);
    end loop;
    new_line;

    wait;

  end process;
end;
