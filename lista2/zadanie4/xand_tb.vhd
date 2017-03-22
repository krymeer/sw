library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xand_tb is
end xand_tb;

architecture behaviour of xand_tb is
  
  component Xand is
  generic(width: integer);
  port(
    clk: in std_logic;
    A, B: in std_logic_vector(width-1 downto 0);
    C: out std_logic_vector(width-1 downto 0)
  );
  end component;

  constant width : integer := 3;

  signal clk: std_logic := '0';
  signal A, B: std_logic_vector(width-1 downto 0) := (others => '0');
  signal C: std_logic_vector(width-1 downto 0);

  constant period : time := 10 ns;
  constant expo : integer := 2 ** width;

  begin

    uut:  Xand generic map(width => width)
          port map(
            clk => clk,
            A => A,
            B => B,
            C => C
          );

    stim_proc : process
    begin
      for i in 1 to expo loop
        for j in 1 to expo loop
          wait for period;
          B <= std_logic_vector(unsigned(B) + 1);
        end loop;
        A <= std_logic_vector(unsigned(A) + 1);
      end loop;
      wait for period;
      wait;
    end process;

  end;
