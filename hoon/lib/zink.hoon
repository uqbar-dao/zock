/-  *zink
|%
++  zink
  |%
  +$  eval-state  [h=hints c=(map * phash)]
  ::
  ++  create-hints
    |=  [n=* c=(map * phash)]
    ^-  [js=json res=* c=(map * phash)]
    ?>  ?=(^ n)
    =/  [res=* h=hints c=(map * phash)]  (eval:zink n [*hints c])
    =^  hs  c  (hash -.n c)
    =^  hf  c  (hash +.n c)
    :-  %-  pairs:enjs:format
        :~
          ['subject' s+(num:enjs hs)]
          ['formula' s+(num:enjs hf)]
          ['hints' (all:enjs h)]
        ==
    [res c]
  ++  eval
    |=  [[s=* f=*] st=eval-state]
    ^-  [res=* st=eval-state]
    =*  c  c.st
    =^  sroot  c  (hash s c)
    =^  froot  c  (hash f c)
    |^
    ::~&  >  "s={<s>}"
    ::~&  >  "f={<f>}"
    ?+    -.f  !!
      ::  formula is a cell; do distribution
      ::
        ^
      =/  [subf1=* subf2=*]  [-.f +.f]
      =^  res-head  st
        (eval [s subf1] st)
      =^  res-tail  st
        (eval [s subf2] st)
      =^  hsubf1  c  (hash subf1 c)
      =^  hsubf2  c  (hash subf2 c)
      :-  [res-head res-tail]
          [(put-hint [%cons hsubf1 hsubf2]) c]
      ::
        %0
      ?>  ?=(@ +.f)
      =/  res  .*(s f)
      =^  hres  c  (hash res c)
      =^  sibs  c  (merk-sibs [s +.f] c)
      [res [(put-hint [%0 +.f hres sibs]) c]]
      ::
        %1
      =^  hres  c  (hash +.f c)
      [+.f [(put-hint [%1 hres]) c]]
      ::
        %2
      =/  [subf1=* subf2=*]  [+<.f +>.f]
      =^  hsubf1  c  (hash subf1 c)
      =^  hsubf2  c  (hash subf2 c)
      =^  res1  st
        (eval [s subf1] st)
      =^  res2  st
        (eval [s subf2] st)
      =^  res3  st
        (eval [res1 res2] st)
      [res3 [(put-hint [%2 hsubf1 hsubf2]) c]]
      ::
        %3
      =^  res  st
        (eval [s +.f] st)
      =^  hsubf  c  (hash +.f c)
      ?@  res     ::  1 for false
        [1 [(put-hint [%3 hsubf %atom res]) c]]
      =^  hhash  c  (hash -.res c)
      =^  thash  c  (hash +.res c)
      [0 [(put-hint [%3 hsubf %cell hhash thash]) c]]
      ::
        %4
      =^  res  st
        (eval [s +.f] st)
      =^  hsubf  c  (hash +.f c)
      ?>  ?=(@ res)
      [(add 1 res) [(put-hint [%4 hsubf res])] c]
      ::
        %5
      =/  [subf1=* subf2=*]  [+<.f +>.f]
      =^  hsubf1  c  (hash subf1 c)
      =^  hsubf2  c  (hash subf2 c)
      =^  res1  st
        (eval [s subf1] st)
      =^  res2  st
        (eval [s subf2] st)
      [=(res1 res2) [(put-hint [%5 hsubf1 hsubf2]) c]]
      ::
        %6
      =/  [subf1=* subf2=* subf3=*]  [+<.f +>-.f +>+.f]
      =^  hsubf1  c  (hash subf1 c)
      =^  hsubf2  c  (hash subf2 c)
      =^  hsubf3  c  (hash subf3 c)
      =^  res1  st
        (eval [s subf1] st)
      ?>  ?|(=(0 res1) =(1 res1))
      =^  res2  st
        ?:  =(0 res1)
          (eval [s subf2] st)
          (eval [s subf3] st)
      [res2 [(put-hint [%6 hsubf1 hsubf2 hsubf3])] c]
      ::
        %7
      =/  [subf1=* subf2=*]  [+<.f +>.f]
      =^  hsubf1  c  (hash subf1 c)
      =^  hsubf2  c  (hash subf2 c)
      =^  res1  st
        (eval [s subf1] st)
      =^  res2  st
        (eval [res1 subf2] st)
      [res2 [(put-hint [%7 hsubf1 hsubf2])] c]
      ::
        %8
      =/  [subf1=* subf2=*]  [+<.f +>.f]
      =^  hsubf1  c  (hash subf1 c)
      =^  hsubf2  c  (hash subf2 c)
      =^  res1  st
        (eval [s subf1] st)
      =^  res2  st
        (eval [[res1 s] subf2] st)
      [res2 [(put-hint [%8 hsubf1 hsubf2])] c]
      ::
        %9
      =/  [axis=* subf1=*]  [+<.f +>.f]
      ?>  ?=(@ axis)
      =^  hsubf1  c  (hash subf1 c)
      =^  res1  st
        (eval [s subf1] st)
      =^  f2  st
        (eval [res1 [0 axis]] st)
      =^  res2  st
        (eval [res1 f2] st)
      =^  hf2   c  (hash f2 c)
      =^  sibs  c  (merk-sibs [res1 axis] c)
      [res2 [(put-hint [%9 axis hsubf1 hf2 sibs])] c]
      ::
        %10
      =/  [axis=* subf1=* subf2=*]  [+<-.f +<+.f +>.f]
      ?>  ?=(@ axis)
      =^  hsubf1  c  (hash subf1 c)
      =^  hsubf2  c  (hash subf2 c)
      =^  res1  st
        (eval [s subf1] st)
      =^  res2  st
        (eval [s subf2] st)
      =/  res  .*(s f)
      =^  oldleaf  st
        (eval [res2 0 axis] st)
      =^  holdleaf  c  (hash oldleaf c)
      =^  sibs  c  (merk-sibs [res2 axis] c)
      [res [(put-hint [%10 axis hsubf1 hsubf2 holdleaf sibs])] c]
      ::
        %11
      =/  subf1=*  +>.f
      (eval [s subf1] st)
    ==
    ::
    ++  put-hint
      |=  hin=hint
      ^-  hints
      =/  inner=(map phash hint)
        (~(gut by h.st) sroot *(map phash hint))
      %+  ~(put by h.st)
        sroot
      (~(put by inner) froot hin)
    ::  +merk-sibs from bottom to top
    ::
    ++  merk-sibs
      |=  [[s=* axis=@] c=(map * phash)]
      =|  path=(list phash)
      |-  ^-  [(list phash) (map * phash)]
      ?:  =(1 axis)
        [path c]
      ?~  axis  !!
      ?@  s  !!
      =/  pick  (cap axis)
      =^  sibling=phash  c
        %-  hash
           [?-(pick %2 +.s, %3 -.s) c]
      =/  child  ?-(pick %2 -.s, %3 +.s)
      %=  $
        s     child
        axis  (mas axis)
        path  [sibling path]
        c     c
      ==
    --
  --
::  if x is an atom then hash(x)=h(x, 0)
::  else hash([x y])=h(h(x), h(y))
::  where h = pedersen hash
++  hash
  |=  [n=* c=(map * phash)]
  ^-  [phash (map * phash)]
  =/  mh  (~(get by c) n)
  ?.  ?=(~ mh)  [u.mh c]
  ?@  n
    =/  h  (hash:pedersen:secp:crypto n 0)
    [h (~(put by c) n h)]
  =^  hh  c  $(n -.n)
  =^  ht  c  $(n +.n)
  =/  h  (hash:pedersen:secp:crypto hh ht)
    [h (~(put by c) n h)]
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
            s+(num leaf.hin)
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
        ~[s+'4' s+(num subf.hin) s+(num atom.hin)]
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
        :~  s+'9'
            s+(num axis.hin)
            s+(num subf1.hin)
            s+(num leaf.hin)
            a+(turn path.hin |=(p=phash s+(num p)))
        ==
        ::
          %10
        :~  s+'10'
            s+(num axis.hin)
            s+(num subf1.hin)
            s+(num subf2.hin)
            s+(num oldleaf.hin)
            a+(turn path.hin |=(p=phash s+(num p)))
        ==
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

