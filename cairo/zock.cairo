%builtins output pedersen range_check

from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.math import abs_value
from starkware.cairo.common.math import sign 
from starkware.cairo.common.alloc import alloc

from cap import cap
from mas import mas

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

func leaf_from_axis{hash_ptr : HashBuiltin*}(root : felt, axis : felt, cache: CacheEntry*, cache_size : felt) -> (leaf):
  alloc_locals

  if axis == 1:
    return (root)
  end

  let (lookup) = lookup_cache_safe(cache, cache_size, root, axis)
  if lookup != 0:
    return (lookup)
  end

  local left
  local right
  local child
  %{
    ids.left = int(program_input['merks'][str(ids.root)][0])
    ids.right = int(program_input['merks'][str(ids.root)][1])
  %}
  let (h) = hash2(left, right)
  assert root = h

  if axis == 2:
    return (left)
  end

  if axis == 3:
    return (right)
  end

  let (c) = cap(axis)
  if c == 2:
    child = left
  end

  if c == 3:
    child = right
  end

  let (m) = mas(axis)
  let (result) = leaf_from_axis(child, m, cache, cache_size)
  return (result)
end

# memory slot. descend old and updated trees checking that merkel siblings are identical.
# return leaf in new tree.
func slot{hash_ptr : HashBuiltin*}(old_root, new_root, axis) -> (leaf): 
  alloc_locals

  if axis == 1:
    return (new_root)
  end  

  local old_left
  local old_right
  local new_left
  local new_right
  %{
    ids.old_left = int(program_input['merks'][str(ids.old_root)][0])
    ids.old_right = int(program_input['merks'][str(ids.old_root)][1])
    ids.new_left = int(program_input['merks'][str(ids.new_root)][0])
    ids.new_right = int(program_input['merks'][str(ids.new_root)][1])
  %}  

  let (oldh) = hash2(old_left, old_right)
  let (newh) = hash2(new_left, new_right)
  assert old_root = oldh
  assert new_root = newh

  local old_child
  local new_child
  local old_sib
  local new_sib
  let (c) = cap(axis)
  if c == 2:
    old_child = old_left
    new_child = new_left
    old_sib = old_right
    new_sib = new_right
  end

  if c == 3:
    old_child = old_right
    new_child = new_right
    old_sib = old_left
    new_sib = new_left
  end

  assert old_sib = new_sib  # merkel siblings much be identical in old and updated tree
  let (m) = mas(axis)
  return slot(old_child, new_child, m) 
end

func verify_zero{hash_ptr : HashBuiltin*}(s, f, cache: CacheEntry*) -> (res):
  alloc_locals

  local axis
  %{
    ids.axis = int(program_input['hints'][str(ids.s)][str(ids.f)][1])
  %}
  let (result) = zero(s, f, axis, cache)
  return (result)
end

# Nock 0
# s, f: subject, formula
# result: hashed value or root of subtree; result of running 0
func zero{hash_ptr : HashBuiltin*}(s, f, axis, cache: CacheEntry*) -> (res):
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

  let (leaf) = lookup_cache(cache, s, axis)
  return (leaf)
end

func verify_one{hash_ptr : HashBuiltin*}(s, f, cache: CacheEntry*) -> (res):
  alloc_locals

  local res
  %{
    ids.res = int(program_input['hints'][str(ids.s)][str(ids.f)][1])
  %}
  let (result) = one(s, f, res, cache)
  return (result)
end

# result: hashed value or root of subtree; result of running 1
func one{hash_ptr : HashBuiltin*}(s, f, result, cache: CacheEntry*) -> (res):
  alloc_locals

  # assert f = [1 result]
  let (h) = hash2(x=h1, y=result)
  assert f = h

  return (result)
end

func verify_two{hash_ptr : HashBuiltin*}(s, f, cache: CacheEntry*) -> (res):
  alloc_locals

  local sf1
  local sf2
  %{
    ids.sf1 = int(program_input['hints'][str(ids.s)][str(ids.f)][1])
    ids.sf2 = int(program_input['hints'][str(ids.s)][str(ids.f)][2])
  %}
  let (result) = two(s, f, sf1, sf2, cache)
  return (result)
