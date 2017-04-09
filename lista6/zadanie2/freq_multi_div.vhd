library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity freq_multi_div is
  generic(N: natural := 1);
  port(
    clk_in:   in std_logic;
    clk_out:  out unsigned(N downto 0)
  );
end freq_multi_div;

architecture behavioral of freq_multi_div is
  signal clk_tmp: unsigned(N downto 0) := (others => '0');
begin
  divide: process(clk_in)
  begin
    if clk_in'event then
      clk_tmp <= clk_tmp +1;
    end if;
  end process;
  clk_out <= clk_tmp;
end behavioral;