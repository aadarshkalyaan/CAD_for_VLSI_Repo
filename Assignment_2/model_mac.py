class BF16:
    def __init__(self, sign, exp, mant):
        self.sign = sign
        self.exp = exp
        self.mant = mant

class FP32:
    def __init__(self, sign, exp, mant):
        self.sign = sign
        self.exp = exp
        self.mant = mant

def binary_string_to_int(str):
    """Convert binary string to integer"""
    t=len(str)
    r=0
    for i in range(t):
        if str[i]=='1':
            r+=2**(t-1-i)
    return r
def int_to_binary_string(num, width):
    """Convert integer to binary string with fixed width"""
    return format(num, f'0{width}b')

def normalise_bf16(z):
    """Normalize the mantissa and handle rounding for BF16"""
    p = int_to_binary_string(z,17)
    if (p[0]==1):
        p = '0'+p[0:16]
    
    mantissa =  '0'+p[2:9]
    round_bit = p[9]
    if '1' in p[10:]:
        sticky_bit = 1
    else:
        sticky_bit = 0
    
    result = binary_string_to_int(mantissa)
    if (round_bit=='1') and ((sticky_bit==1) or (mantissa[7]=='1')):
        result = result+1
        
    return int_to_binary_string(result,8)

def normalise_fp32(z):
    """Normalize the mantissa and handle rounding for FP32"""
    p = z
    if (p[0]==1):
        p = '0'+p[0:24]
    
    mantissa = '0'+p[2:25]
    round_bit = p[25]
    if '1' in p[26:]:
        sticky_bit = 1
    else:
        sticky_bit = 0
    
    result = binary_string_to_int(mantissa)
    if (round_bit=='1') and ((sticky_bit==1) or (mantissa[7]=='1')):
        result = result+1
        
    return int_to_binary_string(result,24)

def bf16_mul(a_str, b_str):
    """Brain Float 16 multiplication implementation"""
    print(a_str,b_str)
    inp1 = BF16(
        sign=binary_string_to_int(a_str[0]),
        exp=binary_string_to_int(a_str[1:9]),
        mant=binary_string_to_int(a_str[9:])
    )
    inp2 = BF16(
        sign=binary_string_to_int(b_str[0]),
        exp=binary_string_to_int(b_str[1:9]),
        mant=binary_string_to_int(b_str[9:])
    )

    # Multiply mantissas (including implicit 1)
    z = (binary_string_to_int('1'+ a_str[9:])) * (binary_string_to_int('1'+ b_str[9:]))
    print((binary_string_to_int('1'+ a_str[9:])),'1'+ a_str[9:])
    print((binary_string_to_int('1'+ b_str[9:])),'1'+ b_str[9:])
    print(z)
    # Normalize result
    m = normalise_bf16((z << 1))
    
    # Handle exponents
    x = (inp1.exp + 0x81)
    y = (inp2.exp + 0x81)
    
    if (z >> 15) & 1:
        exp = (x + y + 1) 
    else:
        exp = (x + y)
    
    if (m[0]=='1'):
        x1 = (exp - 0x81 +1) & 0xFF
    else:
        x1 = (exp - 0x81) & 0xFF
    
    result_sign = inp1.sign ^ inp2.sign
    result_exp = x1 
    result_mant = m
    
    # Convert BF16 result to FP32 format
    fp32_mant = m[1:] + 16*'0' # Extend mantissa to 23 bits
    return int_to_binary_string(result_sign,1)+ int_to_binary_string(result_exp,8)+fp32_mant

