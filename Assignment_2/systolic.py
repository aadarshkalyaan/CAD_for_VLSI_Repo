def bf16_fp32_operations(a_str, b_str, c_str):
   
    mul_result = bf16_mul(a_str, b_str)
    
    # Perform FP32 addition
    final_result = fp32_add(mul_result, c_str)
    
    # Return result as 32-bit string
    return final_result
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

    if (p[0]=='1'):
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
    if (p[0]=='1'):
        p = '0'+p[0:49]
    
    mantissa = '0'+p[2:25]
    round_bit = p[25]
    if '1' in p[26:]:
        sticky_bit = 1
    else:
        sticky_bit = 0
    
    result = binary_string_to_int(mantissa)
    if (round_bit=='1') and ((sticky_bit==1) or (mantissa[23]=='1')):
        result = result+1
        
    return int_to_binary_string(result,24)

def bf16_mul(a_str, b_str):
    """Brain Float 16 multiplication implementation"""
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
    # Normalize result
    m = normalise_bf16((z << 1))
    # Handle exponents
    x = (inp1.exp -127)
    y = (inp2.exp -127)
    if (z >> 15) & 1:
        exp = (x + y + 1) 
    else:
        exp = (x + y)
    
    if (m[0]=='1'):
        x1 = (exp +127 +1) & 0xFF
    else:
        x1 = (exp +127) & 0xFF
    
    result_sign = inp1.sign ^ inp2.sign
    result_exp = x1 
    result_mant = m
    
    # Convert BF16 result to FP32 format
    fp32_mant = m[1:] + 16*'0' # Extend mantissa to 23 bits
    return int_to_binary_string(result_sign,1)+ int_to_binary_string(result_exp,8)+fp32_mant

def fp32_add(a, b):
    """Floating point addition implementation for FP32"""
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
    if exp_diff < 48:
        aligned_s_mant = exp_diff*'0'+(s_mant+24*'0')[0: 48-exp_diff] 
    else :
        aligned_s_mant='0'
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

def signed_8bit_mult_add(a,b,c):
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
def mac(s,a,b,c):
    if s == 1:
        return bf16_fp32_operations(a,b,c)
    else:
        # S1 mode uses int32 computation with lower 8 bits of a and b
        return signed_8bit_mult_add(a,b,c)
def systolic(s,m,n):
    #m and n are 4x4 matrices
    r=[[0 for j in range(4)]for i in range(4)]
    r[0][0]=mac(s,m[0][3],n[3][0],mac(s,m[0][2],n[2][0],mac(s,m[0][1],n[1][0],mac(s,m[0][0],n[0][0],0))))
    r[0][1]=mac(s,m[0][3],n[3][1],mac(s,m[0][2],n[2][1],mac(s,m[0][1],n[1][1],mac(s,m[0][0],n[0][1],0))))
    r[0][2]=mac(s,m[0][3],n[3][2],mac(s,m[0][2],n[2][2],mac(s,m[0][1],n[1][2],mac(s,m[0][0],n[0][2],0))))
    r[0][3]=mac(s,m[0][3],n[3][3],mac(s,m[0][2],n[2][3],mac(s,m[0][1],n[1][3],mac(s,m[0][0],n[0][3],0))))
    r[1][0]=mac(s,m[1][3],n[3][0],mac(s,m[1][2],n[2][0],mac(s,m[1][1],n[1][0],mac(s,m[1][0],n[0][0],0))))
    r[1][1]=mac(s,m[1][3],n[3][1],mac(s,m[1][2],n[2][1],mac(s,m[1][1],n[1][1],mac(s,m[1][0],n[0][1],0))))
    r[1][2]=mac(s,m[1][3],n[3][2],mac(s,m[1][2],n[2][2],mac(s,m[1][1],n[1][2],mac(s,m[1][0],n[0][2],0))))
    r[1][3]=mac(s,m[1][3],n[3][3],mac(s,m[1][2],n[2][3],mac(s,m[1][1],n[1][3],mac(s,m[1][0],n[0][3],0))))
    r[2][0]=mac(s,m[2][3],n[3][0],mac(s,m[2][2],n[2][0],mac(s,m[2][1],n[1][0],mac(s,m[2][0],n[0][0],0))))
    r[2][1]=mac(s,m[2][3],n[3][1],mac(s,m[2][2],n[2][1],mac(s,m[2][1],n[1][1],mac(s,m[2][0],n[0][1],0))))
    r[2][2]=mac(s,m[2][3],n[3][2],mac(s,m[2][2],n[2][2],mac(s,m[2][1],n[1][2],mac(s,m[2][0],n[0][2],0))))
    r[2][3]=mac(s,m[2][3],n[3][3],mac(s,m[2][2],n[2][3],mac(s,m[2][1],n[1][3],mac(s,m[2][0],n[0][3],0))))
    r[3][0]=mac(s,m[3][3],n[3][0],mac(s,m[3][2],n[2][0],mac(s,m[3][1],n[1][0],mac(s,m[3][0],n[0][0],0))))
    r[3][1]=mac(s,m[3][3],n[3][1],mac(s,m[3][2],n[2][1],mac(s,m[3][1],n[1][1],mac(s,m[3][0],n[0][1],0))))
    r[3][2]=mac(s,m[3][3],n[3][2],mac(s,m[3][2],n[2][2],mac(s,m[3][1],n[1][2],mac(s,m[3][0],n[0][2],0))))
    r[3][3]=mac(s,m[3][3],n[3][3],mac(s,m[3][2],n[2][3],mac(s,m[3][1],n[1][3],mac(s,m[3][0],n[0][3],0))))
    return r
m = [[2,7,-9,0],[0,4,13,0],[-16,7,8,0],[0,0,0,0]]
n = [[7,13,1,0],[-1,0,6,0],[4,-11,7,0],[0,0,0,0]]
r=systolic(0,m,n)
for i in r:
    print(i)
    