library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std;

entity selector is
  generic(width : integer := 4);
  port(
    S : in std_logic;
    A, B : in std_logic_vector(width-1 downto 0);
    X : out std_logic_vector(width-1 downto 0)
  );
end selector;

architecture behaviour of selector is
  begin
    X <= A when (S = '0') else B;
end behaviour;