def fp32_add(a, b):
    """Floating point addition implementation for FP32"""
    print(a,b)
    # Extract components
    sign_a = a[0]
    sign_b = b[0]
    exp_a = a[1:9]
    exp_b = b[1:9]
    mant_a = '1'+a[9:]
    mant_b = '1'+b[9:]
    # Determine larger operand
    swap = False
    if exp_b > exp_a or (exp_b == exp_a and mant_b > mant_a):
        swap = True
    
    # Store aligned operands
    b_exp = exp_b if swap else exp_a
    s_exp = exp_a if swap else exp_b
    b_mant = mant_b if swap else mant_a
    s_mant = mant_a if swap else mant_b
    b_sign = sign_b if swap else sign_a
    s_sign = sign_a if swap else sign_b
    
    # Calculate exponent difference and align mantissas
    exp_diff = binary_string_to_int(b_exp) - binary_string_to_int(s_exp)
    aligned_s_mant = exp_diff*'0'+(s_mant+24*'0')[0: 48-exp_diff] if exp_diff < 48 else 48*'0'
    extended_b_mant = b_mant + 24*'0'
    
    # Perform addition or subtraction based on signs
    if sign_a == sign_b:
        sum_reg = binary_string_to_int(extended_b_mant) + binary_string_to_int(aligned_s_mant)
    else:
        sum_reg = binary_string_to_int(extended_b_mant) - binary_string_to_int(aligned_s_mant)
    
    result_sign = b_sign
    base_exp = b_exp
    
    # Handle normalization and exponent adjustment
    exp_adjust = 0
    if int_to_binary_string(sum_reg,49)[0]=='1':
        exp_adjust += 1
    
    norm_mant = normalise_fp32(int_to_binary_string(sum_reg,49)+'0')
    if norm_mant[0]=='1':
        exp_adjust += 1
    
    final_exp = binary_string_to_int(base_exp) + exp_adjust
   
    
    return result_sign+ int_to_binary_string(final_exp,8)+norm_mant[1:]


def compute_mac(a_str, b_str, c_str):
    print(a_str,b_str)
    mul_result = bf16_mul(a_str, b_str)
    
    # Perform FP32 addition
    final_result = fp32_add(mul_result, c_str)
    
    # Return result as 32-bit string
    return final_result
def run_tests():
    # Read test vectors
    with open('./A_binary.txt', 'r') as f:
        a_values = [line.strip() for line in f.readlines() if line.strip()]
        
    with open('./B_binary.txt', 'r') as f:
        b_values = [line.strip() for line in f.readlines() if line.strip()]
        
    with open('./C_binary.txt', 'r') as f:
        c_values = [line.strip() for line in f.readlines() if line.strip()]
        
    with open('./MAC_binary.txt', 'r') as f:
        expected_values = [line.strip() for line in f.readlines() if line.strip()]
    
    print("Running tests...")
    mismatches = 0
    for i, (a, b, c, expected) in enumerate(zip(a_values, b_values, c_values, expected_values)):
        result = compute_mac(a, b, c)
        if result != expected:
            mismatches += 1
            print(f"\nMismatch at test {i}:")
            print(f"A:        {a}")
            print(f"B:        {b}")
            print(f"C:        {c:}")
            print(f"Expected: {expected}")
            print(f"Got:      {result}")

            
    print(f"\nTests completed. {mismatches} mismatches out of {len(expected_values)} tests.")

# Example usage
if __name__ == "__main__":
    run_tests()
    # # Test values
    # a = "0100000001000000"  # Some BF16 number
    # b = "0100000001000000"  # Some BF16 number
    # c = "01000000010010010000111111011011"  # Some FP32 number (~3.14159)
    
    # result = compute_mac(a, b, c)
    # print(f"Input A (BF16):  {a}")
    # print(f"Input B (BF16):  {b}")
    # print(f"Input C (FP32):  {c}")
    # print(f"Result (FP32):   {result}")
    
    # # Test with zero multiplication
    # zero_bf16 = "0000000000000000"
    # result_zero_mul = compute_mac(zero_bf16, b, c)
    # print("\nMultiplying by zero:")
    # print(f"Result (FP32):   {result_zero_mul}")
    
    # # Test with zero addition
    # zero_fp32 = "00000000000000000000000000000000"
    # result_zero_add = compute_mac(a, b, zero_fp32)
    # print("\nAdding zero:")
    # print(f"Result (FP32):   {result_zero_add}")