end

# sf1: first subformula
# sf2: second subformula
# result: hashed value or root of subtree; result of running 2
func two{hash_ptr : HashBuiltin*}(s, f, sf1, sf2, cache: CacheEntry*) -> (res):
  alloc_locals

  # assert f = [2 sf1 sf2]
  let (h_sf1_sf2) = hash2(x=sf1, y=sf2)
  let (h_f) = hash2(x=h2, y=h_sf1_sf2)
  assert f = h_f

  let (res_sf1) = verify(s, sf1, cache)
  let (res_sf2) = verify(s, sf2, cache)
 
  let (result) = verify(s=res_sf1, f=res_sf2, cache=cache)
  return(result)
end

func verify_three{hash_ptr : HashBuiltin*}(s, f, cache: CacheEntry*) -> (res):
  alloc_locals

  local sf
  local atom 
  local head
  local tail
  %{
    ids.sf   = int(program_input['hints'][str(ids.s)][str(ids.f)][1])
    ids.atom = int(program_input['hints'][str(ids.s)][str(ids.f)][2])
    ids.head = int(program_input['hints'][str(ids.s)][str(ids.f)][3])
    ids.tail = int(program_input['hints'][str(ids.s)][str(ids.f)][4])
  %}
  let (result) = three(s, f, sf, atom, head, tail, cache)
  return (result)
end

# if head is 0, then this is an atom
func three{hash_ptr : HashBuiltin*}(s, f, sf, atom, head, tail, cache: CacheEntry*) -> (res):
  let (h) = hash2(x=h3, y=sf)
  assert f = h

  # atom
  if head == 0:
    let (res) = verify(s, sf, cache)
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
  let (res) = verify(s, sf, cache)
  let (h_ht) = hash2(x=head, y=tail)
  assert h_ht = res
  return(h0)
end

func verify_four{hash_ptr : HashBuiltin*}(s, f, cache: CacheEntry*) -> (res):
  alloc_locals

  local sf
  local atom
  %{
    ids.sf = int(program_input['hints'][str(ids.s)][str(ids.f)][1])
    ids.atom = int(program_input['hints'][str(ids.s)][str(ids.f)][2])
  %}
  let (result) = four(s, f, sf, atom, cache)
  return (result)
end

# sf: subformula
# atom: atom returned by subformula
func four{hash_ptr : HashBuiltin*}(s, f, sf, atom, cache: CacheEntry*) -> (res):
  alloc_locals

  # assert f = [4 sf]
  let (h) = hash2(x=h4, y=sf)
  assert f = h

  let (res) = verify(s, sf, cache)
  let (h_a_dec) = hash2(x=atom, y=0)
  assert h_a_dec = res
  let (h_a) = hash2(x=atom + 1, y=0)
  return(h_a)
end

func verify_five{hash_ptr : HashBuiltin*}(s, f, cache: CacheEntry*) -> (res):
  alloc_locals

  local sf1
  local sf2
  %{
    ids.sf1 = int(program_input['hints'][str(ids.s)][str(ids.f)][1])
    ids.sf2 = int(program_input['hints'][str(ids.s)][str(ids.f)][2])
  %}
  let (result) = five(s, f, sf1, sf2, cache)
  return (result)
end

func five{hash_ptr : HashBuiltin*}(s, f, sf1, sf2, cache: CacheEntry*) -> (res):
  alloc_locals

  # assert f = [5 sf1 sf2]
  let (h_sf1_sf2) = hash2(x=sf1, y=sf2)
  let (h_f) = hash2(x=h5, y=h_sf1_sf2)
  assert f = h_f

  let (rsf1) = verify(s, sf1, cache)
  local res_sf1 = rsf1
  let (res_sf2) = verify(s, sf2, cache)
 
  if res_sf1 == res_sf2:
    return(h0)
  end
  return(h1)
end

