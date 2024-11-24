import cocotb
from cocotb_coverage.coverage import coverage_section, CoverPoint, CoverCross
import random
import tensorflow as tf
import numpy as np

# Set random seed for reproducibility
random.seed(2)

# Generate 1000 unique random cases for a, b, c, and s
sample_cases = set()
while len(sample_cases) < 100000:
    a = random.randint(-128, 127)  # 8-bit range for S1 mode
    b = random.randint(-128, 127)
    c = random.randint(-2147483648, 2147483647)  # 32-bit range for c
    s = random.choice([0])  # Mode selection
    sample_cases.add((a, b, c, s))

# Separate the cases for a, b, c, and s bins
a_cases = {case[0] for case in sample_cases}
b_cases = {case[1] for case in sample_cases}
c_cases = {case[2] for case in sample_cases}
s_cases = {case[3] for case in sample_cases}

# Define coverage points based on generated samples
mac_coverage = coverage_section(
    CoverPoint('mac_operation.s', vname='s', bins=list(s_cases)),
    CoverPoint('mac_operation.a', vname='a', bins=list(a_cases)),
    CoverPoint('mac_operation.b', vname='b', bins=list(b_cases)),
    CoverPoint('mac_operation.c', vname='c', bins=list(c_cases)),
    CoverCross('mac_operation.inputs_cross', items=['mac_operation.a', 'mac_operation.b', 'mac_operation.s'])
)

@mac_coverage
def model_mac1(a: tf.bfloat16, b: tf.bfloat16, c: tf.float32, s: int) -> int:
    """
    MAC operation model for S1 (int32) and S2 (fp32) modes with coverage.
    In S1 mode (s=0): compute int32 MAC with a[7:0] and b[7:0].
    In S2 mode (s=1): return a placeholder for fp32 MAC result.
    """
    if s == 1:
        # Placeholder for fp32 MAC result (since exact fp32 modeling isn’t specified here)
        return bf16_fp32_operations(a,b,c)
    else:
        # S1 mode uses int32 computation with lower 8 bits of a and b
        return signed_8bit_mult_add(a,b,c)

sample_cases1 = set()
while len(sample_cases1) < 1000:
    a = tf.random.uniform([], minval=-3.4e38, maxval=3.4e38, dtype=tf.bfloat16)
    b = tf.random.uniform([], minval=-1.0, maxval=1.0, dtype=tf.bfloat16)
    c = tf.random.uniform([], minval=-1.0, maxval=1.0, dtype=tf.float32)
    sample_cases1.add((a, b, c, s))

# Separate the cases for a, b, c, and s bins
a_cases = {case[0] for case in sample_cases}
b_cases = {case[1] for case in sample_cases}
c_cases = {case[2] for case in sample_cases}
s_cases = {case[3] for case in sample_cases}

# Define coverage points based on generated samples
mac_coverage = coverage_section(
    CoverPoint('mac_operation.s', vname='s', bins=list(s_cases)),
    CoverPoint('mac_operation.a', vname='a', bins=list(a_cases)),
    CoverPoint('mac_operation.b', vname='b', bins=list(b_cases)),
    CoverPoint('mac_operation.c', vname='c', bins=list(c_cases)),
    CoverCross('mac_operation.inputs_cross', items=['mac_operation.a', 'mac_operation.b', 'mac_operation.s'])
)
@mac_coverage
def model_mac(a: int, b: int, c: int, s: int) -> int:
    """
    MAC operation model for S1 (int32) and S2 (fp32) modes with coverage.
    In S1 mode (s=0): compute int32 MAC with a[7:0] and b[7:0].
    In S2 mode (s=1): return a placeholder for fp32 MAC result.
    """
    if s == 1:
        # Placeholder for fp32 MAC result (since exact fp32 modeling isn’t specified here)
        return c + (a << 16) + (b << 8)
    else:
        # S1 mode uses int32 computation with lower 8 bits of a and b
        return signed_8bit_mult_add(a,b,c)
def bf16_fp32_operations(a_bf16, b_bf16, c_fp32):
    """
    Perform the following operations:
    1. Multiply two BF16 numbers (a_bf16 and b_bf16)
    2. Check for overflow and underflow
    3. Round the result according to BF16 standard
    4. Convert the result to FP32
    5. Add the result to another FP32 number (c_fp32)
    6. Report the final answer in FP32 format
    
    Parameters:
    a_bf16 (tf.bfloat16): First BF16 number
    b_bf16 (tf.bfloat16): Second BF16 number
    c_fp32 (tf.float32): FP32 number to be added
    
    Returns:
    tf.float32: Final result of the operation
    """
    # Multiply the two BF16 numbers
    result_bf16 = a_bf16 * b_bf16
    
    # Check for overflow and underflow
    if tf.math.is_inf(result_bf16) or tf.math.is_nan(result_bf16):
        print("Overflow or underflow occurred during the BF16 multiplication.")
        return None
    
    # Round the result according to BF16 standard
    result_bf16_rounded = tf.cast(result_bf16, tf.bfloat16)
    
    # Convert the result to FP32
    result_fp32 = tf.cast(result_bf16_rounded, tf.float32)
    
    # Add the result to the FP32 number
    final_result = result_fp32 + c_fp32
    final_result = tf.cast(final_result,tf.float32)
    
    return final_result
# def signed_8bit_mult_add(a: int, b: int, c: int) -> int:
#     """
#     Multiplies the least significant 8 bits of two signed 16-bit integers `a` and `b`,
#     adds the result to a signed 32-bit integer `c`, and returns the 32-bit signed result.
#     """
#     # Mask and extract the least 8 bits
#     a_8bit = a & 0xFF
#     b_8bit = b & 0xFF
    
#     # Convert to signed 8-bit numbers
#     if a_8bit >= 0x80:
#         a_8bit -= 0x100
#     if b_8bit >= 0x80:
#         b_8bit -= 0x100

#     # Perform the signed 8-bit multiplication
#     product = a_8bit * b_8bit

#     # Add the product to `c`, treating `c` as a signed 32-bit integer
#     result = c + product

#     # Ensure the result fits within a signed 32-bit range
#     if result > 0x7FFFFFFF:
#         result -= 0x100000000
#     elif result < -0x80000000:
#         result += 0x100000000

#     return result

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