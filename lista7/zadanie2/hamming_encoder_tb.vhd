library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity hamming_encoder_tb is
end hamming_encoder_tb;

architecture behavior of hamming_encoder_tb is

  component hamming_encoder is
  port(
    data_in: in std_logic_vector(3 downto 0);
    data_out: out std_logic_vector(6 downto 0)
  );
  end component;

  -- input
  signal data_in: std_logic_vector(3 downto 0) := (others => '0');

  -- output
  signal data_out: std_logic_vector(6 downto 0);

  -- clock period
  constant period: time := 20 ns;
begin
  test_data: hamming_encoder
  port map(
    data_in => data_in,
    data_out => data_out
  );

  stim_proc: process
    variable l: line;
    variable b: string(1 to 3);
  begin
    for k in 0 to 15 loop
      data_in <= std_logic_vector(to_unsigned(k, data_in'length));
      wait for period;
      for i in 3 downto 0 loop
        b := std_logic'image(data_in(i));
        write(l, b(2));
      end loop;
      write(l, String'(" - "));
      for i in 6 downto 0 loop
        b := std_logic'image(data_out(i));
        write(l, b(2));
      end loop;
      writeline(output, l);
      wait for period;
    end loop;
  wait;
  end process;
end;