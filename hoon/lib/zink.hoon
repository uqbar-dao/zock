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
      =^  parent  m
        (find-axis +.f)
      [.*(s f) m (put-hint [%0 +.f parent])]
      ::
        %1
    [+.f m (put-hint [%1 (~(got by a) +.f)])]
    ==
    ::
    ++  put-hint
      |=  hin=hint
      ^-  hints
      =/  inner=(map phash hint)
        (~(gut by h) sroot *(map phash hint))
      %+  ~(put by h)
        sroot
      (~(put by inner) froot hin)
    ::
    ++  find-axis
      |=  axis=@
      ^-  [parent=(unit phash) merks]
      |- 
      ?:  =(1 axis)  `m
      =/  [parent=phash hhead=phash htail=phash]
        [(~(got by a) s) (~(got by a) -.s) (~(got by a) +.s)]
      ?:  (lte axis 3)
        :-  `parent
        (~(put by m) parent [hhead htail])
      %_  $
        s  ?:(=(0 (mod axis 2)) -.s +.s)
        axis  (div axis 2)
      ==
    --
  --
++  enjs
  |%
  ++  all
    |=  [m=^merks h=^hints]
    ^-  json
    %-  pairs:enjs:format
    :~  ['merks' (merks m)]
        ['hints' (hints h)]
    ==
  ++  merks
    |=  m=^merks
    ^-  json
    %-  pairs:enjs:format
    %+  turn  ~(tap by m)
      |=  [parent=phash hhead=phash htail=phash]
      :-  (numb parent)
      [%a ~[s+(numb hhead) s+(numb htail)]]
  ::
  ++  hints
    |=  h=^hints
    |^  ^-  json
    %-  pairs:enjs:format
    %+  turn  ~(tap by h)
      |=  [sroot=phash v=(map phash hint)]
      [(numb sroot) (inner v)]
    ++  inner
      |=  i=(map phash hint)
      ^-  json
      %-  pairs:enjs:format
      %+  turn  ~(tap by i)
        |=  [froot=phash hin=hint]
        [(numb froot) (en-hint hin)]
    ++  en-hint
      |=  hin=hint
      ^-  json
      ?-  -.hin
          %0
        :-  %a
        ^-  (list json)
        :*  n+'0'  n+(numb axis.hin) 
            ?~  parent.hin  ~ 
            [s+(numb u.parent.hin) ~]
        ==
        ::
          %1
        [%a ~[n+'1' s+(numb res.hin)]]
      ==
    --
  ::
  ++  numb
    |=  n=@ud
    `cord`(rsh [3 2] (scot %ui n))
  --
--

