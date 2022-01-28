# usage
# python3.9 -m venv ~/cairo_venv
# source ~/cairo_venv/bin/activate
# >>> from utils.merkle.py import hash_noun
# >>> hash_noun([2, 6, 7])

import json
from collections import namedtuple 
from starkware.crypto.signature.signature import pedersen_hash
from starkware.cairo.common.math_utils import as_int

# Nouns are either a number or a list of numbers. 
# Same syntax as Nock.
# Numbers > (P-1)/2 are converted to negative by Cairo

def hash_noun(n):
  # atom
  if type(n) is int:
    return pedersen_hash(n, 0)

  # else cell
  if type(n) is list:
    if n.__len__() == 1:
      return hash_noun(n[0])
    else:
      return pedersen_hash(hash_noun(n[0]), hash_noun(n[1:]))

  else:
    raise Exception('noun should be int or list')

# json_lookup: lookup table of merkle values
# sibling: left or right sibling, determined by axis
# leaf: hashed value or root of sub-tree
# axis
#
# returns: merkle root from fol
def root_from_axis(json_lookup, root, leaf, axis):
  if axis <= 1:
    raise Exception('axis should be >= 2.')

  try:
    sibling = json_lookup[str(root)][str(axis)]
  except:
    raise Exception('[root][axis] not found.')

  if axis == 2:
    return pedersen_hash(leaf, sibling)

  elif axis == 3:
    return pedersen_hash(sibling, leaf)

  new_leaf = 0
  if axis % 2 == 0:
    new_leaf = pedersen_hash(leaf, sibling)
  else:
    new_leaf = pedersen_hash(sibling, leaf)
  return root_from_axis(json_lookup, root, new_leaf, int(axis / 2))


def check_axis(input_json_file, root, leaf, axis):
  f = open(input_json_file)
  j = json.load(f)
  f.close()
  return root_from_axis(j['merkle_siblings'], root, leaf, axis)
  

def example(input_json_file):
  f = open(input_json_file)
  j = json.load(f)
  f.close()
  root = 1832969563318038202482355323522607828463192350149403022354941371033553420549
  leaf = 2258442912665439649622769515993460039756024697697714582745734598954638194578
  axis = 7
  
  return path_root(j['merkle_siblings'], root, leaf, axis)


