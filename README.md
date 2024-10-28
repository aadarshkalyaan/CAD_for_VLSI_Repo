# CAD_for_VLSI_Repo
## Done by Aadarsh Kalyaan EE21B001 and Sumeeth C Muchandimath EE21B145
This repository will be used for the projects of the course CS6230 (CAD for VLSI)

## Assignment 1 :
## Problem Statement:
To design and verify the simple MAC Operation for two cases : **A(int8) B(int8) C(int32) and A(bf16) B(bf16) C(fp32)**

We need to implement this **without** using **+ and \***.

## Design Approach
### Int 8
We started off by implement a simple Carry Look Ahead Adder, as it generates all the carry in one clock cycle, and need to be sequential. This eliminates some delay.

We first implemented a 8-bit CLA, as seen in ***cla8.bsv***. Then we went ahead with designing and implementing a signed 8 bit x 8 bit signed multiplier, which performs a basic shift and add. This can be seen in ***mul8.bsv***.

Then we implemented a 32 bit CLA, which just calls our 8 bit CLA 4 times as seen in cla32.bsv.

Hence the int8 part of the MAC was finished and then we combined it all together in ***mac_int.bsv***. 

### BF16
Here since we already some basic blocks of the adders and multipliers from the previous part, we went ahead with performing multiplication of two bf16 number.

Since the multiplication is taking the ***XOR*** of the sign bit, and taking sum of the exponents, it is easily done as we have a 8-bit CLA, we can use that for the exponent addition. Then we need to append the implicit 1 to the mantissa and then perform unsigned multiplication. For this we created an 8 bit x 8 bit unsigned multiplier ***umul8.bsv***. 

Then we perform **Round Off** according the IEEE standard to the 16 bit bf16 product. Then we pad the mantissa with zeros and convert it to fp32. This is encapsulated in ***bf_mul.bsv***

Addition of two fp32 numbers is a challenge as we need to ensure that we **Round Off** whenever we right shift some information out of scope in the mantissa. According to the rules of fp32 additon, we first find out which number has the bigger exponent and then left shift the exponent of the smaller number to ensure uniformity. The exponent part is done.

We then right shift the mantissa (after appending the implicit 1) of the smaller number to compensate the left shifting. Then we add these numbers using our 48 bit CLA, as seen in ***cla48.bsv***. Then we perform round off to truncate to 23 bits according to the IEEE standard.

All these functions are performed in the file ***fp_add.bsv***.

The entire MAC of BF16 is encapsulated in ***mac_bf16.bsv***

The entire function is captured in ***top.bsv*** with the interface provided in the problem statement.

## Validation with provided test cases and cocotb

As seen below, our MAC satisfies the given testcases for INt8 and BF16.

![intpass](https://github.com/user-attachments/assets/0f2e77dc-5ba6-4036-ba32-1c0572855e04)

INT 8 Testcases Passing

![bf16pass](https://github.com/user-attachments/assets/9fc6200f-f62a-4a62-a44b-054114672ec4)

BF16 Testcases Passing

## Pipelining

We piplined our designs by pipelining our stages in multiplier as well as adder. Everywhere we have an 16 bit CLA, we add specialFIFOS at the input and output, effectively pipelining all our designs! Since the 16 bit CLA is used througout the design, we felt this decision would yield the most benefit!

All the pipelined designs are pre-fixed with ***pl_***.

Int 8 MAC Pipelined:

![plmacint](https://github.com/user-attachments/assets/a43e11f4-4aa4-474a-ae05-98bca35cbb53)

Int 8 MAC without pipelining:

![macint](https://github.com/user-attachments/assets/465dd1e4-3146-4d18-a400-16f07fbc710f)

BF16 MAC Pipelined:

![plmacbf16](https://github.com/user-attachments/assets/9714598b-6960-4e85-a930-0c16d7cb8122)

BF16 MAC without pipelining:

![macbf16](https://github.com/user-attachments/assets/d5af0b1f-9c89-47de-b659-ed66db085093)

## Coverage

As you can see in the ***test_mac.py*** code for int8, we have achieved ***91.49%*** coverage with a fixed seed and 1,00,00,000 test cases randomly chosen in the range. The .yml can be seen in ***int8_coverage_mac.yml***.


Since the range of BF16 was too big, we were unable to sucessfully implementing by taking the range, so we took a pattern of walking ones and zeros and implemented it.


## Running the Files
To run the files, use src_BSV as mentioned in the examples.

To use the testing files, please refer the ***folder counter*** and run as given in the example, ensure to put the testcases folder in mac_verif.



