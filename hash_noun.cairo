%builtins output pedersen

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
  
  return()
end
