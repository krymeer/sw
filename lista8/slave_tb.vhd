library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.numeric_std.all;

entity slave_tb is
end slave_tb;
 
architecture behavior of slave_tb IS 
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
  
  -- outputs from UUT for debugging
  signal state: std_logic_vector(5 downto 0);
  signal vq: std_logic_vector (7 downto 0);
  signal current_cmd: std_logic_vector (3 downto 0);

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
 
  -- Instantiate the Unit Under Test (UUT)
  uut: slave 
  generic map (identifier => "10101010")
  port map(
    conn_bus => conn_bus,
    clk => clk,
    state => state,
    vq => vq,
    vcurrent_cmd => current_cmd
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

  -- 1) Getting the id of the processing unit (slave)
    -- address
    conn_bus <= "10101010";
    wait for clk_period;
    -- CMD: id
    conn_bus <= "00100000";
    wait for clk_period*2;
    -- address
    conn_bus <= "10101010";
    wait for clk_period;
    -- CMD: data_req
    conn_bus <= "01000000";
    wait for clk_period;
    -- this is needed to allow writing on bus by slave
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period;

    write_output("ID");
    -- other possible execution
    wait for clk_period*3;

  -- 2) Adding 64 to 33 (should get 97 = 01100001)
    -- address
    conn_bus <= "10101010";
    wait for clk_period;
    -- CMD: add
    conn_bus <= "00010000";
    wait for clk_period;
    -- 1st argument
    conn_bus <= "01000000";
    wait for clk_period;

    -- address
    conn_bus <= "10101010";
    wait for clk_period;
    -- CMD: add
    conn_bus <= "00010000";
    wait for clk_period;
    -- 2nd argument
    conn_bus <= "00100001";
    wait for clk_period;
    
    -- address
    conn_bus <= "10101010";
    wait for clk_period;
    -- CMD: data_req
    conn_bus <= "01000000";
    wait for clk_period;
    -- this is needed to allow writing on bus by slave
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period;

    write_output("ADD");
    wait for 3*clk_period;

  -- 3) An eight-time computing a CRC 102 = 0x66 = 1100110 (should get 139 = 0x8b = 10001011)
    -- address

    for i in 1 to 8 loop
      -- address
      conn_bus <= "10101010";
      wait for clk_period;
      -- CMD: crc
      conn_bus <= "00110000";
      wait for clk_period;
      -- data for CRC
      conn_bus <= "01100110";
      wait for clk_period;
    end loop;

    -- address
    conn_bus <= "10101010";
    wait for clk_period;
    -- CMD: data_req
    conn_bus <= "01000000";
    wait for clk_period;
    -- this is needed to allow writing on bus by slave
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period;

    write_output("CRC");
    wait for 3*clk_period;

  -- 4) Subtracting 99 from 24 (should get 75 = 01001011)
    -- address
    conn_bus <= "10101010";
    wait for clk_period;
    -- CMD: subtract
    conn_bus <= "01010000";
    wait for clk_period;
    -- 1st argument
    conn_bus <= "01100011";
    wait for clk_period;

    -- address
    conn_bus <= "10101010";
    wait for clk_period;
    -- CMD: subtract
    conn_bus <= "01010000";
    wait for clk_period;
    -- 2nd argument
    conn_bus <= "00011000";
    wait for clk_period;
    
    -- address
    conn_bus <= "10101010";
    wait for clk_period;
    -- CMD: data_req
    conn_bus <= "01000000";
    wait for clk_period;
    -- this is needed to allow writing on bus by slave
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period;

    write_output("SUB");
    wait for 3*clk_period;

    wait;
  end process;
end;