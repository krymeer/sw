library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb_1 is
end tb_1;
 
architecture behavior of tb_1 IS 
  component slave
    generic(identifier: std_logic_vector (7 downto 0));
    port(
      conn_bus: inout std_logic_vector(7 downto 0);
      clk: in std_logic;
      state: out std_logic_vector(5 downto 0);
      vq: out std_logic_vector(7 downto 0);
      vcurrent_cmd: out std_logic_vector(3 downto 0)
    );
    end component;
    
  --Inputs
  signal clk: std_logic := '0';

  --BiDirs
  signal conn_bus: std_logic_vector(7 downto 0) := (others => 'Z');
  
  -- outputs from UUTs for debugging
  signal state_1, state_2, state_3: std_logic_vector(5 downto 0);
  signal vq_1, vq_2, vq_3: std_logic_vector (7 downto 0);
  signal current_cmd_1, current_cmd_2, current_cmd_3: std_logic_vector (3 downto 0);

  -- Clock period definitions
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
    write(l, string'(""));
    writeline(output, l);
  end new_line;

  -- procedure that prints bus' current output
  procedure write_output(command: in string) is
    variable line_w: line;
  begin
    write(line_w, command
      & string'(": ")
      & std_logic_vector_to_line(conn_bus).all
    );
    writeline(output, line_w);
  end write_output;
begin
 
  -- instatiating the UUTs
  unit_1: slave 
  generic map (identifier => "10101010")
  port map(
    conn_bus => conn_bus,
    clk => clk,
    state => state_1,
    vq => vq_1,
    vcurrent_cmd => current_cmd_1
  );

  unit_2: slave 
  generic map (identifier => "10101011")
  port map(
    conn_bus => conn_bus,
    clk => clk,
    state => state_2,
    vq => vq_2,
    vcurrent_cmd => current_cmd_2
  );

  unit_3: slave 
  generic map (identifier => "10101100")
  port map(
    conn_bus => conn_bus,
    clk => clk,
    state => state_3,
    vq => vq_3,
    vcurrent_cmd => current_cmd_3
  );

  -- Clock process definitions
  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;
 
  -- Stimulus process
  stim_proc: process
  begin    
    -- hold reset state for 100 ns.
    wait for 100 ns;  

    wait for clk_period*10;

-- Testing: sending and requiring data from three different processing units

  -- 1st processing unit: adding 0 to 14
    -- address
    conn_bus <= "10101010";
    wait for clk_period;
    -- CMD: add
    conn_bus <= "00010000";
    wait for clk_period;
    -- an argument
    conn_bus <= "00001110";
    wait for clk_period;

  -- 3rd processing unit: sending 6 (00001010) to the accumulator
    -- address
    conn_bus <= "10101100";
    wait for clk_period;
    -- CMD: add
    conn_bus <= "00010000";
    wait for clk_period;
    -- an argument
    conn_bus <= "00001010";
    wait for clk_period;

  -- 2nd processing unit: adding 0 to 20
    -- address
    conn_bus <= "10101011";
    wait for clk_period;
    -- CMD: add
    conn_bus <= "00010000";
    wait for clk_period;
    -- an argument
    conn_bus <= "00010100";
    wait for clk_period;

  -- 3rd processing unit: adding 155 (10011011) to the accumulator
        -- address
    conn_bus <= "10101100";
    wait for clk_period;
    -- CMD: add
    conn_bus <= "00010000";
    wait for clk_period;
    -- an argument
    conn_bus <= "10011011";
    wait for clk_period;

  -- requiring data from 1st processing unit (should get 14 = 00001110)
    -- address
    conn_bus <= "10101010";
    wait for clk_period;
    -- CMD: data_req
    conn_bus <= "01000000";
    wait for clk_period;
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period;

    -- a slight delay is neccessary to prevent transferring data from corrupting
    wait for clk_period;

  -- requiring data from 2nd processing unit (should get 20 = 00010100)
    -- address
    conn_bus <= "10101011";
    wait for clk_period;
    -- CMD: data_req
    conn_bus <= "01000000";
    wait for clk_period;
    -- this is needed to allow writing on bus by slave
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period;

    -- a deliberate delay (as above)
    wait for clk_period;

  -- requiring data from 3rd processing unit (should get 161 = 10100001)
    -- address
    conn_bus <= "10101100";
    wait for clk_period;
    -- CMD: data_req
    conn_bus <= "01000000";
    wait for clk_period;
    -- this is needed to allow writing on bus by slave
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period;

    wait;
  end process;
end;