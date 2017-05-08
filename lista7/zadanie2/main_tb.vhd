library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity main_tb is
end main_tb;

architecture behavior of main_tb is
  
  component lossy_channel
    generic(N: positive);
    port(
      data_in: in std_logic_vector(N-1 downto 0);
      clk: in std_logic;
      data_out: out std_logic_vector(N-1 downto 0)
    );
  end component;

  -- encoder: takes a binary number and extends its width (from 4 to 7 bits)
  component hamming_encoder is
  port(
    data_in: in std_logic_vector(3 downto 0);
    data_out: out std_logic_vector(6 downto 0)
  );
  end component;

  -- decoder: takes an encoded binary number and tries to restore its initial value
  -- also negates a bit with an index equal to the decimal value of err_pos (if err_pos /= "000")
  component hamming_decoder is
  port(
    err_pos: in std_logic_vector(2 downto 0);
    data_in: in std_logic_vector(6 downto 0);
    data_out: out std_logic_vector(3 downto 0)
  );
  end component;

  -- checker: determines if an error occurred
  -- note: it deals only with one-bit errors
  component hamming_checker is
  port(
    data_in: in std_logic_vector(6 downto 0);
    data_out: out std_logic_vector(2 downto 0)
  );
  end component;

  -- channel bitwidth (length of a Hamming-coded number);
  constant code_width: positive := 7;

  -- Hammming encoder's input
  signal encoder_in: std_logic_vector(3 downto 0) := (others => '0');
  -- note: Hamming's output is sent to the lossy channel

  -- channel inputs
  signal data_in: std_logic_vector(code_width-1 downto 0) := (others => '0');
  signal clk: std_logic := '0';

  -- channel output
  signal data_out: std_logic_vector(code_width-1 downto 0);

  -- Hammming decoder's output
  signal decoder_out: std_logic_vector(3 downto 0);

  -- Hamming code checker's output
  signal checker_out: std_logic_vector(2 downto 0);

  -- clock period definition
  constant clk_period: time := 10 ns;

  -- function that returns a line (to write) containing a std_logic_vector
  function std_logic_vector_to_line(v: in std_logic_vector) return line is
    variable b: string(1 to 3);
    variable l: line;
    variable len: natural;
  begin
    len := v'length-1;
    for i in len downto 0 loop
      b := std_logic'image(v(i));
      write(l, b(2));
    end loop;
    return l;
  end std_logic_vector_to_line;

  -- procedure that simply prints a new line
  procedure new_line is
    variable l: line;
  begin
    write(l, String'(""));
    writeline(output, l);
  end new_line;

begin

  -- mapping signals

  lossy: lossy_channel
  generic map(N => code_width)
  port map(
    data_in => data_in,
    clk => clk,
    data_out => data_out
  );

  encoder: hamming_encoder
  port map(
    data_in => encoder_in,
    data_out => data_in
  );

  checker: hamming_checker
  port map(
    data_in => data_out,
    data_out => checker_out
  );

  decoder: hamming_decoder
  port map(
    data_in => data_out,
    err_pos => checker_out,
    data_out => decoder_out
  );

  -- clock process
  clk_proc: process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  main_proc: process
    variable line_w: line;
    variable counter: integer := 0;
    variable pos: integer := 0;
  begin
    wait for 100 ns;

    new_line;

    for i in 0 to 3 loop
      for k in 0 to 15 loop
        encoder_in <= std_logic_vector(to_unsigned(k, encoder_in'length));
        wait for clk_period;

        if data_in /= data_out then
          counter := counter + 1;
          pos := to_integer(unsigned(checker_out));
          write(line_w, 
            String'("n = ")
            & std_logic_vector_to_line(encoder_in).all 
            & String'(" | ")
            & std_logic_vector_to_line(data_in).all
            & String'(" /= ")
            & std_logic_vector_to_line(data_out).all
            & String'(" | bit to negate: ") 
            & integer'image(pos)
          );
          if encoder_in /= decoder_out then
            write(line_w, String'(" | correcting failed, a double bit error occurred"));
            counter := counter + 1;
          else
            write(line_w, String'(" | decoded value: ") & std_logic_vector_to_line(decoder_out).all);            
          end if;
          writeline(output, line_w);
        end if;

      end loop;
    end loop;
 
    new_line;

    write(line_w, String'("total number of bit errors: ") & integer'image(counter));
    writeline(output, line_w);

    new_line;

    wait;
  end process;  
end;