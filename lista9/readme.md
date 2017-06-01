# List 9
### A simple implementation of the MARIE processing unit
Author: Krzysztof Osada, 2017

**Note**: this is my own version of the final task for the Embedded Systems course. Please be advised that the code was posted here only for security purposes, so if you cannot help stealing my bloody work, do it wisely and do not get me into *your* trouble.


##### An example of the MARIE program 
A simple file which consists of 7 lines (numbered from 0 to 6).
```  
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
```

##### System entities
Each element is connected with a special "address" (which is, frankly speaking, just a binary number) that helps identify a component without a doubt.

| Word | Entity | Further details | 
| --------|---------|-------|
| 111100000 | RAM | reading data at a specified address |
| 111100001 | RAM | storing data in the memory |
| 111100010 | PC | jumping to a specified address of an instruction |
| 111100011 | PC | skipping one of instructions |
| 111100100 | REG | updating the MAR (*memory address register*) |
| 111100101 | REG | getting the MAR value
| 111100110 | REG | updating the MBR (*membory buffer register*) |
| 111100111 | REG | getting the MBR value |
| 111101000 | REG | updating the accumulator (AC) |
| 111101001 | REG | getting the value of the accumulator |
| 111101010 | REG | updating the InREG value |
| 111101011 | REG | getting the InREG value |
| 111101100 | REG | updating the OutREG value |

Each entity call begins with ``1111`` so as to distinguish it from MARIE instructions and binary values.
~~**Note**: only first **four** codes are implemented so far.~~ ~Everything should work like a charm.~

#####  RAM (reading)
Required syntax:
```
 111100000
 0000XXXXX
```
where ``XXXXX`` - an address at the memory - is a binary value from 0 to 31.
Four oldest bits should be equal to zero.

##### RAM (storing)
Required syntax
```
111100001
0000XXXXX
0000YYYYY
```
where ``XXXXX`` - an address at the memory - is a binary value from 0 to 31.
Last but not least, ``YYYYY`` is a value which will be stored in the RAM entity. **Note** that this number *cannot* be greater than 31 because it could be confused with operations (words starting with `0001`, `0010`,.., `1001`) or system entities' codes (words starting with `1111`).

##### PC (jumping)
Required syntax:
```
111100010
0000XXXXX
```
where ``XXXXX`` is a new value of the PC register; it holds the address at the RAM entity,
which contains a value or an instruction from the MARIE program.

##### PC (skipcond)
Required syntax:
```
111100011
```
Skipping one address defined at the RAM entity, more precisely: a value of the PC register.
It could be useful when there is a need to omit one of the program instructions.

##### MAR (updating)
Required syntax:
```
111100100
0000XXXXX
```
Storing the address `XXXXX` in the *memory address register*.

##### MAR (getting)
Required syntax:
```
111100101
```
Getting the address stored in the *memory address register*.

##### MBR (updating)
Required syntax:
```
111100110
0000XXXXX
```
Storing the value `XXXXX` in the *memory buffer register*.

##### MBR (getting)
Required syntax:
```
111100111
```
Getting the value stored in the *memory buffer register*.

##### AC (updating)
Required syntax:
```
111101000
0000XXXXX
```
Storing the value `XXXXX` in the accumulator.

##### AC (getting)
Required syntax:
```
111101001
```
Getting the value of the accumulator.
##### inREG (updating)
Required syntax:
```
111101010
```
If the number entered by the user is valid (a natural number from 0 to 31), it is stored in the inREG.

##### inREG (getting)
Required syntax:
```
111101011
```
Getting the value entered by the user.

##### outREG
Required syntax:
```
111101100
0000XXXXX
```
Storing the value `XXXXX` in the outREG, which will be printed then on the standard output.