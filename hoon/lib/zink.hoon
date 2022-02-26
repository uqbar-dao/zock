/-  *zink
|%
++  zink
  |_  a=(map * phash)
  ::  eval: assumes that a has a full hash cache of nouns used
  ::
  ++  eval
    |=  [[s=* f=*] h=hints]
    ^-  [res=* hints]
    =/  [sroot=phash froot=phash]
      [(~(got by a) s) (~(got by a) f)]
    |^
    ~&  >  s
    ~&  >  f
    ?+    -.f  !!
      ::  formula is a cell; do distribution
      ::
        ^
      =/  [subf1=* subf2=*]  [-.f +.f]
      =/  [hsubf1=phash hsubf2=phash] 
        [(~(got by a) subf1) (~(got by a) subf2)]
      =^  res-head  h
        (eval [s subf1] h)
      =^  res-tail  h
        (eval [s subf2] h)
      :-  [res-head res-tail] 
          (put-hint [%cons hsubf1 hsubf2])
      ::
        %0
      ?>  ?=(@ +.f)
      :-  .*(s f) 
      (put-hint [%0 +.f (merk-sibs +.f)])
      ::
        %1
      [+.f (put-hint [%1 (~(got by a) +.f)])]
      ::
        %2
      =/  [subf1=* subf2=*]  [+<.f +>.f]
      =/  [hsubf1=phash hsubf2=phash] 
        [(~(got by a) subf1) (~(got by a) subf2)]
      =^  res1  h
        (eval [s subf1] h)
      =^  res2  h
        (eval [s subf2] h)
      [.*(res1 res2) (put-hint [%2 hsubf1 hsubf2])]
      ::
        %3
      =^  res  h
        (eval [s +.f] h)
      =*  hsubf  (~(got by a) +.f)
      ?@  res     ::  1 for false
        [1 (put-hint [%3 hsubf %atom res])]
      =/  [hhash=phash thash=phash]
        [(~(got by a) -.res) (~(got by a) +.res)] 
      [0 (put-hint [%3 hsubf %cell hhash thash])]
      ::
        %4
      =^  res  h
        (eval [s +.f] h)
      =*  hsubf  (~(got by a) +.f)
      ?>  ?=(@ res)
      [(add 1 res) (put-hint [%4 hsubf res])]
      ::
        %5
      =/  [subf1=* subf2=*]  [+<.f +>.f]
      =/  [hsubf1=phash hsubf2=phash] 
        [(~(got by a) subf1) (~(got by a) subf2)]
      =^  res1  h
        (eval [s subf1] h)
      =^  res2  h
        (eval [s subf2] h)
      [=(res1 res2) (put-hint [%5 hsubf1 hsubf2])]
        %6
      =/  [subf1=* subf2=* subf3=*]  [+<.f +>-.f +>+.f]
      =/  [hsubf1=phash hsubf2=phash hsubf3=phash]
        :*  (~(got by a) subf1)
            (~(got by a) subf2)
            (~(got by a) subf3)
        ==
      =^  res1  h
        (eval [s subf1] h)
      ?>  ?|(=(0 res1) =(1 res1))
      =^  res2  h
        ?:  =(0 res1)
          (eval [s subf2] h)
          (eval [s subf3] h)
      [res2 (put-hint [%6 hsubf1 hsubf2 hsubf3])]
        %7
      =/  [subf1=* subf2=*]  [+<.f +>.f]
      =/  [hsubf1=phash hsubf2=phash]
        [(~(got by a) subf1) (~(got by a) subf2)]
      =^  res1  h
        (eval [s subf1] h)
      =^  res2  h
        (eval [res1 subf2] h)
      [res2 (put-hint [%7 hsubf1 hsubf2])]
        %8
      =/  [subf1=* subf2=*]  [+<.f +>.f]
      =/  [hsubf1=phash hsubf2=phash]
        [(~(got by a) subf1) (~(got by a) subf2)]
      =^  res1  h
        (eval [s subf1] h)
      =^  res2  h
        (eval [[res1 s] subf2] h)
      [res2 (put-hint [%8 hsubf1 hsubf2])]
        %9
      =/  [axis=* subf1=*]  [+<.f +>.f]
      ?>  ?=(@ axis)
      =/  hsubf1=phash  (~(got by a) subf1)
      =^  res1  h
        (eval [s subf1] h)
      =/  f2  .*(res1 [0 axis])
      =^  res2  h
        (eval [res1 f2] h)
      [res2 (put-hint %9 axis hsubf1)]
        %10
      =/  [axis=* subf1=* subf2=*]  [+<-.f +<+.f +>.f]
      ?>  ?=(@ axis)
      =/  [hsubf1=phash hsubf2=phash]
        [(~(got by a) subf1) (~(got by a) subf2)]
      =^  res1  h
        (eval [s subf1] h)
      =^  res2  h
        (eval [s subf2] h)
      =/  res  .*(s f)
      [res (put-hint %10 axis hsubf1 hsubf2)]
        %11
      =/  subf1=*  +>.f
      =/  hsubf1=phash  (~(got by a) subf1)
      =^  res  h
        (eval [s subf1] h)
      [res (put-hint %11 hsubf1)]  :: i think we can just skip the hint
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
    ::  +merk-sibs from bottom to top
    ::
    ++  merk-sibs
      |=  axis=@
      =|  path=(list phash)
      |-  ^-  (list phash)
      ?:  =(1 axis)
        path
      ?~  axis  !!
      ?@  s  !!
      =/  pick  (cap axis)
      =/  sibling=phash
        %-  ~(got by a)
        ?-(pick %2 -.s, %3 +.s)
      %=  $  
        axis  (mas axis)
        path  [sibling path]
      ==
    --
  --
++  enjs
  |%
  ++  all
    |=  h=^hints
    ^-  json
    (hints h)
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
        :~  s+'0'  
            s+(num axis.hin)
            a+(turn path.hin |=(p=phash s+(num p)))
        ==
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
          %6
        ~[s+'6' s+(num subf1.hin) s+(num subf2.hin) s+(num subf3.hin)]
        ::
          %7
        ~[s+'7' s+(num subf1.hin) s+(num subf2.hin)]
        ::
          %8
        ~[s+'8' s+(num subf1.hin) s+(num subf2.hin)]
        ::
          %9
        ~[s+'9' s+(num axis.hin) s+(num subf1.hin)]
        ::
          %10
        ~[s+'10' s+(num axis.hin) s+(num subf1.hin) s+(num subf2.hin)]
        ::
          %11
        ~[s+'11' s+(num subf.hin)]
        ::
          %cons
        ~[s+'cons' s+(num subf1.hin) s+(num subf2.hin)]
      ==
    --
  ::
  ++  num
    |=  n=@ud
    `cord`(rsh [3 2] (scot %ui n))
  --
--

