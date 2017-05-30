-- Author: Krzysztof R. Osada, 2017

library ieee;
use ieee.std_logic_1164.all;

entity pc_tb is
end pc_tb;

architecture behaviour of pc_tb is
  component pc is
  port (
    ctrl_pulse: in std_logic;
    conn_bus: inout std_logic_vector(8 downto 0)
  );
  end component;

  -- inout bus
  signal conn_bus: std_logic_vector(8 downto 0) := (others => 'Z');

  -- input: a pulse signal coming from the controller
  signal ctrl_pulse: std_logic := '0';

  -- clock (only for testing)
  signal clk: std_logic := '0';

  -- clock period definition 
  constant clk_period: time := 10 ns;
begin

  -- Instatiating the UUT
  uut: pc
  port map(
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

  -- The PC entity tests:
  -- 1) getting one value
  -- 2) SKIPCOND - skipping one incoming value
  -- 3) JUMP - changing the PC register to the specified value
  -- 4) getting an another "normal" value

  get_addr: process
  begin
    wait for 100 ns;

  -- operation 1
    -- printing
    ctrl_pulse <= '1';
    wait for clk_period;

    ctrl_pulse <= '0';
    wait for clk_period;

  -- operation 2
    ctrl_pulse <= '1';
    conn_bus <= "111100011";
    wait for clk_period;

    -- clearing the bus
    -- goal: letting the PC print the value of its register
    conn_bus <= (others => 'Z');
    
    ctrl_pulse <= '0';
    wait for clk_period;

    -- printing
    ctrl_pulse <= '1';
    wait for clk_period;

    ctrl_pulse <= '0';
    wait for clk_period;

  -- operation 3
    ctrl_pulse <= '1';
    conn_bus <= "111100010";
    wait for clk_period;

    -- clearing the bus
    conn_bus <= (others => 'Z');

    ctrl_pulse <= '0';
    wait for clk_period;

    -- updating the value of the PC register
    conn_bus <= "000001000";

    ctrl_pulse <= '1';
    wait for clk_period;

    --clearing the bus
    conn_bus <= (others => 'Z');

    ctrl_pulse <= '0';
    wait for clk_period;

    ctrl_pulse <= '1';
    wait for clk_period;

    ctrl_pulse <= '0';
    wait for clk_period;

  -- operation 4
    ctrl_pulse <= '1';
    wait for clk_period;

    ctrl_pulse <= '0';
    wait for clk_period;

    wait;

  end process;
end;