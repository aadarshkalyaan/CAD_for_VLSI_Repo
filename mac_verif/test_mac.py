# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import os
import random
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from model_mac import *

#-----------------------------------------------------------------------------------------------------
'''
Importing Test cases for mac int32
'''

def read_file_to_int(filepath):
    with open(filepath, 'r') as f:
        # Read lines and filter out empty lines before converting to int
        lines = f.readlines()
        # Remove empty lines and whitespace, then convert to int
        return [int(line.strip()) for line in lines if line.strip()]

# Replace the existing file reading code with this:
pwd = os.getcwd()

try:
    # Reading int8MAC test cases
    A_dec_int = read_file_to_int(os.path.join(pwd, 'mac_verif', 'test_cases', 'int8MAC', 'A_decimal.txt'))
    B_dec_int = read_file_to_int(os.path.join(pwd, 'mac_verif', 'test_cases', 'int8MAC', 'B_decimal.txt'))
    C_dec_int = read_file_to_int(os.path.join(pwd, 'mac_verif', 'test_cases', 'int8MAC', 'C_decimal.txt'))
    MAC_dec_int = read_file_to_int(os.path.join(pwd, 'mac_verif', 'test_cases', 'int8MAC', 'MAC_decimal.txt'))

    # Reading binary files
    A_bin_int = [int(a.strip(), 2) for a in open(os.path.join(pwd, 'mac_verif', 'test_cases', 'int8MAC', 'A_binary.txt')).readlines() if a.strip()]
    B_bin_int = [int(b.strip(), 2) for b in open(os.path.join(pwd, 'mac_verif', 'test_cases', 'int8MAC', 'B_binary.txt')).readlines() if b.strip()]
    C_bin_int = [int(c.strip(), 2) for c in open(os.path.join(pwd, 'mac_verif', 'test_cases', 'int8MAC', 'C_binary.txt')).readlines() if c.strip()]
    MAC_bin_int = [int(mac.strip()) for mac in open(os.path.join(pwd, 'mac_verif', 'test_cases', 'int8MAC', 'MAC_binary.txt')).readlines() if mac.strip()]

    # Reading bf16MAC test cases
    A_bin_fp = [int(a.strip(), 2) for a in open(os.path.join(pwd, 'mac_verif', 'test_cases', 'bf16MAC', 'A_binary.txt')).readlines() if a.strip()]
    B_bin_fp = [int(b.strip(), 2) for b in open(os.path.join(pwd, 'mac_verif', 'test_cases', 'bf16MAC', 'B_binary.txt')).readlines() if b.strip()]
    C_bin_fp = [int(c.strip(), 2) for c in open(os.path.join(pwd, 'mac_verif', 'test_cases', 'bf16MAC', 'C_binary.txt')).readlines() if c.strip()]
    MAC_bin_fp = [mac.strip() for mac in open(os.path.join(pwd, 'mac_verif', 'test_cases', 'bf16MAC', 'MAC_binary.txt')).readlines() if mac.strip()]

except FileNotFoundError as e:
    print(f"Error: Could not find test case file: {e.filename}")
    raise
except ValueError as e:
    print(f"Error: Invalid data found in test case files: {e}")
    raise

import os
import random
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge
from model_mac import *

# Keep your existing file reading code...
# [Previous file reading code remains the same until the test function]

