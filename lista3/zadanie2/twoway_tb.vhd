LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY twoway_tb IS
END twoway_tb;
 
ARCHITECTURE behavior OF twoway_tb IS 
 
    component twoway is
      generic(NBit: integer);
      port(
        clk: in std_logic;
        q: out std_logic_vector(NBit-1 downto 0)
      );
    end component;
    
   -- input signal
  signal clk : std_logic := '0';

  constant nb: integer := 8;

  -- output signal
  signal q : std_logic_vector(nb-1 downto 0);

  -- set clock period 
  constant clk_period : time := 20 ns;
 
BEGIN
  -- instantiate UUT
   uut: twoway GENERIC MAP(NBit => nb) 
        PORT MAP (
          clk => clk,
          q => q
        );
   
   -- clock management process
   -- no sensitivity list, but uses 'wait'
  clk_process: process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  stim_proc: process
  begin
    wait;
  end process;
  
END;
