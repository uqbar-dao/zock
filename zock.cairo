%builtins output pedersen

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

# root: merkle root
# leaf: hashed value or root of sub-tree
# axis
# program_input['auth_paths'][root][axis] is a key to a merkle proof
func verify_axis{hp : HashBuiltin*}(root, leaf, axis):
  # - if axis is 1, check that root == leaf
  # - check whether (root, axis) already computed, return if yes
  # - load (root, axis) into segment 'proof'
  # - verify_merkle(proof, axis)
  ret
end

func main{output_ptr : felt*, pedersen_ptr : HashBuiltin*}():
  ret
end
