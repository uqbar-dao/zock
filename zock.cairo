%builtins output pedersen

from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2

func verify_merkle{hp : HashBuiltin*}(auth_path : felt*, leaf, axis) -> (root):
  if axis == 2:
    let (r) = hash2{hash_ptr=hp}(x=leaf, y=[auth_path])
    return (root=r)
  end

  if axis == 3:
    let (r) = hash2{hash_ptr=hp}(x=[auth_path], y=leaf)
    return(root=r)
  end

  %{ memory[ap] = ids.axis % 2 %}
  jmp left_sibling if [ap] != 0; ap++

  right_sibling:
    let (h) = hash2{hash_ptr=hp}(x=leaf, y=[auth_path])
    return verify_merkle(auth_path=auth_path + 1, leaf=h, axis=axis / 2)

  left_sibling:
    let (h) = hash2{hash_ptr=hp}([auth_path], leaf)
    return verify_merkle(auth_path=auth_path + 1, leaf=h, axis=(axis -1) / 2)
end

# **TODO** unimplemented
# root: merkle root
# leaf: hashed value or root of sub-tree
# axis
# program_input['auth_paths'][root][axis] is a key to a merkle proof
func verify_axis{hp : HashBuiltin*}(root, leaf, axis):
  # - if axis is 1, check that root == leaf
  # - check whether (root, axis) already computed, return if yes
  # - load (root, axis) into segment 'proof'
  #    SAMPLE CODE
  #     local x : felt**
  #     %{ ids.x = segments.gen_arg([[1, 2], [3, 4]]) %}
  # - verify_merkle(proof, axis)
  ret
end

func tmp_print_hints(root : felt, axis : felt):
  # TRY SEGMENTS
  %{
    r = str(ids.root)
    a = str(ids.axis)
    print(r)
    print(a)
  %}
  return()
end
# print(program_input['mproofs'][r][a])

func main{output_ptr : felt*, pedersen_ptr : HashBuiltin*}():
  alloc_locals
 
  local r23 = -1024168008553002790667416331076178940052697074220694435907157227142754829457
  tmp_print_hints(r23, 3)

  # right sibling hash in [2, 3]
  local auth_path2 = 936823097115478672163131070534991867793647843312823827742596382032679996195
  # left sibling hash in [2, 3]
  local auth_path3 = 1637368371864026355245122316446106576874611007407245016652355316950184561542

  # hash of [h(2), h(3)]
  let root = -1024168008553002790667416331076178940052697074220694435907157227142754829457
  # hash of 2
  let leaf2 = 1637368371864026355245122316446106576874611007407245016652355316950184561542
  let leaf3 = 936823097115478672163131070534991867793647843312823827742596382032679996195

  let (__fp__, _) = get_fp_and_pc()

  let (merkle_res2) = verify_merkle{hp=pedersen_ptr}(&auth_path2, leaf2, 2) 
  let (merkle_res3) = verify_merkle{hp=pedersen_ptr}(&auth_path3, leaf3, 3) 
  let (bad) = verify_merkle{hp=pedersen_ptr}(&auth_path2, leaf3, 3) 
  serialize_word(merkle_res2)
  serialize_word(merkle_res3)
  serialize_word(bad)
  serialize_word(root)

  return()
end
