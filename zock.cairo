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
const h6 = 2741690337285522037147443857948052150995543108052651970979313688522374979162
const h7 = 2258442912665439649622769515993460039756024697697714582745734598954638194578
const h8 = 2743794648056839147566190792738700325779538550063233531691573479295033948774
const h9 = 3149011590233272225803080114059308917528748800879621812239443987136907759492
const h10 = 2466881358002133364822637278001945633159199669109451817445969730922553850042
const h11 = 1602195742608144856779311879863141684990052756940086705696922586637104021594

# axis: axis of leaf in noun 
# leaf: hashed value or root of subtree
# path: list of hashed siblings from bottom to top
# return: hashed root of tree with leaf at axis and path of siblings
func root_from_axis{hash_ptr : HashBuiltin*}(axis, leaf, path: felt*) -> (root):
  alloc_locals

  if axis == 1:
      return (leaf)
  end

  let (sibling) = [path]

  if axis == 2:
    let (r) = hash2(x=leaf, y=sibling)
    return (root=r)
  end

  if axis == 3:
    let (r) = hash2(x=sibling, y=leaf)
    return(root=r)
  end

  %{ memory[ap] = ids.axis % 2 %}
  jmp left_sibling if [ap] != 0; ap++

  right_sibling:
    let (h) = hash2(x=leaf, y=sibling)
    return root_from_axis(axis=axis / 2, leaf=h, path=path + 1)
    #return root_from_axis(root, leaf=h, axis=axis / 2)

  left_sibling:
    let (h) = hash2(x=sibling, y=leaf)
    return root_from_axis(axis=(axis - 1)/2, leaf=h, path=path + 1)
    #return root_from_axis(root, leaf=h, axis=(axis -1) / 2)
end

# Nock 0
# s, f: subject, formula
# result: hashed value or root of subtree; result of running 0
func zero{hash_ptr : HashBuiltin*}(s, f, axis, leaf, path: felt*) -> (res):
  alloc_locals

  if axis == 0:
    assert 0 = 1    # crash
  end

  # assert that formula is [0 axis]
  let (h_axis) = hash2(axis, 0)
  let (h) = hash2(x=h0, y=h_axis)
  assert f = h

  if axis == 1:
    return (s)
  end

  let (root) = root_from_axis(axis, leaf, path) 
  assert root = s
  return (leaf)
end

# result: hashed value or root of subtree; result of running 1
func one{hash_ptr : HashBuiltin*}(s, f, result) -> (res):
  let (h) = hash2(x=h1, y=result)
  assert f = h
  return (result)
end

# sf1: first subformula
# sf2: second subformula
# result: hashed value or root of subtree; result of running 2
func two{hash_ptr : HashBuiltin*}(s, f, sf1, sf2) -> (res):
  alloc_locals

  let (h_sf1_sf2) = hash2(x=sf1, y=sf2)
  let (h_f) = hash2(x=h2, y=h_sf1_sf2)
  assert f = h_f

  let (res_sf1) = verify(s, sf1)
  let (res_sf2) = verify(s, sf2)
 
  let (result) = verify(res_sf1, res_sf2)
  return(result)
end

# if head is 0, then this is an atom
func three{hash_ptr : HashBuiltin*}(s, f, sf, atom, head, tail) -> (res):
  let (h) = hash2(x=h3, y=sf)
  assert f = h

  # atom
  if head == 0:
    let (res) = verify(s, sf)
    let (h_a) = hash2(x=atom, y=0)
    assert h_a = res
    return(h1)
  end

  # An attacker could have an atom and trick us into thinking it's a cell. 
  # An atom's hash is h(@)=h(@, 0) and a cell's is h([a, b])=h(h(a), h(b))
  # So atom A could be passed in as head=h(A), tail=0 and would hash as a cell.
  # To prevent this we don't allow 0 as the hash of a head or a tail.
  if tail == 0:
    assert 0 = 1    # crash 
    return (0)      # never get here
  end

  # cell
  let (res) = verify(s, sf)
  let (h_ht) = hash2(x=head, y=tail)
  assert h_ht = res
  return(h0)
end

