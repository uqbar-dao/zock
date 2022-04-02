|%
++  dec
  |=  [x=@]
  =/  y=@  0
  |-
  ?:  =(+(y) x)  y
  $(y +(y))
++  add
  |=  [x=@ y=@]
  ^-  @
  ?:  =(x 0)  y
  $(x (dec x), y +(y))
++  fib
  |=  n=@ud
  ^-  @ud
  ?:  =(n 0)  0
  ?:  |(=(n 1) =(n 2))  1
  =/  [x1=@ud x2=@ud i=@ud]  [1 1 3]
  =/  count  0
  |-
  ^-  @ud
  =/  x=@ud  (add x1 x2)
  ?:  =(i n)  x
  $(x1 x2, x2 x, i +(i))
--
