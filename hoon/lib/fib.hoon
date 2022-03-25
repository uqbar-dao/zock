|%
++  fib
  |=  n=@ud
  ^-  @ud
  ?:  =(n 0)  0
  ?:  |(=(n 1) =(n 2))  1
  =/  [x1=@ud x2=@ud i=@ud]  [1 1 3]
  |-
  ^-  @ud
  =/  x  (add x1 x2)
  ?:  =(i n)  x
  $(x1 x2, x2 x, i (add 1 i))
--
