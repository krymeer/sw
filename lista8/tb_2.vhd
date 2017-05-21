library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_2 is
end tb_2;
 
architecture behavior of tb_2 IS 
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
  clk_process_2: process
  begin
    clk_2 <= '0';
    wait for clk_period/8;
    clk_2 <= '1';
    wait for clk_period/8;
  end process;

-- Test: sending data to the 1st processing unit and receiving it in the 2nd processing unit

  -- stimulus process for 1st processing unit
  stim_proc_1: process
  begin    
    wait for 100 ns;

  -- 1st processing unit: adding 0 to 169
    -- address
    conn_bus <= "10101010";
    wait for clk_period;
    -- CMD: add
    conn_bus <= "00010000";
    wait for clk_period;
    -- an argument (169)
    conn_bus <= "10101001";
    wait for clk_period;

  -- requiring data from 1st processing unit (should get 169 = 10101001)
    -- address
    conn_bus <= "10101010";
    wait for clk_period;
    -- CMD: data_req
    conn_bus <= "01000000";
    wait for clk_period;
    -- releasing the bus
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period;

    wait;
  end process;

  stim_proc_2: process
  begin
    wait for 150 ns;

  -- 2nd processing unit starts the adding command
    -- address
    conn_bus <= "10101011";
    wait for clk_period/4;
    -- CMD: add
    conn_bus <= "00010000";
    wait for clk_period/4;

  -- 2nd processing unit clears data on the bus
  -- it does it in order to "steal" a number from 1st processing unit
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period;

  -- 2nd processing unit: adding 11 to the accumulator
    conn_bus <= "10101011";
    wait for clk_period/4;
    -- CMD: add
    conn_bus <= "00010000";
    wait for clk_period/4;
    -- an argument (11)
    conn_bus <= "00001011";
    wait for clk_period/4;

  -- requiring data from 2nd processing unit
  -- expected output: 10110100 (180)
    conn_bus <= "10101011";
    wait for clk_period/4;
    -- CMD: data_req
    conn_bus <= "01000000";
    wait for clk_period/4;
    conn_bus <= "ZZZZZZZZ";
    wait for clk_period/4;

    wait;
  end process;

end;