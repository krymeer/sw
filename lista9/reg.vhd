-- Author: Krzysztof R. Osada, 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.appendix.all;
use std.textio.all;

entity reg is
  port(
    conn_bus: inout std_logic_vector(8 downto 0);
    clk: std_logic
  );
end reg;

-- A component that consists of a few MARIE registers
architecture arch of reg is

  -- Defining MARIE registers:
  --- MAR: memory address register,
  --- MBR: memory buffer register,
  --- AC: accumulator,
  --- inREG: input register,
  --- outREG: output register.
  signal mar, mbr, ac, inreg, outreg: std_logic_vector(8 downto 0) := (others => '0');

  -- Possible states of the REG entity
  -- Their names correspond with the registers listed above
  type state_type is 
    (IDLE, MAR_SET, MAR_GET, MBR_SET, MBR_GET, AC_SET, AC_GET, INREG_SET, INREG_GET, OUTREG_SET);

  -- Initial state of the entity
  signal current_state, next_state: state_type := IDLE;

  -- A "bool" signal which says if the data is being sent at the moment
  signal sending: std_logic := '0';

  -- A word that came from conn_bus and a possible output
  signal word, result: std_logic_vector(8 downto 0) := (others => '0');

begin

  -- Catching changes of the clock signal
  -- The current state of the entity is updated as well
  state: process(clk)
  begin
    if rising_edge(clk) then
      word <= conn_bus;
      current_state <= next_state;
    end if;
  end process;

  nextstate: process(current_state, word)
    variable n: integer;
    variable l: line;
  begin
    -- The code below invokes one of the actions, depending on a given number
    case current_state is
      -- Nothing happened so far
      when IDLE =>
        if sending /= '1' then
          case word is
            when "111100100" 
              -- Update the MAR
              => next_state <= MAR_SET;
            when "111100101"
              -- Get the current MAR value
              => next_state <= MAR_GET;
            when "111100110"
              -- Update the MBR
              => next_state <= MBR_SET;
            when "111100111"
              -- Get the current MBR value
              => next_state <= MBR_GET;
            when "111101000"
              -- Update the AC
              => next_state <= AC_SET;
            when "111101001"
              -- Get the current AC value 
              => next_state <= AC_GET;
            when "111101010"
              -- Update the inREG (get a new input number)
              => next_state <= INREG_SET;
            when "111101011"
              -- Get the current inREG value
              => next_state <= INREG_GET;
            when "111101100"
              -- Update the current outREG value (and print it) 
              => next_state <= OUTREG_SET;
            when others
              => next_state <= IDLE;
          end case;
        end if;
        sending <= '0';
    -- Handling registers' states
      when MAR_SET =>
        mar <= word;
        next_state <= IDLE;
      when MAR_GET =>
        result <= mar;
        sending <= '1';
        next_state <= IDLE;
      when MBR_SET =>
        mbr <= word;
        next_state <= IDLE;
      when MBR_GET =>
        result <= mbr;
        sending <= '1';
        next_state <= IDLE;
      when AC_SET =>
        ac <= word;
        next_state <= IDLE;
      when AC_GET =>
        result <= ac;
        sending <= '1';
        next_state <= IDLE;
      when INREG_SET =>
      -- Asking for the input
        write(l, String'("Please enter a number from 0 to 31:"));
        writeline(output, l);
      -- Parsing the number
        readline(input, l);
        read(l, n);
      -- If the number is valid, store it in the register
        if n >= 0 and n <= 31 then
          inreg <= std_logic_vector(to_unsigned(n, inreg'length));
        else
          inreg <= "000000000";
        end if;
        next_state <= IDLE;
      when INREG_GET =>
        result <= inreg;
        sending <= '1';
        next_state <= IDLE;
      when OUTREG_SET =>
        write_v(word);
        outreg <= word;
        next_state <= IDLE;
      when others
        => next_state <= IDLE;
    end case;
  end process;

  -- A value from the memory is loaded on the bus (if there's such a need)
  conn_bus <= result when sending = '1' else "ZZZZZZZZZ";
end arch;