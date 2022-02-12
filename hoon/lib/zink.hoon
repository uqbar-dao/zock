/-  *zink
|%
++  zink
  |_  a=(map * phash)
  ::  eval: assumes that a has a full hash cache of nouns used
  ::
  ++  eval
    |=  [[s=* f=*] m=merks h=hints]
    ^-  [res=* merks hints]
    =/  [sroot=phash froot=phash]
      [(~(got by a) s) (~(got by a) f)]
    |^
    ?+    -.f  !!
        %0
    ?>  ?=(@ +.f)
      =^  parent-root  m
        (find-axis +.f)
    [.*(s f) m (put-hint [%0 +.f parent-root])]
      ::
        %1
    [+.f m (put-hint [%1 (~(got by a) +.f)])]
    ==
    ::
    ++  put-hint
      |=  hin=hint
      ^-  hints
      (~(put by h) [sroot froot] hin)
    ::
    ++  find-axis
      |=  axis=@
      ^-  [parent-root=(unit phash) merks]
      |- 
      ?:  =(1 axis)  `m
      =/  [parent-root=phash hhead=phash htail=phash]
        [(~(got by a) s) (~(got by a) -.s) (~(got by a) +.s)]
      ?:  (lte axis 3)
        :-  `parent-root
        (~(put by m) parent-root [hhead htail])
      %_  $
        s  ?:(=(0 (mod axis 2)) -.s +.s)
        axis  (div axis 2)
      ==
    --
  --
--

