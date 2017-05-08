library ieee;
use ieee.std_logic_1164.all;

entity hamming_checker is
  port(
    data_in: in std_logic_vector(6 downto 0) := (others => '0');
    data_out: out std_logic_vector(2 downto 0)
  );
end hamming_checker;

architecture behavioral of hamming_checker is
begin
  data_out(2) <= data_in(6) xor data_in(4) xor data_in(2) xor data_in(0);
  data_out(1) <= data_in(5) xor data_in(4) xor data_in(1) xor data_in(0);
  data_out(0) <= data_in(3) xor data_in(2) xor data_in(1) xor data_in(0);
end behavioral;