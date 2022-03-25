|%
++  dec
  |=  [x=@ i=@]
  =/  j  +(i)
  =/  y=@  0
  |-
  ?:  =(+(y) x)  [y j]
  $(y +(y), i j)
++  add
  |=  [x=@ y=@ i=@]
  ^-  [@ @]
  =/  j  +(i)
  ?:  =(x 0)  [y i]
  =/  [dx=@ di=@]  (dec x j)
  $(x dx, y +(y), i di)
  ::$(x (dec x), y +(y))
++  fib
  |=  n=@ud
  ^-  [@ud @ud]
  ?:  =(n 0)  [0 1]
  ?:  |(=(n 1) =(n 2))  [1 1]
  =/  [x1=@ud x2=@ud i=@ud]  [1 1 3]
  =/  count  0
  |-
  ^-  [@ud @ud]
  =.  count  +(count)
  =/  [x=@ud c=@]  (add x1 x2 count)
  ?:  =(i n)  [x count]
  $(x1 x2, x2 x, i +(i), count c)
--
