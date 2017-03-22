library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use std.textio.all;

entity lfsr is
  port(clk: in std_logic;
    q: inout std_logic_vector(15 downto 0) := (others => '0')
  );
end lfsr;

architecture Behavioral of lfsr is
begin
  process
  variable a, b, k: integer;
  variable l: line;
  begin
    -- first process execution
    if q = "0000000000000000" then
      -- read an integer
      readline(input, l);
      read(l, a);

      -- get a binary representation of a given integer
      k := 0;
      while a > 0 loop
        b := a / 2;
        b := b * 2;
        if a > b then
          q(k) <= '1';
        else
          q(k) <= '0';
        end if;
        k := k + 1;
        a := a / 2;
      end loop;

    -- another process executions
    else
      q(15 downto 1) <= q(14 downto 0);
      -- q(0) <= not(q(15) XOR q(14) XOR q(13) XOR q(4));
      -- this line has been changed in order to get the results from the C version
      q(0) <= q(15) xor q(14) xor q(13) xor q(4);
    end if;
    wait until clk'event and clk='1'; 
  end process;
end Behavioral;