func verify_six{hash_ptr : HashBuiltin*}(s, f, cache: CacheEntry*) -> (res):
  alloc_locals

  local sf1
  local sf2
  local sf3
  %{
    ids.sf1 = int(program_input['hints'][str(ids.s)][str(ids.f)][1])
    ids.sf2 = int(program_input['hints'][str(ids.s)][str(ids.f)][2])
    ids.sf3 = int(program_input['hints'][str(ids.s)][str(ids.f)][3])
  %}
  let (result) = six(s, f, sf1, sf2, sf3, cache)
  return (result)
end

func six{hash_ptr : HashBuiltin*}(s, f, sf1, sf2, sf3, cache: CacheEntry*) -> (res):
  alloc_locals

  # assert f = [6 sf1 sf2 sf3]
  let (h_sf2_sf3) = hash2(x=sf2, y=sf3)
  let (h_sf1_sf2_sf3) = hash2(x=sf1, y=h_sf2_sf3)
  let (h_f) = hash2(x=h6, y=h_sf1_sf2_sf3)
  assert f = h_f

  let (rsf1) = verify(s, sf1, cache)

  if rsf1 == h0:
    let (result) = verify(s, sf2, cache)
    return (result)
  end

  if rsf1 == h1:
    let (result) = verify(s, sf3, cache)
    return (result)
  end

  assert 0 = 1     # crash
  return (0)       # should never get here
end

func verify_seven{hash_ptr : HashBuiltin*}(s, f, cache: CacheEntry*) -> (res):
  alloc_locals

  local sf1
  local sf2
  %{
    ids.sf1 = int(program_input['hints'][str(ids.s)][str(ids.f)][1])
    ids.sf2 = int(program_input['hints'][str(ids.s)][str(ids.f)][2])
  %}
  let (result) = seven(s, f, sf1, sf2, cache)
  return (result)
end

func seven{hash_ptr : HashBuiltin*}(s, f, sf1, sf2, cache: CacheEntry*) -> (res):
  alloc_locals

  # assert f = [7 sf1 sf2]
  let (h_sf1_sf2) = hash2(x=sf1, y=sf2)
  let (h_f) = hash2(x=h7, y=h_sf1_sf2)
  assert f = h_f

  let (rsf1) = verify(s, sf1, cache)
  let (result) = verify(rsf1, sf2, cache)
  return (result)
end

func verify_eight{hash_ptr : HashBuiltin*}(s, f, cache: CacheEntry*) -> (res):
  alloc_locals

  local sf1
  local sf2
  %{
    ids.sf1 = int(program_input['hints'][str(ids.s)][str(ids.f)][1])
    ids.sf2 = int(program_input['hints'][str(ids.s)][str(ids.f)][2])
  %}
  let (result) = eight(s, f, sf1, sf2, cache)
  return (result)
end

func eight{hash_ptr : HashBuiltin*}(s, f, sf1, sf2, cache: CacheEntry*) -> (res):
  alloc_locals

  # assert f = [8 sf1 sf2]
  let (h_sf1_sf2) = hash2(x=sf1, y=sf2)
  let (h_f) = hash2(x=h8, y=h_sf1_sf2)
  assert f = h_f
  
  let (rsf1) = verify(s, sf1, cache)
  let s2 = hash2(rsf1, s)     # new subject 
  let (rsf2) = verify(s2.result, sf2, cache)
  return (rsf2)
end

func verify_nine{hash_ptr : HashBuiltin*}(s, f, cache: CacheEntry*) -> (res): 
  alloc_locals

  local axis
  local subf
  %{
    ids.axis = int(program_input['hints'][str(ids.s)][str(ids.f)][1])
    ids.subf = int(program_input['hints'][str(ids.s)][str(ids.f)][2])
  %}
  let (result) = nine(s, f, axis, subf, cache)
  return (result)
end

func nine{hash_ptr : HashBuiltin*}(s, f, axis, subf, cache: CacheEntry*) -> (res):
  alloc_locals

  # assert f = [9 axis subf]
  let (h_axis) = hash2(x=axis, y=0)
  let (h_axis_subf) = hash2(x=h_axis, y=subf)
  let (h_f) = hash2(x=h9, y=h_axis_subf)
  assert f = h_f

  let (rsubf) = verify(s, subf, cache)

  let (f2) = lookup_cache(cache, rsubf, axis)
  let (result) = verify(rsubf, f2, cache)
  return (result)
