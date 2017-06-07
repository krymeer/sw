-- Author: Krzysztof R. Osada, 2017

library ieee;
use ieee.std_logic_1164.all;

entity alu is
  port(
    conn_bus: inout std_logic_vector(8 downto 0);
    clk: std_logic
  );
end alu;

architecture arch of alu is

  -- Possible states of the ALU entity:
  --- IDLE: nothing new happens
  --- CATCH_FIRST, CATCH_SECOND: store arguments for the operation
  --- ADD: perform the addition
  --- SUBT: perform the subtraction
  type state_type is (IDLE, CATCH_FIRST, CATCH_SECOND, ADD, SUBT);

  -- Initial state of the entity
  signal current_state, next_state: state_type := IDLE;

  -- A "bool" signal which says if the data is being sent at the moment
  signal sum, two_numbers, sending: std_logic := '0';

  -- A word that came from conn_bus and a possible output
  signal word, result: std_logic_vector(8 downto 0) := (others => '0');

  -- Two arguments for addition and subtraction operations
  signal arg1, arg2: std_logic_vector(8 downto 0) := (others => '0');

  function subtract(n_1: in std_logic_vector; n_2: std_logic_vector) return std_logic_vector;

  -- Computing a sum of two numbers
  function add(n_1: in std_logic_vector; n_2: in std_logic_vector) return std_logic_vector is
    variable carry: std_logic_vector(4 downto 0) := (others => '0');
    variable arg_1, arg_2, sum_result: std_logic_vector(8 downto 0) := (others => '0');
  begin
    arg_1 := n_1; arg_2 := n_2;
    -- If number 1 is negative, perform a "reverted" subtraction
    -- Treat a sign of number 1 as a binary operator, too
    if arg_1(8) = '1' and arg_2(8) = '0' then
      arg_1(8) := '0'; arg_1(7) := '0';
      return subtract(arg_2, arg_1);
    -- If number 2 is negative, treat its sign as a binary operator
    elsif arg_1(8) = '0' and arg_2(8) = '1' then
      arg_2(8) := '0'; arg_2(7) := '0';
      return subtract(arg_1, arg_2);
    -- If both of numbers are negative, change prefix "00" to "11"
    elsif arg_1(8) = '1' and arg_2(8) = '1' then
      sum_result(8) := '1'; sum_result(7) := '1';
    end if;

    for i in 0 to 4 loop
      sum_result(i) := carry(i) xor n_1(i) xor n_2(i);
      if i < 4 then
        carry(i+1) := (n_1(i) and n_2(i)) or (n_1(i) and carry(i)) or (n_2(i) and carry(i));
      end if;
    end loop;

    -- If the result of the addition is less than any of the arguments, an overflow occurred
    if sum_result < arg_1 or sum_result < arg_2 then
      sum_result := (others => '0');
    end if;

    return sum_result;
  end add;

  -- Computing a difference between two numbers
  function subtract(n_1: in std_logic_vector; n_2: std_logic_vector) return std_logic_vector is
    variable borrow: std_logic_vector(4 downto 0) := (others => '0');
    variable arg_1, arg_2, tmp, difference: std_logic_vector(8 downto 0) := (others => '0');
    variable negative_result: std_logic := '0';
  begin
    arg_1 := n_1; arg_2 := n_2;
    -- The first argument is equal to the second one
    if arg_1 = arg_2 then
      return difference;
    -- Number one positive, number two negative
    elsif arg_1(8) = '0' and arg_2(8) = '1' then
      tmp := arg_2;
      tmp(8) := '0'; tmp(7) := '0';
      return add(arg_1, tmp);
    -- Number one negative, number two positive
    elsif arg_1(8) = '1' and arg_2(8) = '0' then
      tmp := arg_1;
      tmp(8) := '0'; tmp(7) := '0';
      difference := add(tmp, arg_2);
      difference(8) := '1'; difference(7) := '1';
      return difference;
    -- If both of numbers are negative, swap them
    -- Number 2 becomes posivite as well
    elsif arg_1(8) = '1' and arg_2(8) = '1' then
      tmp := arg_2;
      tmp(8) := '0'; tmp(7) := '0';
      -- If the absolute value of number 2 is greater than the absolute value of number 1, swap them
      if arg_2(4 downto 0) > arg_1(4 downto 0) then
        arg_2 := arg_1;
        arg_1 := tmp;
      -- Otherwise
      else
        negative_result := '1';
      end if;
    -- Both of numbers are positive
    elsif arg_1(8) = '0' and arg_2(8) = '0' then
      -- If number 2 is greater than number 1, swap them
      if arg_2 > arg_1 then
        negative_result := '1';
        tmp := arg_2;
        arg_2 := arg_1;
        arg_1 := tmp;
      end if;
    end if;

    for k in 0 to 4 loop
      difference(k) := arg_1(k) xor arg_2(k) xor borrow(k);
      if k < 4 then
        borrow(k+1) := (not(arg_1(k) xor arg_2(k)) and borrow(k)) or (not(arg_1(k)) and arg_2(k));
      end if;
    end loop;

    -- The result is negative, so it starts from "1100"
    if negative_result = '1' then
      difference(8) := '1'; difference(7) := '1';
    end if;

    return difference;
  end subtract;

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
  begin
    case current_state is
      -- Nothing new happened so far
      when IDLE =>
        if sending /= '1' then
          case word is
            -- Addition
            when "111101101" => 
              sum <= '1';
              next_state <= CATCH_FIRST;
            -- Subtraction
            when "111101110" => 
              sum <= '0';
              next_state <= CATCH_FIRST;
            when others
              => next_state <= IDLE;
          end case;
        end if;
        sending <= '0';
      -- Store the first argument for the operation
      when CATCH_FIRST =>
        arg1 <= conn_bus;
        -- Change the state so as to catch an another number
        next_state <= CATCH_SECOND;
      -- Store the second argument for the operation
      when CATCH_SECOND =>
        arg2 <= conn_bus;
        -- Decide what to do next
        if sum = '1' then
          next_state <= ADD;
        else
          next_state <= SUBT;
        end if;
      -- Perform the addition and return the result
      when ADD =>
        result <= add(arg1, arg2);
        sending <= '1';
        next_state <= IDLE;
      -- Perform the subtraction and return the result
      when SUBT =>
        result <= subtract(arg1, arg2);
        sending <= '1';
        next_state <= IDLE;
      -- Nothing new, stay idle
      when others
        => next_state <= IDLE;
    end case;
  end process;

  -- A value from the register is loaded on the bus (if there's such a need)
  conn_bus <= result when sending = '1' else "ZZZZZZZZZ";
end arch;