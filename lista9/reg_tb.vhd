-- Author: Krzysztof R. Osada, 2017

library ieee;
use ieee.std_logic_1164.all;

entity reg_tb is
end reg_tb;

architecture behaviour of reg_tb is
  component reg is
  port(
    conn_bus: inout std_logic_vector(8 downto 0);
    clk: std_logic
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
  uut: reg
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

  -- Testing different MARIE registers
  -- Each register receives a value that ought to be stored in its memory
  -- When it's done, the master sends requests for those numbers in the reversed order  
  test_reg: process
  begin
    wait for 100 ns;

  -- MAR: set 25
    conn_bus <= "111100100";
    wait for clk_period;
    conn_bus <= "000011001";
    wait for clk_period;
  
  -- MBR: set 17
    conn_bus <= "111100110";
    wait for clk_period;
    conn_bus <= "000010001";
    wait for clk_period;

  -- AC: set 6
    conn_bus <= "111101000";
    wait for clk_period;
    conn_bus <= "000000110";
    wait for clk_period;

  -- inREG: set (a number entered by the user)
    conn_bus <= "111101010";
    wait for clk_period;
    conn_bus <= (others => 'Z');
    wait for clk_period;

  -- outREG: set and print
    conn_bus <= "111101100";
    wait for clk_period;
    conn_bus <= "000001111";
    wait for clk_period;

  -- inREG: get
    conn_bus <= "111101011";
    wait for clk_period;
    conn_bus <= (others => 'Z');
    wait for clk_period*2;

  -- AC: get (should be 6)
    conn_bus <= "111101001";
    wait for clk_period;
    conn_bus <= (others => 'Z');
    wait for clk_period*2;

  -- MBR: get (should be 17)
    conn_bus <= "111100111";
    wait for clk_period;
    conn_bus <= (others => 'Z');
    wait for clk_period*2;

  -- MAR: get (should be 25)
    conn_bus <= "111100101";
    wait for clk_period;
    conn_bus <= (others => 'Z');
    wait for clk_period*2;

    wait;
  end process;
end;