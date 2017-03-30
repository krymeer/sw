library ieee;
use ieee.std_logic_1164.all;
use work.txt_util.all;

entity statemachine_tb is
end statemachine_tb;

architecture behaviour of statemachine_tb is
  component statemachine
  port (
    clk:    in std_logic;
    p:      in std_logic;
    reset:  in std_logic;
    r:      out std_logic
  );
  end component;

  -- input
  signal clk: std_logic := '0';
  signal reset: std_logic := '0';
  signal p: std_logic := '0';

  -- output
  signal r: std_logic;

  constant clk_period: time := 10 ns;

begin
  uut: statemachine port map (
    clk => clk,
    p => p,
    r => r,
    reset => reset
  );

  clk_process: process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  stim_proc: process
  begin
    wait for 100 ns;
    wait for clk_period*10;

    p <= '1';
    wait for clk_period;

    for i in 1 to 10 loop
      print(str(r));
      wait for clk_period/2;
    end loop;
    wait;
  end process;
end;