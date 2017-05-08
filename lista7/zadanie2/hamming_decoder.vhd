library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity hamming_decoder is
  port(
    err_pos: in std_logic_vector(2 downto 0);
    data_in: in std_logic_vector(6 downto 0);
    data_out: out std_logic_vector(3 downto 0)
  );
end hamming_decoder;

architecture behavioral of hamming_decoder is
begin
  data_out(3) <= not data_in(4) when err_pos = "110"
    else data_in(4);

  data_out(2) <= not data_in(2) when err_pos = "101"
    else data_in(2);

  data_out(1) <= not data_in(1) when err_pos = "011"
    else data_in(1);

  data_out(0) <= not data_in(0) when err_pos = "111"
    else data_in(0);
end behavioral;