library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity freq_div_tb is
end freq_div_tb;

architecture behavior of freq_div_tb is
  component freq_div
    generic(n: natural := 1; m: natural := 1);
    port (
      clk_in:   in std_logic;
      clk_out:  out std_logic
    );
  end component;

  -- input
  signal clk_in: std_logic := '0';

  -- outputs
  signal clk_out_50: std_logic;
  signal clk_out_100: std_logic;
  signal clk_out_11: std_logic;

  constant clk_period: time := 8 ns;

begin
  clk_50: freq_div 
  generic map(n => 12, m => 8)
  port map(
    clk_in => clk_in,
    clk_out => clk_out_50
  );

  clk_100: freq_div 
  generic map(n => 5000000, m => 5000000)
  port map(
    clk_in => clk_in,
    clk_out => clk_out_100
  );

  -- relative error: 0.0003%
  clk_11: freq_div
  generic map(n => 454545, m => 454545)
  port map(
    clk_in => clk_in,
    clk_out => clk_out_11
  );

  clk_process: process
  begin
    clk_in <= '0';
    wait for clk_period/2;
    clk_in <= '1';
    wait for clk_period/2;
  end process;

end;