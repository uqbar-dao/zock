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

func main{output_ptr : felt*, pedersen_ptr : HashBuiltin*}():
  alloc_locals
  let (__fp__, _) = get_fp_and_pc()

  local null : Noun* = cast(0, Noun*)

  local a2 : Noun = Noun(is_atom=0, atom=2, head=null, tail=null)
  local a3 : Noun = Noun(is_atom=0, atom=3, head=null, tail=null)
  local n1 : Noun = Noun(is_atom=1, atom=0, head=&a2, tail=&a3)
  
  let (h_a2) = hash_noun{hp=pedersen_ptr}(n=&a2)
  let (h_a3) = hash_noun{hp=pedersen_ptr}(n=&a3)
  let (h_n1) = hash_noun{hp=pedersen_ptr}(n=&n1)
  serialize_word(h_a2)
  serialize_word(h_a3)
  serialize_word(h_n1)
  return()
end
