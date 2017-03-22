library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity selector_tb is
end selector_tb;

architecture behaviour of selector_tb is
  component selector is
    generic(width: integer);
    port(
      S: in std_logic;
      A, B: in std_logic_vector(width-1 downto 0);
      X: out std_logic_vector(width-1 downto 0)
    );
  end component;

  constant width: integer := 13;

  -- input
  signal S: std_logic := '0';
  signal A: std_logic_vector(width-1 downto 0) := (others => '0');
  signal B: std_logic_vector(width-1 downto 0) := (others => '0');

  -- output
  signal X: std_logic_vector(width-1 downto 0);

  constant period: time := 10 ns;
  constant t: integer := 2 ** width;

  begin
      uut : selector generic map(width => width)
            port map(
              S => S,
              A => A,
              B => B,
              X => X
            );

    stim_proc: process

    begin

      for i in 1 to t loop
        for j in 1 to t loop
          wait for period;
          B <= std_logic_vector(unsigned(B) + 1);
        end loop;
        A <= std_logic_vector(unsigned(A) + 1);
      end loop;
    
      wait for period;

      S <= '1';
      for i in 1 to t loop
        for j in 1 to t loop
          wait for period;
          B <= std_logic_vector(unsigned(B) + 1);
        end loop;
        A <= std_logic_vector(unsigned(A) + 1);
      end loop;

      wait for period;
      wait;
    end process;
end;