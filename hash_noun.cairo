%builtins output pedersen

from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2

struct Noun:
  member is_atom: felt
  member atom : felt 
  member head : Noun*
  member tail : Noun*
end

func hash_noun{hp : HashBuiltin*}(n : Noun*) -> (res):
  if n.is_atom == 1:
    let (hashed_atom) = hash2{hash_ptr=hp}(x=n.atom, y=0) 
    return(hashed_atom)
  else:
    return(0)
  end
end

func main{output_ptr : felt*, pedersen_ptr : HashBuiltin*}():
  alloc_locals
  local null : Noun* = cast(0, Noun*)

  local n : Noun = Noun(is_atom=0, atom=19, head=null, tail=null)

  let (__fp__, _) = get_fp_and_pc()
  
  return()
end
