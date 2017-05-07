
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
 
ENTITY lossy_channel_tb IS
END lossy_channel_tb;
 
ARCHITECTURE behavior OF lossy_channel_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT lossy_channel
      GENERIC (N : positive);
      PORT(
         data_in : IN  std_logic_vector(N-1 downto 0);
         clk : IN  std_logic;
         data_out : OUT  std_logic_vector(N-1 downto 0)
        );
    END COMPONENT;
   
   -- channel bitwidth 
   constant WIDTH : positive := 16; 

   -- channel inputs
   signal data_in : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
   signal clk : std_logic := '0';

 	-- channel outputs
   signal data_out : std_logic_vector(WIDTH-1 downto 0);

   -- clock period definitions
   constant clk_period : time := 10 ns;

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

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: lossy_channel 
   GENERIC MAP ( N => WIDTH )
   PORT MAP (
          data_in => data_in,
          clk => clk,
          data_out => data_out
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
      variable line_w: line;
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

		for i in 0 to 255
		loop
			data_in <= std_logic_vector(to_unsigned(i, data_in'length));

			wait for clk_period;

      line_w := std_logic_vector_to_line(data_in);
      write(line_w, String'(" - ") & std_logic_vector_to_line(data_out).all);
      writeline(output, line_w);

			  assert data_in = data_out report "flip!";
		end loop;
      wait;
   end process;

END;
