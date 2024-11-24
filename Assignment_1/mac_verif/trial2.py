import tensorflow as tf

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
print(bf16_fp32_operations(tf.cast(10.75,tf.bfloat16),tf.cast(7868380086272.0,tf.bfloat16),tf.cast(25.345001220703125,tf.float32)))