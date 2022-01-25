%builtins output pedersen

from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2

struct Noun:
  member is_atom: felt    # 0 true, 1 false; as is proper
  member atom : felt 
  member head : Noun*
  member tail : Noun*
end

func hash_noun{hp : HashBuiltin*}(n : Noun*) -> (res):
  alloc_locals

  if n.is_atom == 0:
    let (hashed_atom) = hash2{hash_ptr=hp}(x=n.atom, y=0) 
    return(hashed_atom)
  else:
    let (hh) = hash_noun{hp=hp}(n=n.head)
    local hash_head = hh
    let (ht) = hash_noun{hp=hp}(n=n.tail)
    local hash_tail = ht
    let (hashed_noun) = hash2{hash_ptr=hp}(x=hash_head, y=hash_tail)
    return(hashed_noun)
  end
end

func verify_merkle_proof{hp : HashBuiltin*}(proof : felt*):
  return()
end

func main{output_ptr : felt*, pedersen_ptr : HashBuiltin*}():
  alloc_locals
  let (__fp__, _) = get_fp_and_pc()

  local null : Noun* = cast(0, Noun*)

  local a2 : Noun = Noun(is_atom=0, atom=2, head=null, tail=null)
  local a3 : Noun = Noun(is_atom=0, atom=3, head=null, tail=null)
  local a4 : Noun = Noun(is_atom=0, atom=4, head=null, tail=null)
  local a5 : Noun = Noun(is_atom=0, atom=5, head=null, tail=null)
  local a6 : Noun = Noun(is_atom=0, atom=6, head=null, tail=null)
  local a7 : Noun = Noun(is_atom=0, atom=7, head=null, tail=null)
  local n2_3 : Noun = Noun(is_atom=1, atom=0, head=&a2, tail=&a3)
  local n4_5 : Noun = Noun(is_atom=1, atom=0, head=&a4, tail=&a5)
  local n6_7 : Noun = Noun(is_atom=1, atom=0, head=&a6, tail=&a7)
  local n2_6_7 : Noun = Noun(is_atom=1, atom=0, head=&a2, tail=&n6_7)
  local n4_5_3 : Noun = Noun(is_atom=1, atom=0, head=&n4_5, tail=&a3)
  local n4_5_6_7 : Noun = Noun(is_atom=1, atom=0, head=&n4_5, tail=&n6_7)
  
  let (h_a2) = hash_noun{hp=pedersen_ptr}(n=&a2)
  let (h_a3) = hash_noun{hp=pedersen_ptr}(n=&a3)
  let (h_a4) = hash_noun{hp=pedersen_ptr}(n=&a4)
  let (h_a5) = hash_noun{hp=pedersen_ptr}(n=&a5)
  let (h_a6) = hash_noun{hp=pedersen_ptr}(n=&a6)
  let (h_a7) = hash_noun{hp=pedersen_ptr}(n=&a7)
  let (h_n2_3) = hash_noun{hp=pedersen_ptr}(n=&n2_3)
  let (h_n4_5) = hash_noun{hp=pedersen_ptr}(n=&n4_5)
  let (h_n6_7) = hash_noun{hp=pedersen_ptr}(n=&n6_7)
  let (h_n2_6_7) = hash_noun{hp=pedersen_ptr}(n=&n2_6_7)
  let (h_n4_5_3) = hash_noun{hp=pedersen_ptr}(n=&n4_5_3)
  let (h_n4_5_6_7) = hash_noun{hp=pedersen_ptr}(n=&n4_5_6_7)
  serialize_word(h_a4)
  serialize_word(h_a5)
  serialize_word(h_a6)
  serialize_word(h_a7)
  serialize_word(h_n4_5)
  serialize_word(h_n4_5_3)
  serialize_word(h_n4_5_6_7)
  return()
end
