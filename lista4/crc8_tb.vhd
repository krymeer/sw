LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;

ENTITY crc8_tb IS
END crc8_tb;
 
ARCHITECTURE behavior OF crc8_tb IS 
    -- main component counting CRC sums
    COMPONENT crc8
    PORT(
         clk : IN  std_logic;
         data_in : IN  std_logic_vector(7 downto 0);
         crc_out : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
	 -- component delcaration for ROM look-up 
	 component rom_for_crc8
    Port ( address  : in  STD_LOGIC_VECTOR (2 downto 0);
           data_out : out  STD_LOGIC_VECTOR (7 downto 0)
			);
	 end component;
    
	-- clock stuff
   signal clk : std_logic := '0';
   -- clock period 
   constant clk_period : time := 20 ns;
	
	-- CRC generator data
	-- input
   signal data_in : std_logic_vector(7 downto 0) := (others => '0');
   -- output 
   signal crc_out : std_logic_vector(7 downto 0);

	-- ROM
   -- output data 
	signal data_out_a0 : std_logic_vector(7 downto 0);
	signal data_out_66 : std_logic_vector(7 downto 0);
	-- access address
	signal address : std_logic_vector(2 downto 0) := (others => '0');

procedure checkCRC(signal data, address: inout std_logic_vector) is
variable l: line;
variable s: string(1 to 3);
begin

  for i in 0 to 7 loop 
    address <= std_logic_vector(to_unsigned(i, address'length));
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '0';

    -- writing binary representation of CRC sums
    for i in 7 downto 0 loop
      s := std_logic'image(crc_out(i));
      write(l, s(2));
    end loop;
    write(l, String'(" - "));
    for i in 7 downto 0 loop
      if data = X"a0" then
        s := std_logic'image(data_out_a0(i));
      else
        s := std_logic'image(data_out_66(i));
      end if;
      write(l, s(2));
    end loop;
    writeline(output, l);

    -- checking whether the CRC sum corresponds with the value stored in ROM
    if data = X"a0" then
      assert crc_out = data_out_a0
      report "invalid crc value" severity error;
    else
      assert crc_out = data_out_66
      report "invalid crc value" severity error;
    end if;
  end loop;

  writeline(output, l);
end procedure checkCRC;

BEGIN
 	-- Instantiate the Unit Under Test (UUT)
   uut: crc8 PORT MAP (
          clk => clk,
          data_in => data_in,
          crc_out => crc_out
        );
		  
	 -- instance of ROM lookup for constant X"a0" input
	 rom_a0 : entity work.rom_for_crc8(const_a0)
	 port map (
			 address => address,
			 data_out => data_out_a0
		  );
	 -- instance of ROM lookup for constant X"66" input
	 rom_66 : entity work.rom_for_crc8(const_66) 
	 port map (
	 		 address => address,
			 data_out => data_out_66
		  );

   -- Clock process definitions
   clk_process :process
	  variable wait_done : natural := 0;
   begin
	   if wait_done = 0
		then
		   wait for clk_period * 0.2;
			wait_done := 1;
	   end if;
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
   end process;
 
   -- Stimulus process
  stim_proc: process
  variable s: string(1 to 3);
  variable l: line;
  begin
    data_in <= X"66";
    checkCRC(data_in, address);    
    data_in <= X"a0";
    checkCRC(data_in, address);
    
    wait; 

  end process;

END;
