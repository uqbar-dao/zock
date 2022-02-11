/-  *zink
|_  a=(map * phash)
++  eval
  |=  [s=* f=* h=hints m=merks]
  ^-  [res=* hints merks]
  =/  [sroot=phash froot=phash]
  |^
    [(~(got by a) s) (~(got by a) f)]
  ?+    -.f  !!
      %0
    ?>  ?=(@ +.f)
    =^  parent-root  m
      (axis-merks +.f)
    [.*(s f) m (mk-hint [%0 +.f parent-root])]
    ::
      %1
    [+.f m (mk-hint [%1 (~(got by a) +.f]] 
    ==
  ==
  ++  mk-hint
    |=  hin=hint
    (~(put by hints) [sroot froot] hin)
  ::
  ++  axis-merks
    |=  axis=@
    ^-  [parent-root=phash merks]
    ::  TODO use recursive algo from my todos
  --
--

