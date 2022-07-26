%builtins output pedersen range_check

from starkware.cairo.common.registers import get_label_location
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import abs_value
from starkware.cairo.common.math import sign 
from starkware.cairo.common.alloc import alloc

from jets import add_jet
from jets import dec_jet
from jets import mul_jet

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
const h0_2 = 2920760503393641840990351232074818450843248133728638245225608299873225911759 # hash([0 2])

# axis: axis of leaf in noun 
# leaf: hashed value or root of subtree
# path: list of hashed siblings from bottom to top
# return: hashed root of tree with leaf at axis and path of siblings
func root_from_axis{hash_ptr : HashBuiltin*}(axis, leaf, path: felt*) -> (root):
  alloc_locals

  if axis == 1:
      return (leaf)
  end

  local sibling = [path]

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

  left_sibling:
    let (h) = hash2(x=sibling, y=leaf)
    return root_from_axis(axis=(axis - 1)/2, leaf=h, path=path + 1)
end


func verify_zero{hash_ptr : HashBuiltin*}(s, f, n) -> (res, n):
  alloc_locals

  local axis
  local leaf 
  local path : felt*
  %{
    ids.axis = int(program_input['hints'][ids.n][1])
    ids.leaf = int(program_input['hints'][ids.n][2])
    sibs = program_input['hints'][ids.n][3]
    ids.path = path = segments.add()
    for i, val in enumerate(sibs):
      memory[ids.path + i] = int(val)
  %}
  let (result, n1) = zero(s, f, axis, leaf, path, n)
  return (result, n1)
end

# Nock 0
# s, f: subject, formula
# result: hashed value or root of subtree; result of running 0
func zero{hash_ptr : HashBuiltin*}(s, f, axis, leaf, path: felt*, n: felt) -> (res, n):
  alloc_locals

  if axis == 0:
    assert 0 = 1    # crash
  end

  # assert that formula is [0 axis]
  let (h_axis) = hash2(axis, 0)
  let (h) = hash2(x=h0, y=h_axis)
  assert f = h

  if axis == 1:
    return (s, n)
  end

  let (root) = root_from_axis(axis, leaf, path) 
  assert root = s
  return (leaf, n)
end

func verify_one{hash_ptr : HashBuiltin*}(s, f, n) -> (res, n):
  alloc_locals

  local res
  %{
    ids.res = int(program_input['hints'][ids.n][1])
  %}
  let (result, n1) = one(s, f, res, n)
  return (result, n1)
end

# result: hashed value or root of subtree; result of running 1
func one{hash_ptr : HashBuiltin*}(s, f, result, n) -> (res, n):
  alloc_locals

  # assert f = [1 result]
  let (h) = hash2(x=h1, y=result)
  assert f = h

  return (result, n)
end

