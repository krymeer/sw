library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity lfsr is
  port(clk: in std_logic;
    q: inout std_logic_vector(15 downto 0) := (0 => '1', others => '0')
  );
end lfsr;

architecture Behavioral of lfsr is
begin
  process
  begin
    q(15 downto 1) <= q(14 downto 0);
    -- q(0) <= not(q(15) xor q(14) xor q(13) xor q(4));
    -- this line has been changed in order to get the results from the C version
    q(0) <= q(15) xor q(14) xor q(13) xor q(4);
    wait until clk'event and clk='1'; 
  end process;
end Behavioral;