end

func verify_ten{hash_ptr : HashBuiltin*}(s, f, cache: CacheEntry*) -> (res):
  alloc_locals

  local axis
  local subf1
  local subf2
  local new_root
  local path : felt*
  %{
    ids.axis = int(program_input['hints'][str(ids.s)][str(ids.f)][1])
    ids.subf1 = int(program_input['hints'][str(ids.s)][str(ids.f)][2])
    ids.subf2 = int(program_input['hints'][str(ids.s)][str(ids.f)][3])
    ids.new_root = int(program_input['hints'][str(ids.s)][str(ids.f)][4])
  %}
  let (result) = ten(s, f, axis, subf1, subf2, new_root, cache)
  return (result)
end

func ten{hash_ptr : HashBuiltin*}(s, f, axis, subf1, subf2, new_root, cache: CacheEntry*) -> (res):
  alloc_locals

  # assert f = [10 [axis subf1] subf2]
  let (h_axis) = hash2(axis, 0)
  let (h_axis_subf1) = hash2(h_axis, subf1)
  let (h_axis_subf1_subf2) = hash2(h_axis_subf1, subf2)
  let (h_f) = hash2(h10, h_axis_subf1_subf2)
  assert f = h_f

  let (leafSub) = verify(s, subf1, cache)
  let (treeSub) = verify(s, subf2, cache)

  let (leaf) = slot(treeSub, new_root, axis)
  assert leafSub = leaf
  return (new_root)
end

func verify_cons{hash_ptr : HashBuiltin*}(s, f, cache: CacheEntry*) -> (res):
alloc_locals

  local subf1
  local subf2
  %{
    ids.subf1 = int(program_input['hints'][str(ids.s)][str(ids.f)][1])
    ids.subf2 = int(program_input['hints'][str(ids.s)][str(ids.f)][2])
  %}
  let (result) = cons(s, f, subf1, subf2, cache)
  return (result)
end

func cons{hash_ptr : HashBuiltin*}(s, f, subf1, subf2, cache: CacheEntry*) -> (res):
alloc_locals

  # assert f = [subf1 subf2]
  let (hf) = hash2(subf1, subf2)
  assert hf = f

  let (res1) = verify(s, subf1, cache)
  let (res2) = verify(s, subf2, cache)
  let (result) = hash2(res1, res2)
  return (result)
end

func verify{hash_ptr : HashBuiltin*}(s, f, cache: CacheEntry*) -> (res):
  alloc_locals
  # lookup (s, f); make a Nock struct
  # jump based on value of the opcode in struct

  local opcode
  %{
    element0 = program_input['hints'][str(ids.s)][str(ids.f)][0]
    if element0 == 'cons':
      ids.opcode = 100 
    else:
      ids.opcode = int(element0)
    memory[ap] = ids.opcode
  %}
  jmp notzero if [ap] != 0; ap++
  let (result) = verify_zero(s, f, cache)
  return (result)

  notzero:
  %{
    memory[ap] = ids.opcode - 1
  %}
  jmp notone if [ap] != 0; ap++
  let (result) = verify_one(s, f, cache)
  return (result)

  notone:
  %{
    memory[ap] = ids.opcode - 2
  %}
  jmp nottwo if [ap] != 0; ap++
  let (result) = verify_two(s, f, cache)
  return (result)

  nottwo:
  %{
    memory[ap] = ids.opcode - 3
  %}
  jmp notthree if [ap] != 0; ap++
  let (result) = verify_three(s, f, cache)
  return (result)

  notthree:
  %{
    memory[ap] = ids.opcode - 4 
  %}
  jmp notfour if [ap] != 0; ap++
  let (result) = verify_four(s, f, cache)
  return (result)

  notfour:
  %{
    memory[ap] = ids.opcode - 5
  %}
  jmp notfive if [ap] != 0; ap++
  let (result) = verify_five(s, f, cache)
  return (result)

  notfive:
  %{
    memory[ap] = ids.opcode - 6
  %}
  jmp notsix if [ap] != 0; ap++
  let (result) = verify_six(s, f, cache)
  return (result)

  notsix:
  %{
    memory[ap] = ids.opcode - 7
  %}
  jmp notseven if [ap] != 0; ap++
  let (result) = verify_seven(s, f, cache)
  return (result)

  notseven:
  %{
    memory[ap] = ids.opcode - 8
  %}
  jmp noteight if [ap] != 0; ap++
  let (result) = verify_eight(s, f, cache)
  return (result)

  noteight:
  %{
    memory[ap] = ids.opcode - 9
  %}
  jmp notnine if [ap] != 0; ap++
  let (result) = verify_nine(s, f, cache)
  return (result)

  notnine:
  %{
    memory[ap] = ids.opcode - 10
  %}
  jmp notten if [ap] != 0; ap++
  let (result) = verify_ten(s, f, cache)
  return (result)

  notten:
  # only thing left is cons which we are using opcode=100 for 
  assert opcode = 100 
  let (result) = verify_cons(s, f, cache)
  return (result)
