-- Author: Krzysztof R. Osada, 2017

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.appendix.all;

entity ram_tb is
end ram_tb;

architecture behaviour of ram_tb is
  component ram is
  port(
    clk: in std_logic;
    to_write: in std_logic;
    address: in std_logic_vector(4 downto 0);
    data_in: in std_logic_vector(8 downto 0);
    data_out: out std_logic_vector(8 downto 0)
  );
  end component;

  -- inputs
  signal clk: std_logic := '0';
  signal to_write: std_logic := '0';
  signal address: std_logic_vector(4 downto 0) := (others => '0');
  signal data_in: std_logic_vector(8 downto 0) := (others => '0');

  -- output
  signal data_out: std_logic_vector(8 downto 0);

  -- clock period definition 
  constant clk_period: time := 10 ns;

begin

  -- Instatiating the UUT
  uut: ram
  port map(
    clk => clk,
    to_write => to_write,
    address => address,
    data_in => data_in,
    data_out => data_out
  );

  -- clock process definition
  clk_process: process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  -- Testing the RAM entity. First of all, a few words are stored at
  -- the given addresses, then one of them is loaded from the RAM
  -- and finally displayed on the output (TODO)
  test: process
  begin
    wait for 100 ns;

    to_write <= '1';
    address <= "00001";
    data_in <= "000100010";

    wait for clk_period;

    new_line;
    write_s("address:");
    write_v(address);
    write_s("data_in:");
    write_v(data_in);

    to_write <= '1';
    address <= "00010";
    data_in <= "000100001";

    wait for clk_period;

    to_write <= '1';
    address <= "00011";
    data_in <= "000100000";

    wait for clk_period;

    to_write <= '0';
    address <= "00001";
    data_in <= "000000000";

    wait for clk_period;

    new_line;
    write_s("...a few moments later...");
    new_line;

    write_s("address:");
    write_v(address);
    write_s("data_out:");
    write_v(data_out);

    new_line;
    
    wait;

  end process;
end;