-- Author: Krzysztof R. Osada, 2017

library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

package appendix is
  function std_logic_vector_to_line(v: in std_logic_vector) return line;
  function string_to_std_logic_vector(s: in string) return std_logic_vector;
  procedure new_line;
  procedure write_v(v: in std_logic_vector);
  procedure write_s(s: in string);
end appendix;

package body appendix is
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

  -- function that returns a std_logic_vector built from the given string
  function string_to_std_logic_vector(s: in string) return std_logic_vector is
    variable out_v: std_logic_vector(8 downto 0) := (others => '0');
    variable i: integer := 1;
  begin
    for k in 8 downto 0 loop
      case s(i) is
        when '0' => out_v(k) := '0';
        when others => out_v(k) := '1';
      end case;
      i := i + 1;
    end loop;
    return out_v;
  end string_to_std_logic_vector;

  -- procedure that simply prints a new line
  procedure new_line is
    variable l: line;
  begin
    write(l, string'(""));
    writeline(output, l);
  end new_line;

  -- procedure that prints a std_logic_vector
  procedure write_v(v: in std_logic_vector) is
    variable line_w: line;
  begin
    write(line_w, 
      std_logic_vector_to_line(v).all
    );
    writeline(output, line_w);
  end write_v;

  -- procedure that prints a line with a string
  procedure write_s(s: in string) is
    variable line_w: line;
  begin
    write(line_w, s);
    writeline(output, line_w);
  end write_s;

end appendix;