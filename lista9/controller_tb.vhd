-- Author: Krzysztof R. Osada, 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.appendix.all;

entity controller_tb is
end controller_tb;

architecture behaviour of controller_tb is
  -- RAM, a memory entity of the system
  component ram is
  port (
    conn_bus: inout std_logic_vector(8 downto 0);
    clk: in std_logic
  );
  end component;

  -- controller: the most important entity
  -- Reads MARIE programs and performs most of system actions
  component controller is
  port(
    clk: in std_logic;
    reading_done: in std_logic;
    ctrl_pulse: out std_logic;
    conn_bus: inout std_logic_vector(8 downto 0)
  );
  end component;

  -- PC: program counter
  -- Returns an address of the instruction to be executed
  component pc is
  port (
    ctrl_pulse: in std_logic;
    conn_bus: inout std_logic_vector(8 downto 0)
  );
  end component;

  -- inout bus
  signal conn_bus: std_logic_vector(8 downto 0) := (others => 'Z');

  -- inputs: "booleans" and a clock
  signal reading_done, clk, ctrl_pulse: std_logic := '0';

  -- clock period definition 
  constant clk_period: time := 10 ns;

begin

  -- Instatiating the UUTs
  ram_entity: ram
  port map(
    conn_bus => conn_bus,
    clk => clk
  );

  pc_entity: pc
  port map(
    ctrl_pulse => ctrl_pulse,
    conn_bus => conn_bus
  );

  ctrl_entity: controller
  port map(
    clk => clk,
    reading_done => reading_done,
    ctrl_pulse => ctrl_pulse,
    conn_bus => conn_bus
  );

  -- clock process definition
  clk_process: process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  -- Processing a file written in MARIE
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

    conn_bus <= (others => 'Z');
    wait for clk_period;

    -- Reading process finished
    -- The controller may now read the system memory
    reading_done <= '1';

    wait;

  end process;
end;