# sf: subformula
# atom: atom returned by subformula
func four{hash_ptr : HashBuiltin*}(s, f, sf, atom) -> (res):
  let (h) = hash2(x=h4, y=sf)
  assert f = h

  let (res) = verify(s, sf)
  let (h_a_dec) = hash2(x=atom, y=0)
  assert h_a_dec = res
  let (h_a) = hash2(x=atom + 1, y=0)
  return(h_a)
end

func five{hash_ptr : HashBuiltin*}(s, f, sf1, sf2) -> (res):
  alloc_locals

  let (h_sf1_sf2) = hash2(x=sf1, y=sf2)
  let (h_f) = hash2(x=h5, y=h_sf1_sf2)
  assert f = h_f

  let (rsf1) = verify(s, sf1)
  local res_sf1 = rsf1
  let (res_sf2) = verify(s, sf2)
 
  if res_sf1 == res_sf2:
    return(h0)
  end
  return(h1)
end

func six{hash_ptr : HashBuiltin*}(s, f, sf1, sf2, sf3) -> (res):
  alloc_locals

  let (h_sf2_sf3) = hash2(x=sf2, y=sf3)
  let (h_sf1_sf2_sf3) = hash2(x=sf1, y=h_sf2_sf3)
  let (h_f) = hash2(x=h6, y=h_sf1_sf2_sf3)
  assert f = h_f

  let (rsf1) = verify(s, sf1)

  if rsf1 == h0:
    let (result) = verify(s, sf2)
    return (result)
  end

  if rsf1 == h1:
    let (result) = verify(s, sf3)
    return (result)
  end

  assert 0 = 1     # crash
  return (0)       # should never get here
end

func seven{hash_ptr : HashBuiltin*}(s, f, sf1, sf2) -> (res):
  alloc_locals

  let (h_sf1_sf2) = hash2(x=sf1, y=sf2)
  let (h_f) = hash2(x=h7, y=h_sf1_sf2)
  assert f = h_f

  let (rsf1) = verify(s, sf1)
  let (result) = verify(rsf1, sf2)
  return (result)
end

func eight{hash_ptr : HashBuiltin*}(s, f, sf1, sf2) -> (res):
  alloc_locals

  let (h_sf1_sf2) = hash2(x=sf1, y=sf2)
  let (h_f) = hash2(x=h8, y=h_sf1_sf2)
  assert f = h_f
  
  let (rsf1) = verify(s, sf1)
  let s2 = hash2(rsf1, s)     # new subject 
  let (rsf2) = verify(s2.result, sf2)
  return (rsf2)
end

func nine{hash_ptr : HashBuiltin*}(s, f, axis, subf, path: felt*) -> (res):
  alloc_locals

  let (h_axis_subf) = hash2(x=axis, y=subf)
  let (h_f) = hash2(x=h9, y=h_axis_subf)
  assert f = h_f

  let (rsubf) = verify(s, subf)

  let (root) = root_from_axis(rsubf, leaf, axis) 
  assert root = rsubf
  let (result) = verify(rsubf, leaf)
  return (result)
end

func ten{hash_ptr : HashBuiltin*}(s, f, axis, subf1, subf2) -> (res):
  alloc_locals

  let (h_subf1_subf2) = hash2(subf1, subf2)
  let (h_axis_subf1_subf2) = hash2(axis, h_subf1_subf2)
  let (h_f) = hash2(h10, h_axis_subf1_subf2)
  assert f = h_f

  let (rsf1) = verify(s, subf1)
  let (rsf2) = verify(s, subf2)

  let (root) = root_from_axis(rsf2, rsf1, axis) 
  return (root)
end

func eleven{hash_ptr : HashBuiltin*}(s, f, subf) -> (res):
  alloc_locals

  let (h_f) = hash2(h11, subf)
  assert f = h_f

  let (res) = verify(s, subf)
  return (res)
end

func verify{hash_ptr : HashBuiltin*}(s, f) -> (res):
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

  let (res) = zero{hash_ptr=pedersen_ptr}(s, f07, 7, leaf7)
  %{ print(ids.res) %}
  serialize_word(res)
  return()
end
