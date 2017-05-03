library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity hamming_tb is
end hamming_tb;

architecture behavior of hamming_tb is
  
  -- encoder: takes a binary number and extends its width (from 4 to 7 bits)
  component hamming_encoder is
  port(
    data_in: in std_logic_vector(3 downto 0);
    data_out: out std_logic_vector(6 downto 0)
  );
  end component;

  -- decoder: takes an encoded binary number and tries to restore its initial value
  component hamming_decoder is
  port(
    data_in: in std_logic_vector(6 downto 0);
    data_out: out std_logic_vector(3 downto 0)
  );
  end component;

  -- input
  signal data_in: std_logic_vector(3 downto 0) := (others => '0');

  -- signal which receives data from the encoder and sends it to the decoder
  signal connector: std_logic_vector(6 downto 0);

  -- output
  signal data_out: std_logic_vector(3 downto 0);

  -- clock period
  constant period: time := 20 ns;
begin

  -- mapping signals
  encoder_test: hamming_encoder
  port map(
    data_in => data_in,
    data_out => connector
  );

  decoder_test: hamming_decoder
  port map(
    data_in => connector,
    data_out => data_out
  );

  main_proc: process
    variable l: line;
    variable b: string(1 to 3);
  begin

  write(l, String'(""));
  writeline(output, l);

  -- encoding and decoding all the binary numbers that consist of at most 4 bits
  for k in 0 to 15 loop
    data_in <= std_logic_vector(to_unsigned(k, data_in'length));
    wait for period;

    for i in 3 downto 0 loop
      b := std_logic'image(data_in(i));
      write(l, b(2));
    end loop;
    write(l, String'(" - "));
    for i in 6 downto 0 loop
      b := std_logic'image(connector(i));
      write(l, b(2));
    end loop;
    writeline(output, l);
    wait for period;

    for i in 6 downto 0 loop
      b := std_logic'image(connector(i));
      write(l, b(2));
    end loop;
    write(l, String'(" - "));
    for i in 3 downto 0 loop
      b := std_logic'image(data_out(i));
      write(l, b(2));
    end loop;
    writeline(output, l);
    wait for period;
  end loop;

  write(l, String'(""));
  writeline(output, l);
  wait;
  end process;

end;