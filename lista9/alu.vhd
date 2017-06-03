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
  --- CATCH: store arguments for the operation
  --- ADD: perform the addition
  --- SUBT: perform the subtraction
  type state_type is (IDLE, CATCH, ADD, SUBT);

  -- Initial state of the entity
  signal current_state, next_state: state_type := IDLE;

  -- A "bool" signal which says if the data is being sent at the moment
  signal sum, two_numbers, sending: std_logic := '0';

  -- A word that came from conn_bus and a possible output
  signal word, result: std_logic_vector(8 downto 0) := (others => '0');

  -- Two arguments for addition and subtraction operations
  signal arg1, arg2: std_logic_vector(4 downto 0) := (others => '0');

  -- Computing a sum of two numbers
  function add(n_1: in std_logic_vector; n_2: in std_logic_vector) return std_logic_vector is
    variable carry: std_logic_vector(4 downto 0) := (others => '0');
    variable sum: std_logic_vector(8 downto 0) := (others => '0');
  begin
    for i in 0 to 4 loop
      sum(i) := carry(i) xor n_1(i) xor n_2(i);
      if i < 4 then
        carry(i+1) := (n_1(i) and n_2(i)) or (n_1(i) and carry(i)) or (n_2(i) and carry(i));
      end if;
    end loop; 
    return sum;
  end add;

  -- Computing a difference between two numbers (providing that A >= B)
  function subtract(n_1: in std_logic_vector; n_2: std_logic_vector) return std_logic_vector is
    variable borrow: std_logic_vector(4 downto 0) := (others => '0');
    variable difference: std_logic_vector(8 downto 0) := (others => '0');
  begin
    if n_1 = "000000000" then
      return n_2;
    elsif n_1 < n_2 then
      return "000000000";
    end if;
    for k in 0 to 4 loop
      difference(k) := n_1(k) xor n_2(k) xor borrow(k);
      if k < 4 then
        borrow(k+1) := (not(n_1(k) xor n_2(k)) and borrow(k)) or (not(n_1(k)) and n_2(k));
      end if;
    end loop;
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
              next_state <= CATCH;
            -- Subtraction
            when "111101110" => 
              sum <= '0';
              next_state <= CATCH;
            when others
              => next_state <= IDLE;
          end case;
        end if;
        sending <= '0';
      -- Store the arguments for the operation
      when CATCH =>
        if two_numbers = '0' then
          two_numbers <= '1';
          arg1 <= conn_bus(4 downto 0);
        elsif two_numbers = '1' then
          two_numbers <= '0';
          arg2 <= conn_bus(4 downto 0);
          if sum = '1' then
            next_state <= ADD;
          else
            next_state <= SUBT;
          end if;
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