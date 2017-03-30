library ieee;
use ieee.std_logic_1164.all;

entity statemachine is
  port(
    clk:    in std_logic;
    p:      in std_logic;
    reset:  in std_logic;
    r:      out std_logic := '0'
  );
end statemachine;

architecture Flow of statemachine is
  type state is (A, B, C, D);
  signal state_now: state := A;
  signal state_aft: state := B;

  begin
    state_advance: process(clk, reset)
    begin
      if reset = '1' then
        state_now <= A;
      elsif reset = '0' and rising_edge(clk) then
        if p = '1' then
          state_now <= state_aft;
        end if;
      end if;
    end process;

    next_state: process(state_now)
    begin
      case state_now is
        when A =>
          if p = '1' then
            state_aft <= B;
          end if;
          r <= '0';
        when B =>
          if p = '1' then
            state_aft <= C;
          end if;
          r <= '0';
        when C =>
          if p = '1' then
            state_aft <= D;
          end if;
          r <= '0';
        when D =>
          if p = '1' then
            state_aft <= B;
          else
            state_aft <= A;
          end if;
          r <= '1';
      end case;
    end process;

end Flow;