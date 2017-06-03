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
  type state_type is (IDLE, CALL_PC, CALL_RAM, SET_RAM_ADDR, SET_MAR, SET_MBR, SET_AC, GET_RAM_WORD, SET_INREG, GET_INREG, SET_OUTREG, OUTPUT_GET_AC, DECODE, PC_JUMP, WAIT_FOR_PC, WAIT_FOR_RAM, SKIP_GET_AC, SKIP, PC_CLR, CALL_RAM_FOR_MBR, CALL_AC_FOR_MBR, STORE, SET_RAM_FOR_STORE, ALU_GET_AC, ALU_ARGS, WAIT_FOR_ALU);

  -- Initial state of the entity
  signal current_state, next_state: state_type := IDLE;

  -- "Booleans" allowing or forbidding the entity to perform an action 
  signal add_op, alu_sent, alu_op, up_ac, mar_next, end_of_program, sending: std_logic := '0';

  -- An address at the memory (RAM), a value of the register, an accumulator value, ALU args
  signal address, value, acc, arg1, arg2: std_logic_vector(8 downto 0);

  -- An address at the memory (being a part of the instruction)
  signal ram_addr: std_logic_vector(4 downto 0);

  -- A value used with the skipcond instruction
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
        -- Wait until a word from the RAM entity arrives
        when GET_RAM_WORD =>
          sending <= '0';
          if conn_bus /= address then
            next_state <= DECODE;
          end if;
        -- Decode the word
        when DECODE =>
          alu_op <= '0';
        --  write_v(conn_bus);
          opcode := conn_bus(8 downto 5);
          -- Perform an operation depending on the opcode
          case opcode is
            -- Load
            when "0001" =>
              unsgn := (others => '0');
              for i in 4 downto 0 loop
                unsgn(i) := conn_bus(i);
              end loop;
              address <= std_logic_vector(unsgn);
              mar_next <= '0';
              ctrl_reg <= "111100100";
              sending <= '1';
              next_state <= SET_MAR;
            -- Store
            when "0010" =>
              unsgn := (others => '0');
              for i in 4 downto 0 loop
                unsgn(i) := conn_bus(i);
              end loop;
              address <= std_logic_vector(unsgn);
              mar_next <= '1';
              ctrl_reg <= "111100100";
              sending <= '1';
              next_state <= SET_MAR;
            -- Add
            when "0011" =>
              add_op <= '1';
              alu_op <= '1';
              unsgn := (others => '0');
              for i in 4 downto 0 loop
                unsgn(i) := conn_bus(i);
              end loop;
              address <= std_logic_vector(unsgn);
              mar_next <= '0';
              ctrl_reg <= "111100100";
              sending <= '1';
              next_state <= SET_MAR;
            -- Subt
            when "0100" =>
              add_op <= '0';
              alu_op <= '1';
              unsgn := (others => '0');
              for i in 4 downto 0 loop
                unsgn(i) := conn_bus(i);
              end loop;
              address <= std_logic_vector(unsgn);
              mar_next <= '0';
              ctrl_reg <= "111100100";
              sending <= '1';
              next_state <= SET_MAR;
            -- Input
            when "0101" =>
              ctrl_reg <= "111101010";
              sending <= '1';
              next_state <= SET_INREG;
            -- Output
            when "0110" =>
              ctrl_reg <= "111101001";
              sending <= '1';
              next_state <= OUTPUT_GET_AC;
            -- Halt
            when "0111" =>
              end_of_program <= '1';
              next_state <= IDLE;
            -- Skipcond
            when "1000" =>
              ctrl_reg <= "111101001";
              sending <= '1';
              twobit <= conn_bus(4 downto 3);
              next_state <= SKIP_GET_AC;
            -- Jump
            when "1001" =>
              sending <= '1';
              ctrl_reg <= "111100010";
              ram_addr <= conn_bus(4 downto 0);
              next_state <= WAIT_FOR_PC;
            when others =>
              next_state <= IDLE;
          end case;
        -- Updating the address stored in MAR
        when SET_MAR =>
          if conn_bus = "111100100" then
            ctrl_reg <= address;
          elsif conn_bus = address then
            sending <= '0';
          else
            sending <= '1';
            if mar_next = '0' then
              ctrl_reg <= "111100000";
              next_state <= CALL_RAM_FOR_MBR;
            else
              ctrl_reg <= "111101001";
              next_state <= CALL_AC_FOR_MBR;
            end if;
          end if;
        -- Getting a current value of the accumulator
        when CALL_AC_FOR_MBR =>
          sending <= '0';
          if conn_bus /= "111101001" and conn_bus /= "ZZZZZZZZZ" then
            up_ac <= '0';
            sending <= '1';
            value <= conn_bus;
            ctrl_reg <= "111100110";
            next_state <= SET_MBR;
          end if;
        -- Calling the RAM entity so as to get a value
        when CALL_RAM_FOR_MBR =>
          if conn_bus = "111100000" then
            ctrl_reg <= address;
          elsif conn_bus = address then
            sending <= '0';
            next_state <= WAIT_FOR_RAM;
          end if;
        -- Catching the value sent by the RAM entity
        when WAIT_FOR_RAM =>
          if conn_bus /= "ZZZZZZZZZ" then
            up_ac <= '1';
            sending <= '1';
            value <= conn_bus;
            if alu_op = '1' then
              -- The value on the bus is argument 2 for the ALU entity
              arg2 <= conn_bus;
              -- Get the value of the accumulator
              ctrl_reg <= "111101001";
              next_state <= ALU_GET_AC;
            else
              ctrl_reg <= "111100110";
              next_state <= SET_MBR;
            end if;
          end if;
        -- Getting the value of the accumulator for the ALU entity
        when ALU_GET_AC =>
          sending <= '0';
          if conn_bus /= "ZZZZZZZZZ" and conn_bus /= "111101001" then 
            -- The value of the accumulator
            arg1 <= conn_bus;
            -- Decide if an addition or a subtraction should be performed
            sending <= '1';
            if add_op = '1' then
              ctrl_reg <= "111101101";
            else
              ctrl_reg <= "111101110";
            end if;
            next_state <= ALU_ARGS;
          end if;
        -- Sending arguments to perform an action in the ALU entity
        when ALU_ARGS =>
          if conn_bus = "111101101" or conn_bus = "111101110" then
            ctrl_reg <= arg1;
          else
            ctrl_reg <= arg2;
            next_state <= WAIT_FOR_ALU;
          end if;
        -- Getting the result computed by the ALU entity
        when WAIT_FOR_ALU =>
          sending <= '0';
          if alu_sent = '0' and conn_bus = arg2 then
            alu_sent <= '1';
          end if;
          -- Update the accumulator
          if alu_sent = '1' and conn_bus /= "ZZZZZZZZZ" then
            alu_sent <= '0';
            sending <= '1';
            acc <= conn_bus;
            ctrl_reg <= "111101000";
            next_state <= SET_AC;
          end if;
        -- Updating the value stored in MBR
        when SET_MBR =>
          if conn_bus = "111100110" then
            ctrl_reg <= value;
          elsif conn_bus = value then
            sending <= '0';
          else
            sending <= '1';
            -- Update the accumulator
            if up_ac = '1' then
              acc <= value;
              ctrl_reg <= "111101000";
              next_state <= SET_AC;
            -- Update the memory at a given address
            elsif up_ac = '0' then
              ctrl_reg <= "111100001";
              next_state <= SET_RAM_FOR_STORE;
            end if;
          end if;
        -- When the value of the accumulator comes, call the outREG
        when OUTPUT_GET_AC =>
          sending <= '0';
          if conn_bus /= "ZZZZZZZZZ" and conn_bus /= "111101001" then
            value <= conn_bus;
            ctrl_reg <= "111101100"; 
            sending <= '1';           
            next_state <= SET_OUTREG;
          end if;
        -- Call the inREG:
        --- when the REG entity receives a word, it asks the user to enter a number
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
        -- Call the RAM entity, set the given address and update the value
        when SET_RAM_FOR_STORE =>
          if conn_bus = "111100001" then
            ctrl_reg <= address;
          elsif conn_bus = address then
            ctrl_reg <= value;
            next_state <= STORE;
          end if;
        -- Finish the storing process
        when STORE =>
          sending <= '0';
          next_state <= IDLE;
        when others =>
          next_state <= IDLE;
      end case;
    end if;
  end process;

  conn_bus <= ctrl_reg when sending = '1' else (others => 'Z');  
end arch;
