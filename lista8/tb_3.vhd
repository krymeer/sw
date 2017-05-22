library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_3 is
end tb_3;
 
architecture behavior of tb_3 IS 
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
  signal clk_1, clk_2: std_logic := '0';

  --BiDirs
  signal conn_bus: std_logic_vector(7 downto 0) := (others => 'Z');
  
  -- outputs from UUTs for debugging
  signal state_1, state_2: std_logic_vector(5 downto 0);
  signal vq_1, vq_2: std_logic_vector (7 downto 0);
  signal current_cmd_1, current_cmd_2: std_logic_vector (3 downto 0);

  -- Clock period definitions
  constant clk_period: time := 10 ns;

begin
 
  -- instatiating the UUTs
  unit_1: slave 
  generic map (identifier => "10101010")
  port map(
    conn_bus => conn_bus,
    clk => clk_1,
    state => state_1,
    vq => vq_1,
    vcurrent_cmd => current_cmd_1
  );

  unit_2: slave 
  generic map (identifier => "10101011")
  port map(
    conn_bus => conn_bus,
    clk => clk_2,
    state => state_2,
    vq => vq_2,
    vcurrent_cmd => current_cmd_2
  );

  -- Clock process for the 1st processing unit
  clk_process_1: process
  begin
    clk_1 <= '0';
    wait for clk_period/2;
    clk_1 <= '1';
    wait for clk_period/2;
  end process;

  -- Clock process for the 2nd processing unit
  clk_process_2: process(clk_1)
  begin
    if clk_1 = '1' then
      clk_2 <= '0';
    else
      clk_2 <= '1';
    end if;
  end process;

-- Test: sending data to the 1st processing unit and receiving it in the 2nd processing unit
-- the 8-bit bus is cleared each time after sending the data
-- (the data is not needed when the clock is in state '0', so then the another processing unit may use the bus)

  -- stimulus process for 1st processing unit
  stim_proc_1: process
  begin
    -- work begins when the clock is in state '1'
    wait for clk_period/2;

  -- 1st processing unit: adding 0 to 169
    -- address
    conn_bus <= "10101010";
    wait for clk_period/2;
    -- clearing the bus
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period/2;

    -- CMD: add
    conn_bus <= "00010000";
    wait for clk_period/2;
    -- clearing the bus
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period/2;
    
    -- an argument (169)
    conn_bus <= "10101001";
    wait for clk_period/2;
    -- clearing the bus
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period/2;

  -- requiring data from 1st processing unit (should get 169 = 10101001)
    -- address
    conn_bus <= "10101010";
    wait for clk_period/2;
    -- clearing the bus
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period/2;

    -- CMD: data_req
    conn_bus <= "01000000";
    wait for clk_period/2;
    -- releasing the bus
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period/2;
    
    -- and here the data ought to show up on the bus and be grabbed by the 2nd processing unit
    
    wait;
  end process;

  stim_proc_2: process
  begin
    -- work begins moments before the "grabbed" number comes (demanded by DATA_REQ from the 1st processing unit)
    wait for clk_period*4;

    -- address
    conn_bus <= "10101011";
    wait for clk_period/2;
    -- releasing the bus
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period/2;

    -- CMD: add
    conn_bus <= "00010000";
    wait for clk_period/2;
    -- releasing the bus
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period/2; 

    -- and here the 2nd processing unit adds its own accumulator and a number from the 1st processing unit
    wait for clk_period;

  -- 2nd processing unit: adding 11 to the accumulator
    -- address
    conn_bus <= "10101011";
    wait for clk_period/2;
    -- releasing the bus
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period/2;

    -- CMD: add
    conn_bus <= "00010000";
    wait for clk_period/2;
    -- releasing the bus
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period/2;
    
    -- an argument (11)
    conn_bus <= "00001011";
    wait for clk_period/2;
    -- releasing the bus
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period/2;

    -- address
    conn_bus <= "10101011";
    wait for clk_period/2;
    -- releasing the bus
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period/2;

    -- CMD: data_req
    conn_bus <= "01000000";
    wait for clk_period/2;
    -- releasing the bus
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period/2;

  -- expected number on the bus: 180 (10110100) = 169 (1st processing unit) + 11 (2nd processing unit)

    wait;
  end process;

end;