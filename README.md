# CAD_for_VLSI_Repo
## Done by Aadarsh Kalyaan EE21B001 and Sumeeth C Muchandimath EE21B145
This repository will be used for the projects of the course CS6230 (CAD for VLSI)

## Assignment 1 :
### Problem Statement:
To design and verify the simple MAC Operation for two cases : **A(int8) B(int8) C(int32) and A(bf16) B(bf16) C(fp32)**

We need to implement this **without** using **+ and \***.

### Design Approach
We started off by implement a simple Carry Look Ahead Adder, as it generates all the carry in one clock cycle, and need to be sequential. This eliminates some delay.

We first implemented a 8-bit CLA, as seen in *cla8.bsv*. Then we went ahead with designing and implementing a 8bit x 8bit signed multiplier, which performs a basic shift and add. This can be seen in *mul8.bsv*.

Then we implemented a 32 bit CLA, which just calls our 8 bit CLA 4 times as seen in cla32.bsv.

Hence the int8 part of the MAC was finished and then we combined it all together in *mac_int.bsv*. 