@cocotb.test()
async def test_mac(dut):
    """Test MAC functionality according to BSV specification"""
    
    # Create a 10us period clock on port CLK
    clock = Clock(dut.CLK, 10, units="us")
    cocotb.start_soon(clock.start(start_high=False))
    
    # Reset
    dut.RST_N.value = 0
    await RisingEdge(dut.CLK)
    dut.RST_N.value = 1
    await RisingEdge(dut.CLK)
    
    # Initialize inputs
    dut.get_MAC_a.value = 0
    dut.get_MAC_b.value = 0
    dut.get_MAC_c.value = 0
    dut.get_MAC_s.value = 0
    
    dut._log.info('Starting MAC integer tests')
    
    # Test integer MAC operations
    for i in range(0, 1049):
        # Set inputs
        dut.get_MAC_s.value = 0  # Integer mode
        dut.get_MAC_a.value = A_bin_int[i]
        dut.get_MAC_b.value = B_bin_int[i]
        dut.get_MAC_c.value = C_bin_int[i]
        
        # Wait for computation
        await RisingEdge(dut.CLK)
        
        # Log and check results
        dut._log.info(f'Test {i}: a={A_bin_int[i]}, b={B_bin_int[i]}, c={C_bin_int[i]}')
        dut._log.info(f'Output: {dut.get_MAC.value}')
        
        assert int(MAC_bin_int[i]) == int(str(dut.get_MAC.value)), \
            f'MAC Output Mismatch, Expected = {MAC_bin_int[i]}, Got = {int(str(dut.get_MAC.value))}'
    
    dut._log.info('Integer MAC tests completed successfully')

import os
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb_coverage.coverage import coverage_db
from model_mac import model_mac

# Define or load test data for A, B, C, and expected MAC results here
# A_bin_int, B_bin_int, C_bin_int, MAC_bin_int should be defined or loaded in this scope

import os
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb_coverage.coverage import coverage_db
from model_mac import model_mac, sample_cases  # Import sample_cases from model_mac
def to_twos_complement(value, bit_width):
    if value < 0:
        # Apply two's complement by adding 2^bit_width to the negative number
        value = (1 << bit_width) + value
    return value

@cocotb.test()
async def test_mac_coverage(dut):
    """Test MAC operation with coverage tracking for S1 and S2 modes using random samples"""
    
    # Clock setup
    clock = Clock(dut.CLK, 10, units="us")
    cocotb.start_soon(clock.start(start_high=False))

    # Reset the DUT
    dut.RST_N.value = 0
    await RisingEdge(dut.CLK)
    dut.RST_N.value = 1

    # Loop through the pre-generated random test cases
    for a, b, c, s in sample_cases:
        
        # Set the inputs and mode in DUT
        dut.get_MAC_a.value = to_twos_complement(a,16)
        dut.get_MAC_b.value = to_twos_complement(b,16)
        dut.get_MAC_c.value = to_twos_complement(c,32)
        dut.get_MAC_s.value = 0

        # Wait for processing in DUT
        await RisingEdge(dut.CLK)
        await RisingEdge(dut.CLK)

        # Get the model's expected output for the current case
        expected_mac = model_mac(a, b, c, s)

        # Capture coverage data for current input values and mode
        model_mac(a, b, c, s)

        # Log and validate the output from DUT against the expected result
        dut._log.info(f"MAC Output in mode S{s}: {dut.get_MAC.value}")
        assert int(dut.get_MAC.value) == to_twos_complement(expected_mac,32), \
            f"MAC Output Mismatch in mode S{s}: Expected = {expected_mac}, Got = {int(dut.get_MAC.value)}, A = {a}, B = {b}, C = {c}"

    # Export the coverage results to a YAML file
    coverage_db.export_to_yaml(filename="coverage_mac.yml")


    
    # # Test floating point MAC operations
    # dut._log.info('Starting MAC floating point tests')
    
    # for i in range(0, 1000):
    #     # Set inputs
    #     dut.get_MAC_s.value = 1  # Floating point mode
    #     dut.get_MAC_a.value = A_bin_fp[i]
    #     dut.get_MAC_b.value = B_bin_fp[i]
    #     dut.get_MAC_c.value = C_bin_fp[i]
        
    #     # Wait for computation
    #     await RisingEdge(dut.CLK)
        
    #     # Log and check results
    #     dut._log.info(f'Test {i}: a={A_bin_fp[i]}, b={B_bin_fp[i]}, c={C_bin_fp[i]}')
    #     dut._log.info(f'Output: {dut.get_MAC.value}')
        
    #     assert str(MAC_bin_fp[i])[0:30] == str(dut.get_MAC.value)[0:30], \
    #         f'MAC Output Mismatch, Expected = {str(MAC_bin_fp[i])}, Got = {str(dut.get_MAC.value)}'
    
    # dut._log.info('Floating point MAC tests completed successfully')

