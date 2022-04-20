from starkware.cairo.common.math import unsigned_div_rem, assert_nn
from starkware.cairo.common.math_cmp import is_le_felt 
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.pow import pow
from pow2 import pow2

const YES = 0
const NO = 1

func assert_bool(a : felt):
    if a == TRUE:
        return ()
    else:
        if a == FALSE:
            return ()
        else:
            assert 0 = 1
            return ()
        end
    end
end

func not(a : felt) -> (b : felt):
    assert_bool(a)

    if a == TRUE:
        return (FALSE)
    else:
        return (TRUE)
    end
end

# convert boolean to loobean representation
# TRUE  (1) -> %.y 0
# FALSE (0) -> %.n 1
func loob(a : felt) -> (l : felt):
    assert_bool(a)
    let (result) = not(a)
    return (result)
end

# MARK - 1a: Basic Arithmetic

# TODO handle atom <-> cairo overflow/edge cases

# Arithmetic

func add_jet(a : felt, b : felt) -> (res : felt):
    let result = a + b
    return (result)
end

func dec_jet(a : felt) -> (res : felt):
    let result = a - 1
    return (result)
end

func div{range_check_ptr}(a : felt, b : felt) -> (res : felt):
    let (q, _) = unsigned_div_rem(a, b)
    return (q)
end

func dvr{range_check_ptr}(a : felt, b : felt) -> (q : felt, r : felt):
    let (q, r) = unsigned_div_rem(a, b)
    return (q, r)
end

# Comparison Functions

# N.B: All comparison functions return loobeans unless otherwise specified



# optimization: we could inline the calls to lth and lte but it sacrifices readabilty
func gte{range_check_ptr}(a : felt, b : felt) -> (l : felt):
    alloc_locals

    let (is_lth_lb) = lth(a, b)
    let (is_gte) = not(is_lth_lb)
    return (is_gte)
end


func gth{range_check_ptr}(a : felt, b : felt) -> (l : felt):
    alloc_locals
    
    let (is_lte_lb) = lte(a, b)
    let (is_gth) = not(is_lte_lb)
    return (is_gth)
end


func lte{range_check_ptr}(a : felt, b : felt) -> (l : felt):
    alloc_locals

    let (is_lte) = is_le_felt(a, b)
    let (result) = loob(is_lte)
    return (result)
end

func lth{range_check_ptr}(a : felt, b : felt) -> (l : felt):
    alloc_locals

    let (is_lte) = is_le_felt(a + 1, b)    
    let (result) = loob(is_lte)
    return (result)
end


func max{range_check_ptr}(a : felt, b : felt) -> (l : felt):
    alloc_locals

    let (a_lth_b) = lth(a, b)  # loob
    if a_lth_b == YES:
        return (b)
    else:
        return (a)
    end
end

func min{range_check_ptr}(a : felt, b : felt) -> (l : felt):
    alloc_locals

    let (a_gth_b) = gth(a, b)  # loob
    if a_gth_b == YES:
        return (b)
    else:
        return (a)
    end
end


func mod{range_check_ptr}(a : felt, b : felt) -> (r : felt):
    let (_, r) = unsigned_div_rem(a, b)
    return (r)
end


func mul_jet(a : felt, b : felt) -> (res : felt):
    let result = a * b
    return (result)
end

func sub{range_check_ptr}(a : felt, b : felt) -> (res : felt):
    let result = a - b
    assert_nn(result)  # hoon crashes on subtraction underflow
    return (result)
end


# MARK - 2c: Bit Arithmetic

# from the https://urbit.org/docs/hoon/reference/stdlib/1c#bloq, 
# bloq is an "Atom representing block size. A block of size a has a bitwidth of 2^a."

using bloq = felt

# could try https://cp-algorithms.com/algebra/binary-exp.html
# for more performant general exp and then special casing here
func bex(a : bloq) -> (res : felt):
    # if a == 0:
    #     return (1)
    # else:
    #     let (bex_prv) = bex(a - 1)
    #     return (2 * bex_prv)
    # end

    # 50 more steps and 97 more memory cells used by pow vs. naive recursion
    # however, pow might perform better for large exponents. remains to be seen
    # return pow(2, a)

    # the lookup table pow2 uses 19 less steps
    # but has the obvious penalty of storing the LUT

    return pow2(a)
end

