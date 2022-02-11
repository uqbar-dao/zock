/-  *zink
|_  a=(map * phash)
++  preprocess
  |=  [s=* f=*]
  ^-  hint
  ?+    -.f  !!
      %0
    hint 
      %1
    [%1 (~(got by a) +.f)]
  ==
--

