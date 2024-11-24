import cocotb
from cocotb_coverage.coverage import coverage_section, CoverPoint, CoverCross
import random
from testcases import *
# Set random seed for reproducibility
random.seed(2)

# Generate 1000 unique random cases for a, b, c, and s
sample_cases = set()
a = random.sample(zeros_16bit+ones_16bit,100)
b = random.sample(zeros_16bit+ones_16bit,100)
c = random.sample(zeros_32bit+ones_32bit,100)

# Separate the cases for a, b, c, and s bins
a_cases = {a}
b_cases = {b}
c_cases = {c}
s_cases = {1}

# Define coverage points based on generated samples
mac_coverage = coverage_section(
    CoverPoint('mac_operation.a', vname='a', bins=list(a_cases)),
    CoverPoint('mac_operation.b', vname='b', bins=list(b_cases)),
    CoverPoint('mac_operation.c', vname='c', bins=list(c_cases)),
    CoverCross('mac_operation.inputs_cross', items=['mac_operation.a', 'mac_operation.b', 'mac_operation.c'])
)
import numpy as np

def binary_operations(a_bin16, b_bin16, c_bin32):
    # Convert binary strings to integers
    a_int16 = int(a_bin16, 2)
    b_int16 = int(b_bin16, 2)
    c_int32 = int(c_bin32, 2)

    # Multiply the two 16-bit binary numbers
    result_int16 = a_int16 * b_int16

    # Check for overflow and underflow
    if result_int16 > 65535 or result_int16 < -65535:
        print("Overflow or underflow occurred during the 16-bit binary multiplication.")
        return None

    # Round the result according to 16-bit standard
    result_int16_rounded = np.clip(result_int16, -32768, 32767)

    # Convert the result to 32-bit binary
    result_bin32 = "{0:032b}".format(result_int16_rounded)

    # Add the result to the 32-bit binary number
    final_result_int32 = c_int32 + int(result_bin32, 2)
    final_result_bin32 = "{0:032b}".format(final_result_int32)

    return final_result_bin32
@mac_coverage
def model_mac(a: int, b: int, c: int, s: int) -> int:
    """
    MAC operation model for S1 (int32) and S2 (fp32) modes with coverage.
    In S1 mode (s=0): compute int32 MAC with a[7:0] and b[7:0].
    In S2 mode (s=1): return a placeholder for fp32 MAC result.
    """
    if s == 1:
        # Placeholder for fp32 MAC result (since exact fp32 modeling isn’t specified here)
        return binary_operations(a,b,c)
    else:
        # S1 mode uses int32 computation with lower 8 bits of a and b
        return signed_8bit_mult_add(a,b,c)

def signed_8bit_mult_add(a: int, b: int, c: int) -> int:
    """
    Multiplies the least significant 8 bits of two signed 16-bit integers `a` and `b`,
    adds the result to a signed 32-bit integer `c`, and returns the 32-bit signed result.
    """
    # Mask and extract the least 8 bits
    a_8bit = a & 0xFF
    b_8bit = b & 0xFF
    
    # Convert to signed 8-bit numbers
    if a_8bit >= 0x80:
        a_8bit -= 0x100
    if b_8bit >= 0x80:
        b_8bit -= 0x100

    # Perform the signed 8-bit multiplication
    product = a_8bit * b_8bit

    # Add the product to `c`, treating `c` as a signed 32-bit integer
    result = c + product

    # Ensure the result fits within a signed 32-bit range
    if result > 0x7FFFFFFF:
        result -= 0x100000000
    elif result < -0x80000000:
        result += 0x100000000

    return result

# # model for increment alone

# import cocotb
# from cocotb_coverage.coverage import *

# mac_coverage = coverage_section(
#     CoverPoint('top.increment_di', vname='increment_di', bins = list(range(0,16))),
#     CoverPoint('top.EN_increment', vname='EN_increment', bins = list(range(0,2))),
#     CoverCross('top.cross_cover', items = ['top.increment_di', 'top.EN_increment'])
# )
# @mac_coverage
# def model_mac(current_state, EN_increment: int, increment_di: int) -> int:
#     if(EN_increment):
#         return current_state + 2 * increment_di
#     return 0e3