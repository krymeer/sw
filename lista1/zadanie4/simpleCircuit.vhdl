entity simpleCircuit is
  port(i0, i1, i2 : in bit; o1, o2 : out bit);
end simpleCircuit;

architecture gates of simpleCircuit is
signal t0, t1 : bit;
begin
  t0 <= i0 and i1;
  t1 <= i1 or i2;
  o1 <= t0 nor t1;
  o2 <= t0 xor t1;
end gates;