end

# Cached nock 0 lookup [sub 0 axis]
struct CacheEntry:
  member sub : felt    # hash of subject
  member axis : felt   
  member leaf : felt    # hash of result
end

# Build cache of nock 0s from input
func load_cache{hash_ptr : HashBuiltin*}(n : felt, cache_start : CacheEntry*, cache_end : CacheEntry*) -> (cache : CacheEntry*):
  alloc_locals

  local sub
  local axis
  %{
    rzc = program_input['zero-cache']['reverse-zc']
    if str(ids.n) in rzc:
      data = list(rzc[str(ids.n)].items())[0]
      ids.sub = int(data[0])
      ids.axis = int(data[1])
    else:
      ids.sub = 0
      ids.axis = 0
  %}

  if sub == 0:
    # end of cache entries to load
    return (cache_end)
  end

  let (leaf) = leaf_from_axis(sub, axis, cache_start, n)
  cache_end.sub = sub
  cache_end.axis = axis
  cache_end.leaf = leaf

  return load_cache(n=n + 1, cache_start = cache_start, cache_end=cache_end + CacheEntry.SIZE)
end


# Lookup nock 0 in cache
func lookup_cache(cache: CacheEntry*, sub : felt, axis : felt) -> (res):
  let (res) = lookup_cache_safe(cache, -1, sub, axis)
  return (res)
end

# cache lookup with bounds checking
func lookup_cache_safe(cache: CacheEntry*, cache_size : felt, sub : felt, axis : felt) -> (res):
  alloc_locals

  local index
  local found
  %{
    d = program_input['zero-cache']['zc']
    if str(ids.sub) in d and str(ids.axis) in d[str(ids.sub)]: 
      ids.index = d[str(ids.sub)][str(ids.axis)]
      if ids.cache_size > -1 and ids.index >= ids.cache_size:
        ids.found = 0
      else:
        ids.found = 1
    else:
      ids.found = 0
  %}

  if found == 0:
    return (0) # not found
  end

  let entry : CacheEntry = cache[index]
  assert entry.axis = axis
  assert entry.sub = sub
  return (entry.leaf)
end

func main{output_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(): 
  alloc_locals
 
  let (cache_start : CacheEntry*) = alloc()
  let (cache_end) = load_cache{hash_ptr=pedersen_ptr}(0, cache_start=cache_start, cache_end=cache_start)

  local s
  local f
  %{
    ids.s = int(program_input['subject'])
    ids.f = int(program_input['formula'])
  %}
  let (result) = verify{hash_ptr=pedersen_ptr}(s=s, f=f, cache=cache_start)

  %{
    print(f"s=  {ids.s}")
    print(f"f=  {ids.f}")
    print(f"res={ids.result}")
  %}

  serialize_word(s)
  serialize_word(f)
  serialize_word(result)
  return ()
end

