from cocotb_coverage.coverage import *
from enum import IntEnum
import random

# Define operation modes
class MACMode(IntEnum):
    INTEGER = 0
    FLOATING_POINT = 1

# Coverage model for MAC operations
coverage_db = {}

# Define coverage points
int_value_bins = [
    (0, 0),           # Zero
    (1, 127),         # Positive values
    (-128, -1),       # Negative values
]

SelectMode = coverage_section(
    CoverPoint("top.mac_mode", 
        xf=lambda x: x.s,
        bins=[0, 1],
        bins_labels=["INTEGER", "FLOATING_POINT"])
)

MACInputs = coverage_section(
    CoverPoint("top.a_value",
        xf=lambda x: x.a,
        bins=int_value_bins,
        bins_labels=["ZERO", "POSITIVE", "NEGATIVE"]),
    CoverPoint("top.b_value",
        xf=lambda x: x.b,
        bins=int_value_bins,
        bins_labels=["ZERO", "POSITIVE", "NEGATIVE"]),
    CoverPoint("top.c_value",
        xf=lambda x: x.c,
        bins=[
            (0, 0),           # Zero
            (1, 2**31-1),     # Positive values
            (-2**31, -1)      # Negative values
        ],
        bins_labels=["ZERO", "POSITIVE", "NEGATIVE"]),
    CoverCross("top.mac_cross",
        items=["top.a_value", "top.b_value"])
)

class MACTransaction:
    def __init__(self, a, b, c, s):
        self.a = a
        self.b = b
        self.c = c
        self.s = s

@SelectMode
@MACInputs
def coverage_sample(transaction):
    pass

def model_mac_int(a: int, b: int, c: int) -> int:
    """Model for integer MAC operation"""
    # Handle 8-bit signed multiplication
    a_signed = a if a < 128 else a - 256
    b_signed = b if b < 128 else b - 256
    
    # Perform MAC operation
    result = (a_signed * b_signed) + c
    
    # Saturate result if needed
    if result > 2**31 - 1:
        result = 2**31 - 1
    elif result < -2**31:
        result = -2**31
        
    return result

async def generate_test_vectors(count: int):
    """Generate test vectors for MAC verification"""
    vectors = []
    for _ in range(count):
        # Generate random 8-bit values for a and b
        a = random.randint(0, 255)
        b = random.randint(0, 255)
        # Generate random 32-bit value for c
        c = random.randint(-2**31, 2**31-1)
        # Randomly select mode (currently focusing on integer mode)
        s = random.randint(0, 1)
        
        vectors.append((a, b, c, s))
    return vectors

def check_coverage():
    """Print coverage report"""
    coverage_db.report_coverage(filename="mac_coverage.rpt", 
                              bins=True,
                              expand_print=True)
    coverage_db.export_to_yaml(filename="mac_coverage.yml")