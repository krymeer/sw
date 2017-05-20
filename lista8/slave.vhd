library ieee;
use ieee.std_logic_1164.all;
--USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-----------------------------------------------------------------------
-- a (working) skeleton template for slave device on 8-bit bus
--    capable of executing commands sent on the bus in the sequence:
--    1) device_address (8 bits)
--    2) cmd_opcode (4 bits) & reserved (4 bits) 
--    3) (optional) cmd_args (8 bits)
--
-- currently supported commands: 
--  * ID      [0010] - get device address
--  * DATA_REQ  [1111] - send current result in the next clockpulse
--  * NOP     [0000] - don't do anything
-----------------------------------------------------------------------
-- debugging information on current state of statemachine and command
-- executed and input buffer register is given in outputs, vstate, 
-- vcurrent_cmd and vq, respectively
-----------------------------------------------------------------------

entity slave is
  generic(identifier: std_logic_vector(7 downto 0) := "10101010");
  port( 
    conn_bus: inout std_logic_vector(7 downto 0);
    clk: in std_logic;
    state: out std_logic_vector(5 downto 0);
    vq: out std_logic_vector(7 downto 0);
    vcurrent_cmd : out std_logic_vector(3 downto 0)
  );
end slave;

architecture Behavioral of slave is

  -- statemachine definitions
  type state_type is (IDLE, CMD, RUN);
  signal current_s: state_type := IDLE;
  signal next_s: state_type := IDLE;
  -- for debugging entity's state
  signal vstate: std_logic_vector(5 downto 0) := (others => '0');

  -- command definitions
  type cmd_type is (NOP, ADD, ID, CRC, DATA_REQ, SUB);
  attribute enum_encoding: string;
  attribute enum_encoding of cmd_type: type is
    "0000 0001 0010 0011 0100 0101";
  signal current_cmd: cmd_type := NOP;

  -- input buffer
  signal q: std_logic_vector (7 downto 0) := (others => '0');

  -- for storing results and indicating it is to be sent to bus
  signal result_reg: std_logic_vector (7 downto 0) := (others => '0');
  signal sending: std_logic := '0';

  -- function that returns a sum of (at least) two numbers
  function add(accumulator: in std_logic_vector; n: in std_logic_vector) return std_logic_vector is
    variable carry, sum: std_logic_vector(7 downto 0) := "00000000";
  begin
    for i in 0 to 7 loop
      sum(i) := carry(i) xor accumulator(i) xor n(i);
      if i < 7 then
        carry(i+1) := (accumulator(i) and n(i)) or (accumulator(i) and carry(i)) or (n(i) and carry(i));
      end if;
    end loop; 
    return sum;
  end add;

  -- function that computes a difference between two numbers (providing that A >= B)
  function subtract(accumulator: in std_logic_vector; n: std_logic_vector) return std_logic_vector is
    variable borrow, difference: std_logic_vector(7 downto 0) := "00000000";
  begin
    if accumulator = "00000000" then
      return n;
    elsif accumulator < n then
      return "00000000";
    end if;
    for k in 0 to 7 loop
      difference(k) := accumulator(k) xor n(k) xor borrow(k);
      if k < 7 then
        borrow(k+1) := (not(accumulator(k) xor n(k)) and borrow(k)) or (not(accumulator(k)) and n(k));
      end if;
    end loop;
    return difference;
  end subtract;

  -- function that compute a CRC of a given number
  function computeCRC(crc: in std_logic_vector; n: in std_logic_vector) return std_logic_vector is
    variable newCRC: std_logic_vector(7 downto 0);
  begin
    newCRC(0) := n(7) xor n(6) xor n(0) xor crc(0) xor crc(6) xor crc(7);
    newCRC(1) := n(6) xor n(1) xor n(0) xor crc(0) xor crc(1) xor crc(6);
    newCRC(2) := n(6) xor n(2) xor n(1) xor n(0) xor crc(0) xor crc(1) xor crc(2) xor crc(6);
    newCRC(3) := n(7) xor n(3) xor n(2) xor n(1) xor crc(1) xor crc(2) xor crc(3) xor crc(7);
    newCRC(4) := n(4) xor n(3) xor n(2) xor crc(2) xor crc(3) xor crc(4);
    newCRC(5) := n(5) xor n(4) xor n(3) xor crc(3) xor crc(4) xor crc(5);
    newCRC(6) := n(6) xor n(5) xor n(4) xor crc(4) xor crc(5) xor crc(6);
    newCRC(7) := n(7) xor n(6) xor n(5) xor crc(5) xor crc(6) xor crc(7);
    return newCRC;
  end computeCRC;

begin

  stateadvance: process(clk)
  begin
    if rising_edge(clk) then
      q <= conn_bus;
      current_s <= next_s;
    end if;
  end process;

  nextstate: process(current_s,q)
    variable fourbit: std_logic_vector(3 downto 0) := "0000";
    variable curr_crc, add_acc, sub_acc: std_logic_vector(7 downto 0) := "00000000";
  begin
    case current_s is
      when IDLE =>
        vstate <= "000001";   -- set for debugging
        if q = identifier and sending /= '1' then
          next_s <= CMD;
        else
          next_s <= IDLE;
        end if;
        sending <= '0';
      when CMD =>
        vstate <= "000010";
        -- command decode
        fourbit := q(7 downto 4);
        case fourbit is
          when "0000" => current_cmd <= NOP;
          when "0001" => current_cmd <= ADD;
          when "0010" => current_cmd <= ID;
          when "0011" => current_cmd <= CRC;
          when "0100" => current_cmd <= DATA_REQ;
          when "0101" => current_cmd <= SUB;
          when others => current_cmd <= NOP;
        end case;
        next_s <= RUN;
      when RUN =>
        vstate <= "000100";
        -- determine action based on currend_cmd state
        case current_cmd is
          when NOP
            => result_reg <= result_reg;
          when ID
            => result_reg <= identifier;
          when DATA_REQ
            => sending <= '1';
          when ADD =>
            add_acc := add(add_acc, q);
            result_reg <= add_acc;
          when SUB =>
            sub_acc := subtract(sub_acc, q);
            result_reg <= sub_acc;
          when CRC =>
            curr_crc := computeCRC(curr_crc, q);
            result_reg <= curr_crc;
          when others
            => result_reg <= result_reg;
        end case;
        next_s <= IDLE;
      when others => 
        vstate <= "111111";
        next_s <= IDLE;
    end case;
end process;

-- tri-state bus
conn_bus <= result_reg when sending = '1' else "ZZZZZZZZ";

-- output debugging signals
state <= vstate; 
vq    <= q;

  with current_cmd select
    vcurrent_cmd <= "0001" when ADD,
      "0010" when ID, 
      "0011" when CRC, 
      "0100" when DATA_REQ,
      "0101" when SUB,
      "0000" when others;

end Behavioral;