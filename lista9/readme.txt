A simple implementation of the MARIE processing unit
Author: Krzysztof Osada, 2017

0. An example of the MARIE program
  #0 Load 4 
    000100100
  #1 Add 5
    001100101
  #2 Store 6
    001000110
  #3 Halt
    011100000
  #4 Number 16
    000010000
  #5 Number 7
    000000111
  #6 Memory location for the result
    000000000
which consists of 7 lines (from 0 to 6).

1. System entities
Each element is connected with a special "address" (which is, frankly speaking, just a binary number) that helps identify a component without a doubt.

1111 00000	RAM (reading)
1111 00001	RAM (storing)
1111 00010	PC
1111 00011	AC
1111 00100	Controller
to be continued...

1.1 RAM (reading)
Required syntax:
  111100000
  0000XXXXX
where 'XXXXX' - an address at the memory - is a binary value from 0 to 31.
Four oldest bits should be equal to zero.

1.2 RAM (storing)
Required syntax
  111100000
  0000XXXXX
  YYYYYYYYY
where 'XXXXX' - an address at the memory - is a binary value from 0 to 31.
Last but not least, 'YYYYYYYYY' is a value which will be stored in the RAM entity.