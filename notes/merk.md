hint path is sibling leaves from bottom to top
[%0 axis=@ path=(list phash)]

```
zero(s, f, axis):
verify 0 formula 
- if axis == 1, return subject
- else
  * load path into mem
  * call res = root(leaf=result, axis, path)
- if res == subject, return res

root(leaf, axis, path : felt*)
- sibling is path[0] 
- if axis == 2 or 3, hash w sibling and return
- else compute mod and jmp
  * h = hash2(leaf, sibling) or hash2(sibling, leaf)
  * recur root(leaf=h, axis= (axis or axis-1) / 2, path=path+1)
```


