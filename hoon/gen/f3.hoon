|%
++  arm2  734
++  add
  |=  [x=@ y=@]
  ?:  =(x 0)
    y
  $(x (dec x), y +(y))
--
