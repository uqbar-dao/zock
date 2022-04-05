|%
++  dec
  |=  x=@
  =/  y=@  0
  |-
  ?:  =(+(y) x)  y
  $(y +(y))
++  add
  |=  [x=@ y=@]
  ^-  @
  ?:  =(x 0)  y
  $(x (dec x), y +(y))
++  mul
  |=  [x=@ y=@]
  ?:  |(=(x 0) =(y 0))  0
  =/  a  x
  |-  ^-  @
  ?:  =(y 1)  a
  $(a (add a x), y (dec y))
++  double
  |=  [x=@]
  ^-  @
  (mul 2 x)
--
