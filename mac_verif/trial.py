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
print((signed_8bit_mult_add(0b0000000001111000,0b0000000010001001,0b00000000000000000000010111101011)))