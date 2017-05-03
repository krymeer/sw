library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity hamming_decoder_tb is
end hamming_decoder_tb;

architecture behavior of hamming_decoder_tb is
  
  component hamming_decoder is
  port(
    data_in: in std_logic_vector(6 downto 0);
    data_out: out std_logic_vector(3 downto 0)
  );
  end component;

  -- input
  signal data_in: std_logic_vector(6 downto 0) := (others => '0');

  -- output
  signal data_out: std_logic_vector(3 downto 0);

  -- clock period
  constant period: time := 20 ns;

begin
  test_data: hamming_decoder
  port map(
    data_in => data_in,
    data_out => data_out
  );

  -- decoding process of one of the numbers (only for testing)
  stim_proc: process
    variable l: line;
    variable s: string(1 to 3);
  begin
    data_in <= "1010101";
    wait for period;
    for i in 6 downto 0 loop
      s := std_logic'image(data_in(i));
      write(l, s(2));
    end loop;
    write(l, String'(" - "));
    for i in 3 downto 0 loop
      s := std_logic'image(data_out(i));
      write(l, s(2));
    end loop;
    writeline(output, l);
    wait for period;
    wait;
  end process;
end;