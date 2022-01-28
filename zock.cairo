%builtins output pedersen range_check

from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import abs_value
from starkware.cairo.common.math import sign 

# constants of common integer hashes
const h0 = 2089986280348253421170679821480865132823066470938446095505822317253594081284
const h1 = 1089549915800264549621536909767699778745926517555586332772759280702396009108
const h2 = 1637368371864026355245122316446106576874611007407245016652355316950184561542
const h3 = 936823097115478672163131070534991867793647843312823827742596382032679996195
const h4 = 469486474782544164430568959439120883383782181399389907385047779197726806430
const h5 = 2941083907689010536497253969578701440794094793277200004061830176674600429738

# root: merkle root
# leaf: hashed value or root of subtree
# axis
func root_from_axis{hp : HashBuiltin*}(root, leaf, axis) -> (root):
  alloc_locals
  local sibling : felt
  %{ 
    ids.sibling = program_input['merkle_siblings'][str(ids.root)][str(ids.axis)]
  %}

  if axis == 2:
    let (r) = hash2{hash_ptr=hp}(x=leaf, y=sibling)
    return (root=r)
  end

  if axis == 3:
    let (r) = hash2{hash_ptr=hp}(x=sibling, y=leaf)
    return(root=r)
  end

  %{ memory[ap] = ids.axis % 2 %}
  jmp left_sibling if [ap] != 0; ap++

  right_sibling:
    let (h) = hash2{hash_ptr=hp}(x=leaf, y=sibling)
    return root_from_axis(root, leaf=h, axis=axis / 2)

  left_sibling:
    let (h) = hash2{hash_ptr=hp}(x=sibling, y=leaf)
    return root_from_axis(root, leaf=h, axis=(axis -1) / 2)
end

# Nock 0
# s, f: subject, formula
# result: hashed value or root of subtree; result of running 0
func zero{hp : HashBuiltin*}(s, f, axis, result) -> (res):
  alloc_locals

  if axis == 0:
    assert 0 = 1    # crash
  end

  # assert that formula is [0 axis]
  let (h_axis) = hash2{hash_ptr=hp}(axis, 0)
  let (h) = hash2{hash_ptr=hp}(x=h0, y=h_axis)
  assert f = h

  if axis == 1:
    assert s = result
    return(result)
  end

  let (root) = root_from_axis{hp=hp}(s, result, axis) 
  assert root = s
  return(result)
end

# result: hashed value or root of subtree; result of running 1
func one{hp : HashBuiltin*}(s, f, result) -> (res):
  let (h) = hash2{hash_ptr=hp}(x=h1, y=result)
  assert f = h
  return (result)
end

# sf1: first subformula
# sf2: second subformula
# result: hashed value or root of subtree; result of running 2
func two{hp : HashBuiltin*}(s, f, sf1, sf2) -> (res):
  alloc_locals

  let (h_sf1_sf2) = hash2{hash_ptr=hp}(x=sf1, y=sf2)
  let (h_f) = hash2{hash_ptr=hp}(x=h2, y=h_sf1_sf2)
  assert f = h_f

  let (res_sf1) = verify{hp=hp}(s, sf1)
  let (res_sf2) = verify{hp=hp}(s, sf2)
 
  let (result) = verify{hp=hp}(res_sf1, res_sf2)
  return(result)
end

# if head is 0, then this is an atom
func three{hp : HashBuiltin*}(s, f, sf, atom, head, tail) -> (res):
  let (h) = hash2{hash_ptr=hp}(x=h3, y=sf)
  assert f = h

  # atom
  if head == 0:
    let (res) = verify(s, sf)
    let (h_a) = hash2{hash_ptr=hp}(x=atom, y=0)
    assert h_a = res
    return(h1)
  end

  # cell
  let (res) = verify(s, sf)
  let (h_ht) = hash2{hash_ptr=hp}(x=head, y=tail)
  assert h_ht = res
  return(h0)
end

# sf: subformula
# atom: atom returned by subformula
func four{hp : HashBuiltin*}(s, f, sf, atom) -> (res):
  let (h) = hash2{hash_ptr=hp}(x=h4, y=sf)
  assert f = h

  let (res) = verify(s, sf)
  let (h_a_dec) = hash2{hash_ptr=hp}(x=atom - 1, y=0)
  assert h_a_dec = res
  let (h_a) = hash2{hash_ptr=hp}(x=atom, y=0)
  return(h_a)
end

func five{hp : HashBuiltin*}(s, f, sf1, sf2) -> (res):
  alloc_locals

  let (h_sf1_sf2) = hash2{hash_ptr=hp}(x=sf1, y=sf2)
  let (h_f) = hash2{hash_ptr=hp}(x=h5, y=h_sf1_sf2)
  assert f = h_f

  let (rsf1) = verify{hp=hp}(s, sf1)
  local res_sf1 = rsf1
  let (res_sf2) = verify{hp=hp}(s, sf2)
 
  if res_sf1 == res_sf2:
    return(h0)
  end
  return(h1)
end

func verify{hp : HashBuiltin*}(s, f) -> (res):
  # lookup (s, f); make a Nock struct
  # jump based on value of the opcode in struct
  return(0)
end

func main{output_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
  alloc_locals
 
  # let (__fp__, _) = get_fp_and_pc()
  # [[4 5] 6 7]
  local s = 1832969563318038202482355323522607828463192350149403022354941371033553420549
  # [0 2]
  local f02 = 2920760503393641840990351232074818450843248133728638245225608299873225911759
  # [0 7]
  local f07 = 2158122302526224927154186209761230448692469586990117158947361357036821155407
  # [4 5]
  local leaf2 = 1506610249047466047325607308647502845160729906712972118690756978255845486763
  # [6 7]
  local leaf3 = 1457137102687840622469998386657531077922059188363371731706856889535607109733
  local leaf7 = 2258442912665439649622769515993460039756024697697714582745734598954638194578

  let (res) = zero{hp=pedersen_ptr}(s, f07, 7, leaf7)
  %{ print(ids.res) %}
  serialize_word(res)
  return()
end
