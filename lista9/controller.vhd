-- Author: Krzysztof R. Osada, 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.appendix.all;

entity controller is
  port(
    clk: in std_logic;
    reading_done: in std_logic;
    ctrl_pulse: out std_logic := '0';
    conn_bus: inout std_logic_vector(8 downto 0)
  );
end controller;

architecture arch of controller is
  -- Possible states of the controller
  -- THe list includes a few "dirty" workarounds, unfortunalely
  type state_type is (IDLE, CALL_PC, CALL_RAM, SET_RAM_ADDR, SET_AC, GET_RAM_WORD, SET_INREG, GET_INREG, SET_OUTREG, OUTPUT_GET_AC, DECODE, PC_JUMP, WAIT_FOR_PC, SKIP_GET_AC, SKIP, PC_CLR);

  -- Initial state of the entity
  signal current_state, next_state: state_type := IDLE;

  -- "Booleans" allowing or forbidding the entity to perform an action 
  signal end_of_program, sending: std_logic := '0';

  -- An address at the memory (RAM)
  signal address, value, acc: std_logic_vector(8 downto 0);

  signal ram_addr: std_logic_vector(4 downto 0);

  signal twobit: std_logic_vector(1 downto 0);

  -- Bus words: the first one which arrives, and the second one that could be returned
  signal word, ctrl_reg: std_logic_vector(8 downto 0) := (others => '0');

begin

  -- Note: both of processes peform actions only when reading a file is done

  state: process(clk)
  begin
    if rising_edge(clk) and reading_done = '1' then
      word <= conn_bus;
      current_state <= next_state;
    end if;
  end process;

  nextstate: process(current_state, word)
    variable opcode: std_logic_vector(3 downto 0);
    variable unsgn: unsigned(8 downto 0);
  begin
    if reading_done = '1' then
      case current_state is
        when IDLE =>
          -- Get an address from the PC entity
          if end_of_program = '0' then
            ctrl_pulse <= '1';
            next_state <= CALL_RAM;
          -- Nothing new happened, go on
          else
            next_state <= IDLE;
          end if;
        -- Get the address and call the RAM entity
        when CALL_RAM =>
          address <= conn_bus;
          ctrl_pulse <= '0';
          ctrl_reg <= "111100000";
          sending <= '1';
          next_state <= SET_RAM_ADDR;
        -- Send the address to the RAM entity
        when SET_RAM_ADDR =>
          ctrl_reg <= address;
          next_state <= GET_RAM_WORD;
        -- Wait until a word from the RAM arrives
        when GET_RAM_WORD =>
          sending <= '0';
          if conn_bus /= address then
            next_state <= DECODE;
          end if;
        -- Decode the word
        when DECODE =>
        --  write_v(conn_bus);
          opcode := conn_bus(8 downto 5);
          -- Perform an operation depending on the opcode
          case opcode is
            when "0101" =>
              ctrl_reg <= "111101010";
              sending <= '1';
              next_state <= SET_INREG;
            when "0110" =>
              ctrl_reg <= "111101001";
              sending <= '1';
              next_state <= OUTPUT_GET_AC;
            when "0111" =>
              end_of_program <= '1';
              next_state <= IDLE;
            when "1000" =>
              ctrl_reg <= "111101001";
              sending <= '1';
              twobit <= conn_bus(4 downto 3);
              next_state <= SKIP_GET_AC;
            when "1001" =>
              sending <= '1';
              ctrl_reg <= "111100010";
              ram_addr <= conn_bus(4 downto 0);
              next_state <= WAIT_FOR_PC;
            when others =>
              next_state <= IDLE;
          end case;
        -- When the value of the accumulator comes, call the outREG
        when OUTPUT_GET_AC =>
          sending <= '0';
          if conn_bus /= "ZZZZZZZZZ" and conn_bus /= "111101001" then
            value <= conn_bus;
            ctrl_reg <= "111101100"; 
            sending <= '1';           
            next_state <= SET_OUTREG;
          end if;
        -- Call the inREG
        -- When the REG entity receives a word, it asks the user to enter a number
        when SET_INREG =>
          sending <= '0';
          if conn_bus = "ZZZZZZZZZ" then            
            ctrl_reg <= "111101011";
            sending <= '1';
            next_state <= GET_INREG;
          else
            next_state <= SET_INREG;
          end if;
        -- Get the current value of the inREG
        when GET_INREG =>
          sending <= '0';
          if conn_bus = "111101011" or conn_bus = "ZZZZZZZZZ" then
            next_state <= GET_INREG;
          else
            sending <= '1';
            acc <= conn_bus;
            ctrl_reg <= "111101000";
            next_state <= SET_AC;
          end if;
        -- Update the value of the outREG
        when SET_OUTREG =>
          if conn_bus = "ZZZZZZZZZ" then
            next_state <= IDLE;
          elsif conn_bus = "111101100" then
            ctrl_reg <= value;
          else
            sending <= '0';
          end if;
        -- Update the value of the accumulator
        when SET_AC =>
          if conn_bus = "ZZZZZZZZZ" then
            next_state <= IDLE;
          elsif conn_bus = "111101000" then
            ctrl_reg <= acc;
          else
            sending <= '0';
          end if;
        -- Get the value of the accumulator and decide whether to skip next instruction
        when SKIP_GET_AC =>
          sending <= '0';
          if conn_bus /= "111101001" and conn_bus /= "ZZZZZZZZZ" then
            case twobit is
              when "01" =>
                -- AC = 0 and SKIPCOND = 100001000
                if conn_bus = "000000000" then
                  sending <= '1';
                  ctrl_reg <= "111100011";
                  next_state <= SKIP;
                else
                  next_state <= IDLE;
                end if;
              when "10" =>
                -- AC > 0 and SKIPCOND = 100010000
                if conn_bus /= "000000000" then
                  sending <= '1';
                  ctrl_reg <= "111100011";
                  next_state <= SKIP;
                else
                  next_state <= IDLE;
                end if;
              when others =>
                next_state <= IDLE;
            end case;
          end if;
        -- Skip one instruction
        when SKIP =>
          ctrl_pulse <= '1';
          next_state <= PC_CLR;
        -- Stop forcible PC changing
        when PC_CLR =>
          sending <= '0';
          ctrl_pulse <= '0';
          next_state <= IDLE;
        -- Let the PC know that there is going to be a jump
        when WAIT_FOR_PC =>
          ctrl_pulse <= '1';
          next_state <= PC_JUMP;
        when PC_JUMP =>
          ctrl_pulse <= '0';
          -- Set the new value of the PC
          if conn_bus = "111100010" then
            unsgn := (others => '0');
            for i in 4 downto 0 loop
              unsgn(i) := ram_addr(i);
            end loop;
            ctrl_reg <= std_logic_vector(unsgn);
          -- Changing the PC done with success
          elsif conn_bus = "ZZZZZZZZZ" then
            ctrl_pulse <= '0';
            next_state <= IDLE;
          -- Call the PC again
          else
            sending <= '0';
            ctrl_pulse <= '1';
            next_state <= PC_JUMP;
          end if;
        when others =>
          next_state <= IDLE;
      end case;
    end if;
  end process;

  conn_bus <= ctrl_reg when sending = '1' else (others => 'Z');  
end arch;
