-- Author: Krzysztof R. Osada, 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
  port (
    clk: in std_logic;
    to_write: in std_logic := '1';
    address: in std_logic_vector(4 downto 0);
    data_in: in std_logic_vector(8 downto 0);
    data_out: out std_logic_vector(8 downto 0)
  );
end ram;

-- A simple implementation of the RAM architecture
architecture arch of ram is
  -- Building the array for the RAM
  constant address_width: integer := 5;
  type ram_arr is array(natural(2 ** address_width - 1) downto 0) 
    of std_logic_vector(8 downto 0);

  -- Declaring the RAM signal
  signal ram_s: ram_arr;

  -- A holder of the memory address
  signal addr_reg: std_logic_vector(4 downto 0) := (others => '0');

begin
  
  -- A process declaration is necessary to handle the 'if' statement
  process(clk)
  begin
    if rising_edge(clk) then
      -- Writing the data at the specified address of the RAM
      if to_write = '1' then
        ram_s(to_integer(unsigned(address))) <= data_in;
      end if;

      -- Registering the address for further reading
      addr_reg <= address;
    end if;
  end process;

  -- Returning the contents stored at the given address
  data_out <= ram_s(to_integer(unsigned(addr_reg)));

end arch;