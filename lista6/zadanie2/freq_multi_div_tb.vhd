library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity freq_multi_div_tb is
end freq_multi_div_tb;

architecture behavior of freq_multi_div_tb is
  component freq_multi_div
    generic(N: natural := 1);
    port (
      clk_in:   in std_logic;
      clk_out:  out unsigned(N downto 0)
    );
  end component;

  -- input
  signal clk_in: std_logic := '0';

  -- outputs
  signal clk_out: unsigned(6 downto 0);

  -- workaround: separate signals for different frequencies
  signal my_clk_0, my_clk_1, my_clk_2, my_clk_3, my_clk_4, my_clk_5, my_clk_6: std_logic;

  constant clk_period: time := 8 ns;

begin
  clk_uut: freq_multi_div
  generic map(N => 6)
  port map(
    clk_in => clk_in,
    clk_out => clk_out
  );

  my_clk_0 <= clk_out(0); my_clk_1 <= clk_out(1); my_clk_2 <= clk_out(2);
  my_clk_3 <= clk_out(3); my_clk_4 <= clk_out(4); my_clk_5 <= clk_out(5);
  my_clk_6 <= clk_out(6);

  clk_process: process
  begin
    clk_in <= '0';
    wait for clk_period/2;
    clk_in <= '1';
    wait for clk_period/2;
  end process;

end;