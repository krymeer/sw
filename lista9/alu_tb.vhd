-- Author: Krzysztof R. Osada, 2017

library ieee;
use work.appendix.all;
use ieee.std_logic_1164.all;

entity alu_tb is
end alu_tb;

architecture behaviour of alu_tb is
  component alu is
  port (
    conn_bus: inout std_logic_vector(8 downto 0);
    clk: in std_logic
  );
  end component;

  -- inout bus
  signal conn_bus: std_logic_vector(8 downto 0) := (others => 'Z');

  -- clock (only for testing)
  signal clk: std_logic := '0';

  -- clock period definition 
  constant clk_period: time := 10 ns;
begin

 -- Instatiating the UUT
  uut: alu
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

  -- Testing ALU and its features
  main_process: process
  begin
    wait for 100 ns;

  -- Adding operation
  --- arguments: 15 and 5
  --- expected result: 20 (000010100)

    conn_bus <= "111101101";
    wait for clk_period;

    conn_bus <= "000001111";
    wait for clk_period;

    conn_bus <= "000000101";
    wait for clk_period;

  -- Clearing the bus
    conn_bus <= (others => 'Z');
    wait for clk_period;

  -- Printing the result
    write_v(conn_bus);
    wait for clk_period;

  -- Subtracting operation
  --- arguments: 16 and 5
  --- expected result: 11 (000001011)

    conn_bus <= "111101110";
    wait for clk_period;

    conn_bus <= "000010000";
    wait for clk_period;

    conn_bus <= "000000101";
    wait for clk_period;

  -- Clearing the bus
    conn_bus <= (others => 'Z');
    wait for clk_period;

  -- Printing the result
    write_v(conn_bus);
    wait for clk_period;
    
    wait;
  end process;

end;