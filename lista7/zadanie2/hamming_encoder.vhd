library ieee;
use ieee.std_logic_1164.all;

entity hamming_encoder is
  port(
    data_in: in std_logic_vector(3 downto 0);
    data_out: out std_logic_vector(6 downto 0)
  );
end hamming_encoder;

architecture behavioral of hamming_encoder is
begin
  data_out(6) <= data_in(3) xor data_in(2) xor data_in(0);
  data_out(5) <= data_in(3) xor data_in(1) xor data_in(0);
  data_out(4) <= data_in(3);
  data_out(3) <= data_in(2) xor data_in(1) xor data_in(0);
  data_out(2) <= data_in(2);
  data_out(1) <= data_in(1);
  data_out(0) <= data_in(0);
end behavioral;

