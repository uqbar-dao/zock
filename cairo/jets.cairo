#%builtins range_check

from starkware.cairo.common.math import unsigned_div_rem, assert_nn
from starkware.cairo.common.math_cmp import is_le_felt 
from starkware.cairo.common.bool import TRUE, FALSE

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

# MARK - 1a

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