func verify_two{hash_ptr : HashBuiltin*}(s, f, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  local sf1
  local sf2
  %{
    ids.sf1 = int(program_input['hints'][ids.n][1])
    ids.sf2 = int(program_input['hints'][ids.n][2])
  %}
  let (result, n1) = two(s, f, sf1, sf2, l, j, n)
  return (result, n1)
end

# sf1: first subformula
# sf2: second subformula
# result: hashed value or root of subtree; result of running 2
func two{hash_ptr : HashBuiltin*}(s, f, sf1, sf2, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  # assert f = [2 sf1 sf2]
  let (h_sf1_sf2) = hash2(x=sf1, y=sf2)
  let (h_f) = hash2(x=h2, y=h_sf1_sf2)
  assert f = h_f

  let (res_sf1, n1) = verify(s, sf1, l, j, n+1)
  let (res_sf2, n2) = verify(s, sf2, l, j, n1+1)
 
  let (result, n3) = verify(s=res_sf1, f=res_sf2, l=l, j=j, n=n2+1)
  return(result, n3)
end

func verify_three{hash_ptr : HashBuiltin*}(s, f, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  local sf
  local atom 
  local head
  local tail
  %{
    ids.sf   = int(program_input['hints'][ids.n][1])
    ids.atom = int(program_input['hints'][ids.n][2])
    ids.head = int(program_input['hints'][ids.n][3])
    ids.tail = int(program_input['hints'][ids.n][4])
  %}
  let (result, n1) = three(s, f, sf, atom, head, tail, l, j=j, n=n)
  return (result, n1)
end

# if head is 0, then this is an atom
func three{hash_ptr : HashBuiltin*}(s, f, sf, atom, head, tail, l : felt*, j : felt*, n: felt) -> (res, n):
  let (h) = hash2(x=h3, y=sf)
  assert f = h

  # atom
  if head == 0:
    let (res, n1) = verify(s, sf, l, j, n+1)
    let (h_a) = hash2(x=atom, y=0)
    assert h_a = res
    return(h1, n1)
  end

  # An attacker could have an atom and trick us into thinking it's a cell. 
  # An atom's hash is h(@)=h(@, 0) and a cell's is h([a, b])=h(h(a), h(b))
  # So atom A could be passed in as head=h(A), tail=0 and would hash as a cell.
  # To prevent this we don't allow 0 as the hash of a head or a tail.
  if tail == 0:
    assert 0 = 1    # crash 
    return (0, 0)      # never get here
  end

  # cell
  let (res, n1) = verify(s, sf, l, j, n+1)
  let (h_ht) = hash2(x=head, y=tail)
  assert h_ht = res
  return(h0, n1)
end

func verify_four{hash_ptr : HashBuiltin*}(s, f, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  local sf
  local atom
  %{
    ids.sf = int(program_input['hints'][ids.n][1])
    ids.atom = int(program_input['hints'][ids.n][2])
  %}
  let (result, n1) = four(s, f, sf, atom, l, j, n)
  return (result, n1)
end

# sf: subformula
# atom: atom returned by subformula
func four{hash_ptr : HashBuiltin*}(s, f, sf, atom, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  # assert f = [4 sf]
  let (h) = hash2(x=h4, y=sf)
  assert f = h

  let (res, n1) = verify(s, sf, l, j, n+1)
  let (h_a_dec) = hash2(x=atom, y=0)
  assert h_a_dec = res
  let (h_a) = hash2(x=atom + 1, y=0)
  return(h_a, n1)
end

func verify_five{hash_ptr : HashBuiltin*}(s, f, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  local sf1
  local sf2
  %{
    ids.sf1 = int(program_input['hints'][ids.n][1])
    ids.sf2 = int(program_input['hints'][ids.n][2])
  %}
  let (result, n1) = five(s, f, sf1, sf2, l, j, n)
  return (result, n1)
end

func five{hash_ptr : HashBuiltin*}(s, f, sf1, sf2, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  # assert f = [5 sf1 sf2]
  let (h_sf1_sf2) = hash2(x=sf1, y=sf2)
  let (h_f) = hash2(x=h5, y=h_sf1_sf2)
  assert f = h_f

  let (rsf1, n1) = verify(s, sf1, l, j, n+1)
  local res_sf1 = rsf1
  let (res_sf2, n2) = verify(s, sf2, l, j, n1+1)
 
  if res_sf1 == res_sf2:
    return(h0, n2)
  end
  return(h1, n2)
end

func verify_six{hash_ptr : HashBuiltin*}(s, f, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  local sf1
  local sf2
  local sf3
  %{
    ids.sf1 = int(program_input['hints'][ids.n][1])
    ids.sf2 = int(program_input['hints'][ids.n][2])
    ids.sf3 = int(program_input['hints'][ids.n][3])
  %}
  let (result, n1) = six(s, f, sf1, sf2, sf3, l, j, n)
  return (result, n1)
end

func six{hash_ptr : HashBuiltin*}(s, f, sf1, sf2, sf3, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  # assert f = [6 sf1 sf2 sf3]
  let (h_sf2_sf3) = hash2(x=sf2, y=sf3)
  let (h_sf1_sf2_sf3) = hash2(x=sf1, y=h_sf2_sf3)
  let (h_f) = hash2(x=h6, y=h_sf1_sf2_sf3)
  assert f = h_f

  let (rsf1, n1) = verify(s, sf1, l, j, n+1)

  if rsf1 == h0:
    let (result, n2) = verify(s, sf2, l, j, n1+1)
    return (result, n2)
  end

  if rsf1 == h1:
    let (result, n2) = verify(s, sf3, l, j, n1+1)
    return (result, n2)
  end

  assert 0 = 1     # crash
  return (0, 0)       # should never get here
end

func verify_seven{hash_ptr : HashBuiltin*}(s, f, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  local sf1
  local sf2
  %{
    ids.sf1 = int(program_input['hints'][ids.n][1])
    ids.sf2 = int(program_input['hints'][ids.n][2])
  %}
  let (result, n1) = seven(s, f, sf1, sf2, l, j, n)
  return (result, n1)
end

func seven{hash_ptr : HashBuiltin*}(s, f, sf1, sf2, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  # assert f = [7 sf1 sf2]
  let (h_sf1_sf2) = hash2(x=sf1, y=sf2)
  let (h_f) = hash2(x=h7, y=h_sf1_sf2)
  assert f = h_f

  let (rsf1, n1) = verify(s, sf1, l, j, n+1)
  let (result, n2) = verify(rsf1, sf2, l, j, n1+1)
  return (result, n2)
end

func verify_eight{hash_ptr : HashBuiltin*}(s, f, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  local sf1
  local sf2
  %{
    ids.sf1 = int(program_input['hints'][ids.n][1])
    ids.sf2 = int(program_input['hints'][ids.n][2])
  %}
  let (result, n1) = eight(s, f, sf1, sf2, l, j, n)
  return (result, n1)
end

func eight{hash_ptr : HashBuiltin*}(s, f, sf1, sf2, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  # assert f = [8 sf1 sf2]
  let (h_sf1_sf2) = hash2(x=sf1, y=sf2)
  let (h_f) = hash2(x=h8, y=h_sf1_sf2)
  assert f = h_f
  
  let (rsf1, n1) = verify(s, sf1, l, j, n+1)
  let (s2) = hash2(rsf1, s)     # new subject 
  let (rsf2, n2) = verify(s2, sf2, l, j, n1+1)
  return (rsf2, n2)
end

func verify_nine{hash_ptr : HashBuiltin*}(s, f, l : felt*, j : felt*, n: felt) -> (res, n): 
  alloc_locals

  local axis
  local subf
  local f2 
  local path : felt*
  %{
    ids.axis = int(program_input['hints'][ids.n][1])
    ids.subf = int(program_input['hints'][ids.n][2])
    ids.f2 = int(program_input['hints'][ids.n][3])
    sibs = program_input['hints'][ids.n][4]
    ids.path = path = segments.add()
    for i, val in enumerate(sibs):
      memory[ids.path + i] = int(val)
  %}
  let (result, n1) = nine(s, f, axis, subf, f2, path, l, j, n)
  return (result, n1)
end

func nine{hash_ptr : HashBuiltin*}(s, f, axis, subf, f2, path: felt*, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  # assert f = [9 axis subf]
  let (h_axis) = hash2(x=axis, y=0)
  let (h_axis_subf) = hash2(x=h_axis, y=subf)
  let (h_f) = hash2(x=h9, y=h_axis_subf)
  assert f = h_f

  let (rsubf, n1) = verify(s, subf, l, j, n+1)

  let (root) = root_from_axis(axis, f2, path)
  assert root = rsubf
  let (result, n2) = verify(rsubf, f2, l, j, n1+1)
  return (result, n2)
end

func verify_ten{hash_ptr : HashBuiltin*}(s, f, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  local axis
  local subf1
  local subf2
  local old_leaf 
  local path : felt*
  %{
    ids.axis = int(program_input['hints'][ids.n][1])
    ids.subf1 = int(program_input['hints'][ids.n][2])
    ids.subf2 = int(program_input['hints'][ids.n][3])
    ids.old_leaf = int(program_input['hints'][ids.n][4])
    sibs = program_input['hints'][ids.n][5]
    ids.path = path = segments.add()
    for i, val in enumerate(sibs):
      memory[ids.path + i] = int(val)
  %}
  let (result, n1) = ten(s, f, axis, subf1, subf2, old_leaf, path, l, j, n)
  return (result, n1)
end

func ten{hash_ptr : HashBuiltin*}(s, f, axis, subf1, subf2, old_leaf, path: felt*, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  # assert f = [10 [axis subf1] subf2]
  let (h_axis) = hash2(axis, 0)
  let (h_axis_subf1) = hash2(h_axis, subf1)
  let (h_axis_subf1_subf2) = hash2(h_axis_subf1, subf2)
  let (h_f) = hash2(h10, h_axis_subf1_subf2)
  assert f = h_f

  let (rsf1, n1) = verify(s, subf1, l, j, n+1)
  let (rsf2, n2) = verify(s, subf2, l, j, n1+1)

  let (root) = root_from_axis(axis, old_leaf, path)
  assert root = rsf2
  let (new_root) = root_from_axis(axis, rsf1, path) 
  return (new_root, n2)
end

func verify_cons{hash_ptr : HashBuiltin*}(s, f, l : felt*, j : felt*, n: felt) -> (res, n):
alloc_locals

  local subf1
  local subf2
  %{
    ids.subf1 = int(program_input['hints'][ids.n][1])
    ids.subf2 = int(program_input['hints'][ids.n][2])
  %}
  let (result, n1) = cons(s, f, subf1, subf2, l, j, n)
  return (result, n1)
end

func cons{hash_ptr : HashBuiltin*}(s, f, subf1, subf2, l : felt*, j : felt*, n: felt) -> (res, n):
alloc_locals

  # assert f = [subf1 subf2]
  let (hf) = hash2(subf1, subf2)
  assert hf = f

  let (res1, n1) = verify(s, subf1, l, j, n+1)
  let (res2, n2) = verify(s, subf2, l, j, n1+1)
  let (result) = hash2(res1, res2)
  return (result, n2)
end

func verify_jet{hash_ptr : HashBuiltin*}(s, f, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  local head 
  local next
  local arm_axis
  local core_axis
  local sam 
  %{
    ids.head = int(program_input['hints'][ids.n][1])
    ids.next = int(program_input['hints'][ids.n][2])
    ids.arm_axis = int(program_input['hints'][ids.n][3])
    ids.core_axis = int(program_input['hints'][ids.n][4])
    ids.sam = int(program_input['hints'][ids.n][5])
  %}

  let (result, n1) = jet(s, f, head, next, arm_axis, core_axis, sam, l, j, n)
  return (result, n1)
end

# Check that we are trying to call an arm in a core, then check that the arm_axis
# is a jet. If so run the jet instead of evaluating the nock.
# The calling convention is:
# [8 [9 ARM-AXIS 0 CORE-AXIS] 9 2 10 [6 MAKE-SAMPLE] 0 2]
# So check that head is [9 arm_axis 0 core_axis], then check that
# next is [9 2 10 [6 sam] 0 2]
func jet{hash_ptr : HashBuiltin*}(s, f, head, next, arm_axis, core_axis, sam, l : felt*, j : felt*, n: felt) -> (res, n):
  alloc_locals

  # verify that f is [8 head next]
  let (h_head_next) = hash2(head, next)
  let (hf) = hash2(h8, h_head_next)
  assert f = hf

  # Verify that head is [9 arm_axis 0 core_axis]
  let (h_corea) = hash2(core_axis, 0)
  let (h_arma) = hash2(arm_axis, 0)
  let (h0_corea) = hash2(h0, h_corea)
  let (h_arm_core) = hash2(h_arma, h0_corea)
  let (hf) = hash2(h9, h_arm_core)
  assert head = hf 

  # Verify that next is [9 2 10 [6 sam] 0 2]
  let (hash_1) = hash2(h6, sam)
  let (hash_2) = hash2(hash_1, h0_2)
  let (hash_3) = hash2(h10, hash_2)
  let (hash_4) = hash2(h2, hash_3)
  let (h_next) = hash2(h9, hash_4)
  assert next = h_next

  # We have an arm call. Now compute the sample. 
  # Remember we're in an 8 so we want to evaluate:
  # =/  sub  .*(s head)
  # =/  arg  .*(sub^s sam)  :: pin result to head of subject (nock 8)
  # and arg is the hash of our jet sample
  let (sub, n1) = verify(s, head, l, j, n+1)
  let (new_sub) = hash2(sub, s)
  let (arg, n2) = verify(new_sub, sam, l, j, n1+1)

  # OK now call jet ARM_AXIS with sample ARG. 
  let (result) = call_jet(s, f, arm_axis, sam, j, n)
  let (hresult) = hash2(result, 0)
  return (hresult, n2)
end

func call_jet(s, f, arm_axis, sample, j : felt*, n: felt) -> (res):
  ap += SIZEOF_LOCALS

  local labels : felt*

  if j == 0:
    let (label_array) = alloc()
    let (addloc) = get_label_location(add)
    let (decloc) = get_label_location(dec)
    let (mulloc) = get_label_location(mul)
    let (doubleloc) = get_label_location(double)
    assert label_array[0] = addloc
    assert label_array[1] = decloc
    assert label_array[2] = mulloc
    assert label_array[3] = doubleloc
    labels = label_array
  else:
    labels = j
  end

  local label
  %{
    # jet axis (in hoon) -> label array offset (in cairo)
    dict = {
      20:0, # add
      21:1, # dec
      4:2,  # mul
      11:3 # double
      }
    jet = dict.get(ids.arm_axis, "invalid axis")
    ids.label = memory[ids.labels + jet]  
  %}

  [ap] = s; ap++
  [ap] = f; ap++
  [ap] = sample; ap++

  jmp abs label

  add:
  let sub = [ap - 3]
  let form = [ap - 2]
  local arg1
  local arg2
  %{
    ids.arg1 = int(program_input['hints'][ids.n][6]['arg1'])
    ids.arg2 = int(program_input['hints'][ids.n][6]['arg2'])
  %}
  let (result) = add_jet(arg1, arg2)
  return (result)

  dec:
  let sub = [ap - 3]
  let form = [ap - 2]
  local arg
  %{
    ids.arg = int(program_input['hints'][ids.n][6]['arg'])
  %}
  let (result) = dec_jet(arg)
  return (result)

  mul:
  let sub = [ap - 3]
  let form = [ap - 2]
  local arg1
  local arg2
  %{
    ids.arg1 = int(program_input['hints'][ids.n][6]['arg1'])
    ids.arg2 = int(program_input['hints'][ids.n][6]['arg2'])
  %}
  let (result) = mul_jet(arg1, arg2)
  return (result)

  double:
  let sub = [ap - 3]
  let form = [ap - 2]
  local arg
  %{
    ids.arg = int(program_input['hints'][ids.n][6]['arg'])
  %}
  let (result) = mul_jet(arg, 2)
  return (result)
end


func verify{hash_ptr : HashBuiltin*}(s, f, l : felt*, j : felt*, n : felt) -> (res, n):
  ap += SIZEOF_LOCALS

  local labels : felt*
  if l == 0:
    let (label_array) = alloc()
    let (l0loc) = get_label_location(zero)
    let (l1loc) = get_label_location(one)
    let (l2loc) = get_label_location(two)
    let (l3loc) = get_label_location(three)
    let (l4loc) = get_label_location(four)
    let (l5loc) = get_label_location(five)
    let (l6loc) = get_label_location(six)
    let (l7loc) = get_label_location(seven)
    let (l8loc) = get_label_location(eight)
    let (l9loc) = get_label_location(nine)
    let (l10loc) = get_label_location(ten)
    let (consloc) = get_label_location(cons)
    let (jetloc) = get_label_location(jet)
    assert label_array[0] = l0loc
    assert label_array[1] = l1loc
    assert label_array[2] = l2loc
    assert label_array[3] = l3loc
    assert label_array[4] = l4loc
    assert label_array[5] = l5loc
    assert label_array[6] = l6loc
    assert label_array[7] = l7loc
    assert label_array[8] = l8loc
    assert label_array[9] = l9loc
    assert label_array[10] = l10loc
    assert label_array[11] = consloc
    assert label_array[12] = jetloc
    labels = label_array
  else:
    labels = l
  end

  local label
  %{
    element0 = program_input['hints'][ids.n][0]
    if element0 == 'cons':
      opcode = 11 
    elif element0 == 'jet':
      opcode = 12
    else:
      opcode = int(element0)
    ids.label = memory[ids.labels + opcode]
  %}

  # stash all the variables with the ap register so they don't get revoked
  # after the jump
  [ap] = n; ap++
  [ap] = j; ap++
  [ap] = labels; ap++
  [ap] = hash_ptr; ap++
  [ap] = s; ap++
  [ap] = f; ap++

  jmp abs label

  zero:
  let hash_ptr = cast([ap - 3], HashBuiltin*)
  let (result, n1) = verify_zero([ap - 2], [ap - 1], [ap - 6])
  return (result, n1)

  one:
  let hash_ptr = cast([ap - 3], HashBuiltin*)
  let (result, n1) = verify_one([ap - 2], [ap - 1], [ap - 6])
  return (result, n1)

  two:
  let hash_ptr = cast([ap - 3], HashBuiltin*)
  let l = cast([ap - 4], felt*)
  let j = cast([ap - 5], felt*)
  let (result, n1) = verify_two([ap - 2], [ap - 1], l, j, [ap - 6])
  return (result, n1)

  three:
  let hash_ptr = cast([ap - 3], HashBuiltin*)
  let l = cast([ap - 4], felt*)
  let j = cast([ap - 5], felt*)
  let (result, n1) = verify_three([ap - 2], [ap - 1], l, j, [ap - 6])
  return (result, n1)

  four:
  let hash_ptr = cast([ap - 3], HashBuiltin*)
  let l = cast([ap - 4], felt*)
  let j = cast([ap - 5], felt*)
  let (result, n1) = verify_four([ap - 2], [ap - 1], l, j, [ap - 6])
  return (result, n1)

  five:
  let hash_ptr = cast([ap - 3], HashBuiltin*)
  let l = cast([ap - 4], felt*)
  let j = cast([ap - 5], felt*)
  let (result, n1) = verify_five([ap - 2], [ap - 1], l, j, [ap - 6])
  return (result, n1)

  six:
  let hash_ptr = cast([ap - 3], HashBuiltin*)
  let l = cast([ap - 4], felt*)
  let j = cast([ap - 5], felt*)
  let (result, n1) = verify_six([ap - 2], [ap - 1], l, j, [ap - 6])
  return (result, n1)

  seven:
  let hash_ptr = cast([ap - 3], HashBuiltin*)
  let l = cast([ap - 4], felt*)
  let j = cast([ap - 5], felt*)
  let (result, n1) = verify_seven([ap - 2], [ap - 1], l, j, [ap - 6])
  return (result, n1)

  eight:
  let hash_ptr = cast([ap - 3], HashBuiltin*)
  let l = cast([ap - 4], felt*)
  let j = cast([ap - 5], felt*)
  let (result, n1) = verify_eight([ap - 2], [ap - 1], l, j, [ap - 6])
  return (result, n1)

  nine:
  let hash_ptr = cast([ap - 3], HashBuiltin*)
  let l = cast([ap - 4], felt*)
  let j = cast([ap - 5], felt*)
  let (result, n1) = verify_nine([ap - 2], [ap - 1], l, j, [ap - 6])
  return (result, n1)

  ten:
  let hash_ptr = cast([ap - 3], HashBuiltin*)
  let l = cast([ap - 4], felt*)
  let j = cast([ap - 5], felt*)
  let (result, n1) = verify_ten([ap - 2], [ap - 1], l, j, [ap - 6])
  return (result, n1)

  cons:
  let hash_ptr = cast([ap - 3], HashBuiltin*)
  let l = cast([ap - 4], felt*)
  let j = cast([ap - 5], felt*)
  let (result, n1) = verify_cons([ap - 2], [ap - 1], l, j, [ap - 6])
  return (result, n1)

  jet:
  let hash_ptr = cast([ap - 3], HashBuiltin*)
  let l = cast([ap - 4], felt*)
  let j = cast([ap - 5], felt*)
  let (result, n1) = verify_jet([ap - 2], [ap - 1], l, j, [ap - 6])
  return (result, n1)
end

func main{output_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
  alloc_locals
 
  local s
  local f
  %{
    ids.s = int(program_input['subject'])
    ids.f = int(program_input['formula'])
  %}
  let (result, n1) = verify{hash_ptr = pedersen_ptr}(s=s, f=f, l=cast(0, felt*), j=cast(0, felt*), n=0)

  %{
    print(ids.s)
    print(ids.f)
    print(ids.result)
  %}

  serialize_word(s)
  serialize_word(f)
  serialize_word(result)
  return ()
end