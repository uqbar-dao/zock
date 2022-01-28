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

func verify_formula{hp : HashBuiltin*}(f, opcode_hash, rest_hash):
  let (h) = hash2{hash_ptr=hp}(x=opcode_hash, y=rest_hash)
  assert f = h
  return()
end

func hash_val{hp : HashBuiltin*}(v : felt) -> (hash : felt):
  let (hash) = hash2{hash_ptr=hp}(x=v, y=0)
  return(hash=hash)
end

# Nock 0
# s, f: subject, formula
# leaf: hashed value or root of subtree; result of running 0
func zero{hp : HashBuiltin*}(s, f, axis, leaf) -> (res):
  alloc_locals

  if axis == 0:
    assert 0 = 1    # crash
  end

  # assert that formula is [0 axis]
  # let h_axis = hash_val(axis)
  # verify_formula{hp=hp}(f=f, opcode_hash=h0, rest_hash=h_axis)

  if axis == 1:
    assert s = leaf
    return(s)
  end

  let (root) = root_from_axis{hp=hp}(s, leaf, axis) 
  assert root = s
  return(s)
end

func main{output_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
  alloc_locals
 
  # let (__fp__, _) = get_fp_and_pc()
  # [[4 5] 6 7]
  local s = 1832969563318038202482355323522607828463192350149403022354941371033553420549
  # [0 2]
  local f = 2920760503393641840990351232074818450843248133728638245225608299873225911759
  # [4 5]
  local leaf2 = 1506610249047466047325607308647502845160729906712972118690756978255845486763
  # [6 7]
  local leaf3 = 1457137102687840622469998386657531077922059188363371731706856889535607109733
  local leaf7 = 2258442912665439649622769515993460039756024697697714582745734598954638194578

  let (res) = zero{hp=pedersen_ptr}(s, f, 7, leaf7)
  %{ print(ids.res) %}
  serialize_word(res)
  return()
end
