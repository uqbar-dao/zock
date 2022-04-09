%builtins range_check

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

func add(a : felt, b : felt) -> (res : felt):
    let result = a + b
    return (result)
end

func dec(a : felt) -> (res : felt):
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


func mul(a : felt, b : felt) -> (res : felt):
    let result = a * b
    return (result)
end

func sub{range_check_ptr}(a : felt, b : felt) -> (res : felt):
    let result = a - b
    assert_nn(result)  # hoon crashes on subtraction underflow
    return (result)
end



func main{range_check_ptr}():
  alloc_locals
 
  local a
  local b
  local c

  %{
   ids.a = int(8)
   ids.b = int(4)
   ids.c = int(3)
  %}

  let (add_res) = add(a, b)
  let (dec_res) = dec(a)
  
  let (div_res1) = div(a, b)
  let (div_res2) = div(b, a)

  let dvr_res1 = dvr(a, b)
  let dvr_res2 = dvr(b, a)
  let dvr_res3 = dvr(a, c)


  # let (gte_res1) = gte(a, b)
  # let (gte_res2) = gte(b, a)
  # let (gte_res3) = gte(a, a)

  # let (gth_res1) = gth(a, b)
  # let (gth_res2) = gth(b, a)
  # let (gth_res3) = gth(a, a)

  # let (lte_res1) = lte(a, b)
  # let (lte_res2) = lte(b, a)
  # let (lte_res3) = lte(a, a)

  # let (lth_res1) = lth(a, b)
  # let (lth_res2) = lth(b, a)
  # let (lth_res3) = lth(a, a)

  # let (max_res1) = max(a, b)
  # let (max_res2) = max(b, a)
  # let (max_res3) = max(a, a)

  # let (min_res1) = min(a, b)
  # let (min_res2) = min(b, a)
  # let (min_res3) = min(a, a)

  let (mod_res1) = mod(a, b)
  let (mod_res2) = mod(b, a)
  let (mod_res3) = mod(a, c)
  
  assert dvr_res1.r = mod_res1
  assert dvr_res2.r = mod_res2
  assert dvr_res3.r = mod_res3


  let (mul_res1) = mul(a, b)
  let (mul_res2) = mul(b, a)

  let (sub_res1) = sub(a, b)
  # let (sub_crash) = sub(b, a)

  # todo 


  %{
    TRUE = 1
    FALSE = 0

    YES = 0
    NO = 1
    
    def loob_str(l):
        return "YES" if l == YES else "NO"
    
    def bool_str(b):
        return "TRUE" if b == TRUE else "FALSE"

    def res2str(fn, args, result):
        args = map(str, args)
        return f"{fn}({','.join(args)}) = {str(result)}"
    

    print(f"a = {ids.a}")
    print(f"b = {ids.b}")
    print(f"c = {ids.c}")

    print()

    print(res2str("add", [ids.a, ids.b], ids.add_res))
    print(res2str("dec", [ids.a], ids.dec_res))

    print()

    print(res2str("div", [ids.a, ids.b], ids.div_res1))
    print(res2str("div", [ids.b, ids.a], ids.div_res2))
    
    print()

    print(res2str("dvr", [ids.a, ids.b], {"q": ids.dvr_res1.q, "r": ids.dvr_res1.r}))
    print(res2str("dvr", [ids.b, ids.a], {"q": ids.dvr_res2.q, "r": ids.dvr_res2.r}))
    print(res2str("dvr", [ids.a, ids.c], {"q": ids.dvr_res3.q, "r": ids.dvr_res3.r}))
    
    # print()

    # print("gte", [ids.a, ids.b], loob_str(ids.gte_res1))
    # print("gte", [ids.b, ids.a], loob_str(ids.gte_res2))
    # print("gte", [ids.a, ids.a], loob_str(ids.gte_res3))

    # print()

    # print("gth", [ids.a, ids.b], loob_str(ids.gth_res1))
    # print("gth", [ids.b, ids.a], loob_str(ids.gth_res2))
    # print("gth", [ids.a, ids.a], loob_str(ids.gth_res3))

    # print()

    # print()

    # print(res2str("lte", (a,b), loob_str(ids.lte_res1)))
    # print(res2str("lte", (b,a), loob_str(ids.lte_res2)))
    # print(res2str("lte", (a,a), loob_str(ids.lte_res3)))

    # print()

    # print(res2str("lth", (a,b), loob_str(ids.lth_res1)))
    # print(res2str("lth", (b,a), loob_str(ids.lth_res2)))
    # print(res2str("lth", (a,a), loob_str(ids.lth_res3)))

    print()

    print(res2str("mul", [ids.a, ids.b], ids.mul_res1))
    print(res2str("mul", [ids.b, ids.a], ids.mul_res2))

    print(res2str("sub", [ids.a, ids.b], ids.sub_res1))

    print()

    
  %}

  return ()
end


