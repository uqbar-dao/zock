/-  *zink
|%
++  zink
  |_  a=(map * phash)
  ::  eval: assumes that a has a full hash cache of nouns used
  ::
  ++  eval
    |=  [[s=* f=*] mh=[m=merks h=hints]]
    ^-  [res=* merks hints]
    =/  [sroot=phash froot=phash]
      [(~(got by a) s) (~(got by a) f)]
    |^
    ?+    -.f  !!
      ::  formula is a cell; do distribution
      ::
        ^
      =/  [subf1=* subf2=*]  [-.f +.f]
      =/  [hsubf1=phash hsubf2=phash] 
        [(~(got by a) subf1) (~(got by a) subf2)]
      =^  res-head  mh
        (eval [s subf1] mh)
      =^  res-tail  mh
        (eval [s subf2] mh)
      :*  [res-head res-tail]  m.mh
          (put-hint [%cell hsubf1 hsubf2])
      ==
      ::
        %0
      ?>  ?=(@ +.f)
      [.*(s f) (walk-axis +.f) (put-hint [%0 +.f])] 
      ::
        %1
      [+.f m.mh (put-hint [%1 (~(got by a) +.f)])]
      ::
        %2
      =/  [subf1=* subf2=*]  [+<.f +>.f]
      =/  [hsubf1=phash hsubf2=phash] 
        [(~(got by a) subf1) (~(got by a) subf2)]
      =^  res1  mh
        (eval [s subf1] mh)
      =^  res2  mh
        (eval [s subf2] mh)
      [.*(res1 res2) m.mh (put-hint [%2 hsubf1 hsubf2])]
      ::
        %3
      =^  res  mh
        (eval [s +.f] mh)
      =*  hsubf  (~(got by a) +.f)
      ?@  res     ::  1 for false
        [1 m.mh (put-hint [%3 hsubf %atom res])]
      =/  [hhash=phash thash=phash]
        [(~(got by a) -.res) (~(got by a) +.res)] 
      [0 m.mh (put-hint [%3 hsubf %cell hhash thash])]
      ::
        %4
      =^  res  mh
        (eval [s +.f] mh)
      ~&  >>>  res
      =*  hsubf  (~(got by a) +.f)
      ?>  ?=(@ res)
      [res m.mh (put-hint [%4 hsubf res])]
      ::
        %5
      =/  [subf1=* subf2=*]  [+<.f +>.f]
      =/  [hsubf1=phash hsubf2=phash] 
        [(~(got by a) subf1) (~(got by a) subf2)]
      =^  res1  mh
        (eval [s subf1] m.mh h.mh)
      =^  res2  mh
        (eval [s subf2] m.mh h.mh)
      [=(res1 res2) m.mh (put-hint [%5 hsubf1 hsubf2])]
    ==
    ::
    ++  put-hint
      |=  hin=hint
      ^-  hints
      =/  inner=(map phash hint)
        (~(gut by h.mh) sroot *(map phash hint))
      %+  ~(put by h.mh)
        sroot
      (~(put by inner) froot hin)
    ::
    ++  walk-axis
      |=  axis=@
      ^-  merks
      |- 
      ?:  =(1 axis)
        m.mh       
      =/  [parent=phash hhead=phash htail=phash]
        [(~(got by a) s) (~(got by a) -.s) (~(got by a) +.s)]
      ?:  (lte axis 3)
        (~(put by m.mh) parent [hhead htail])
      %_  $
        s  ?:(=(0 (mod (div axis 2) 2)) -.s +.s)
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
      :-  (num parent)
      [%a ~[s+(num hhead) s+(num htail)]]
  ::
  ++  hints
    |=  h=^hints
    |^  ^-  json
    %-  pairs:enjs:format
    %+  turn  ~(tap by h)
      |=  [sroot=phash v=(map phash hint)]
      [(num sroot) (inner v)]
    ++  inner
      |=  i=(map phash hint)
      ^-  json
      %-  pairs:enjs:format
      %+  turn  ~(tap by i)
        |=  [froot=phash hin=hint]
        [(num froot) (en-hint hin)]
    ++  en-hint
      |=  hin=hint
      ^-  json
      :-  %a
      ^-  (list json)
      ?-  -.hin
          %0
        ~[s+'0' s+(num axis.hin)]
        ::
          %1
        ~[s+'1' s+(num res.hin)]
        ::
          %2
        ~[s+'2' s+(num subf1.hin) s+(num subf2.hin)]
        ::
          %3
        ::  if atom, head and tail are 0
        ::  
        :*  s+'3'  s+(num subf.hin) 
            ?-  -.subf-res.hin
                %atom
              ~[s+(num +.subf-res.hin) s+'0' s+'0']
                %cell
              :~  s+'0'
                  s+(num head.subf-res.hin)
                  s+(num tail.subf-res.hin)
              ==
            ==
        ==
        ::
          %4
        ~[s+'4' s+(num subf.hin) s+(num subf-res.hin)]
        ::
          %5
        ~[s+'5' s+(num subf1.hin) s+(num subf2.hin)]
        ::
          %cell
        ~[s+'cell' s+(num subf1.hin) s+(num subf2.hin)]
      ==
    --
  ::
  ++  num
    |=  n=@ud
    `cord`(rsh [3 2] (scot %ui n))
  --
--

