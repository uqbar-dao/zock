%builtins range_check

from jets import add_jet, dec_jet, div, dvr, mul_jet, mod, sub, bex
from jets import gte, gth, lte, lth, max, min


func main{range_check_ptr}():
  alloc_locals
 
  local a
  local b
  local c
  local z

  %{
   ids.a = int(8)
   ids.b = int(4)
   ids.c = int(3)
   ids.z = int(0)
  %}


  # N.B: `local` is necessary to copy results to local variables to prevent them from being revoked

  let (local add_res) = add_jet(a, b)
  let (local dec_res) = dec_jet(a)
  
  let (local div_res1) = div(a, b)
  let (local div_res2) = div(b, a)

  let (local dvr_res1q, local dvr_res1r) = dvr(a, b)
  let (local dvr_res2q, local dvr_res2r) = dvr(b, a)
  let (local dvr_res3q, local dvr_res3r) = dvr(a, c)
  
  let (local gte_res1) = gte(a, b)
  let (local gte_res2) = gte(b, a)
  let (local gte_res3) = gte(a, a)

  let (local gth_res1) = gth(a, b)
  let (local gth_res2) = gth(b, a)
  let (local gth_res3) = gth(a, a)

  let (local lte_res1) = lte(a, b)
  let (local lte_res2) = lte(b, a)
  let (local lte_res3) = lte(a, a)

  let (local lth_res1) = lth(a, b)
  let (local lth_res2) = lth(b, a)
  let (local lth_res3) = lth(a, a)

  let (local max_res1) = max(a, b)
  let (local max_res2) = max(b, a)
  let (local max_res3) = max(a, a)

  let (local min_res1) = min(a, b)
  let (local min_res2) = min(b, a)
  let (local min_res3) = min(a, a)

  let (local mod_res1) = mod(a, b)
  let (local mod_res2) = mod(b, a)
  let (local mod_res3) = mod(a, c)
  
  assert dvr_res1r = mod_res1
  assert dvr_res2r = mod_res2
  assert dvr_res3r = mod_res3


  let (local mul_res1) = mul_jet(a, b)
  let (local mul_res2) = mul_jet(b, a)

  let (local sub_res1) = sub(a, b)
  # let (sub_crash) = sub(b, a)

  let (local bex_res1) = bex(z)
  let (local bex_res2) = bex(b)
  let (local bex_res3) = bex(b)




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

    print(res2str("dvr", [ids.a, ids.b], {"q": ids.dvr_res1q, "r": ids.dvr_res1r}))
    print(res2str("dvr", [ids.b, ids.a], {"q": ids.dvr_res2q, "r": ids.dvr_res2r}))
    print(res2str("dvr", [ids.a, ids.c], {"q": ids.dvr_res3q, "r": ids.dvr_res3r}))
    
    print()

    print(res2str("gte", [ids.a, ids.b], loob_str(ids.gte_res1)))
    print(res2str("gte", [ids.b, ids.a], loob_str(ids.gte_res2)))
    print(res2str("gte", [ids.a, ids.a], loob_str(ids.gte_res3)))

    print()

    print(res2str("gth", [ids.a, ids.b], loob_str(ids.gth_res1)))
    print(res2str("gth", [ids.b, ids.a], loob_str(ids.gth_res2)))
    print(res2str("gth", [ids.a, ids.a], loob_str(ids.gth_res3)))

    print()

    print()

    print(res2str("lte", [ids.a, ids.b], loob_str(ids.lte_res1)))
    print(res2str("lte", [ids.b, ids.a], loob_str(ids.lte_res2)))
    print(res2str("lte", [ids.a, ids.a], loob_str(ids.lte_res3)))

    print()

    print(res2str("lth", [ids.a, ids.b], loob_str(ids.lth_res1)))
    print(res2str("lth", [ids.b, ids.a], loob_str(ids.lth_res2)))
    print(res2str("lth", [ids.a, ids.a], loob_str(ids.lth_res3)))

    print()

    print(res2str("mul", [ids.a, ids.b], ids.mul_res1))
    print(res2str("mul", [ids.b, ids.a], ids.mul_res2))

    print(res2str("sub", [ids.a, ids.b], ids.sub_res1))

    print()

    print(res2str("bex", [ids.z], ids.bex_res1))
    print(res2str("bex", [ids.b], ids.bex_res2))

    print('\n' + '='*32)


    
  %}

  return ()
end