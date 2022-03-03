/-  *zink
|%
++  zink
  |_  a=(map * phash)
  +$  eval-state  [h=hints tohash=(list *)]
  ::  eval: assumes that a has a full hash cache of nouns used
  ::
  ++  eval
    |=  [[s=* f=*] state=eval-state]
    ^-  [res=* state=eval-state]
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
      =^  mhsubf1  state  (get-hash subf1)
      =^  mhsubf2  state  (get-hash subf2)
      =^  res-head  state
        (eval [s subf1] state)
      =^  res-tail  state
        (eval [s subf2] state)
      =/  mhint
        ;<  hsubf1=phash  _biff  mhsubf1
        ;<  hsubf2=phash  _biff  mhsubf2
        (some [%cons hsubf1 hsubf2])
      :-  [res-head res-tail]
          (put-hint mhint)
      ::
        %0
      ?>  ?=(@ +.f)
      =/  res  .*(s f)
      =^  mhres  state  (get-hash res)
      =/  mhint
        ;<  hres=phash  _biff  mhres
        (some [%0 +.f hres (merk-sibs s +.f)])
      [res (put-hint mhint)]
      ::
        %1
      =^  mhres  state  (get-hash +.f)
      =/  mhint
        ;<  hres=phash  _biff  mhres
        (some [%1 hres])
      [+.f (put-hint mhint)]
      ::
        %2
      =/  [subf1=* subf2=*]  [+<.f +>.f]
      =^  mhsubf1  state  (get-hash subf1)
      =^  mhsubf2  state  (get-hash subf2)
      =^  res1  state
        (eval [s subf1] state)
      =^  res2  state
        (eval [s subf2] state)
      =/  mhint
        ;<  hsubf1=phash  _biff  mhsubf1
        ;<  hsubf2=phash  _biff  mhsubf2
        (some [%2 hsubf1 hsubf2])
      [.*(res1 res2) (put-hint mhint)]
      ::
        %3
      =^  res  state
        (eval [s +.f] state)
      =^  mhsubf  state  (get-hash +.f)
      ?@  res     ::  1 for false
        =/  mhint
          ;<  hsubf=phash  _biff  mhsubf
          (some [%3 hsubf %atom res])
        [1 (put-hint mhint)]
      =^  mhhash  state  (get-hash -.res)
      =^  mthash  state  (get-hash +.res)
      =/  mhint
        ;<  hsubf=phash  _biff  mhsubf
        ;<  hhash=phash  _biff  mhhash
        ;<  thash=phash  _biff  mthash
        (some [%3 hsubf %cell hhash thash])
      [0 (put-hint mhint)]
      ::
        %4
      =^  res  state
        (eval [s +.f] state)
      =^  mhsubf  state  (get-hash +.f)
      ?>  ?=(@ res)
      =/  mhint
        ;<  hsubf=phash  _biff  mhsubf
        (some [%4 hsubf res])
      [(add 1 res) (put-hint mhint)]
      ::
        %5
      =/  [subf1=* subf2=*]  [+<.f +>.f]
      =^  mhsubf1  state  (get-hash subf1)
      =^  mhsubf2  state  (get-hash subf2)
      =^  res1  state
        (eval [s subf1] state)
      =^  res2  state
        (eval [s subf2] state)
      =/  mhint
        ;<  hsubf1=phash  _biff  mhsubf1
        ;<  hsubf2=phash  _biff  mhsubf2
        (some [%5 hsubf1 hsubf2])
      [=(res1 res2) (put-hint mhint)]
      ::
        %6
      =/  [subf1=* subf2=* subf3=*]  [+<.f +>-.f +>+.f]
      =^  mhsubf1  state  (get-hash subf1)
      =^  mhsubf2  state  (get-hash subf2)
      =^  mhsubf3  state  (get-hash subf3)
      =^  res1  state
        (eval [s subf1] state)
      ?>  ?|(=(0 res1) =(1 res1))
      =^  res2  state
        ?:  =(0 res1)
          (eval [s subf2] state)
          (eval [s subf3] state)
      =/  mhint
        ;<  hsubf1=phash  _biff  mhsubf1
        ;<  hsubf2=phash  _biff  mhsubf2
        ;<  hsubf3=phash  _biff  mhsubf3
        (some [%6 hsubf1 hsubf2 hsubf3])
      [res2 (put-hint mhint)]
      ::
        %7
      =/  [subf1=* subf2=*]  [+<.f +>.f]
      =^  mhsubf1  state  (get-hash subf1)
      =^  mhsubf2  state  (get-hash subf2)
      =^  res1  state
        (eval [s subf1] state)
      =^  res2  state
        (eval [res1 subf2] state)
      =/  mhint
        ;<  hsubf1=phash  _biff  mhsubf1
        ;<  hsubf2=phash  _biff  mhsubf2
        (some [%7 hsubf1 hsubf2])
      [res2 (put-hint mhint)]
      ::
        %8
      =/  [subf1=* subf2=*]  [+<.f +>.f]
      =^  mhsubf1  state  (get-hash subf1)
      =^  mhsubf2  state  (get-hash subf2)
      =^  res1  state
        (eval [s subf1] state)
      =^  res2  state
        (eval [[res1 s] subf2] state)
      =/  mhint
        ;<  hsubf1=phash  _biff  mhsubf1
        ;<  hsubf2=phash  _biff  mhsubf2
        (some [%8 hsubf1 hsubf2])
      [res2 (put-hint mhint)]
      ::
        %9
      =/  [axis=* subf1=*]  [+<.f +>.f]
      ?>  ?=(@ axis)
      =^  mhsubf1  state  (get-hash subf1)
      =^  res1  state
        (eval [s subf1] state)
      =/  f2  .*(res1 [0 axis])
      =^  res2  state
        (eval [res1 f2] state)
      =/  mhint
        ;<  hsubf1=phash  _biff  mhsubf1
        (some [%9 axis hsubf1 (merk-sibs res1 axis)])
      [res2 (put-hint mhint)]
      ::
        %10
      =/  [axis=* subf1=* subf2=*]  [+<-.f +<+.f +>.f]
      ?>  ?=(@ axis)
      =^  mhsubf1  state  (get-hash subf1)
      =^  mhsubf2  state  (get-hash subf2)
      =^  res1  state
        (eval [s subf1] state)
      =^  res2  state
        (eval [s subf2] state)
      =/  res  .*(s f)
      =/  mhint
        ;<  hsubf1=phash  _biff  mhsubf1
        ;<  hsubf2=phash  _biff  mhsubf2
        (some [%10 axis hsubf1 hsubf2 (merk-sibs res2 axis)])
      [res (put-hint mhint)]
      ::
        %11
      =/  subf1=*  +>.f
      (eval [s subf1] state)
    ==
    ::
    ++  get-hash
      |=  n=*
      ^-  [(unit phash) eval-state]
      =/  hn  (~(get by a) n)
      :-  hn
      ?~  hn
      state(tohash [n tohash.state])
      state
    ::
    ++  put-hint
      |=  mhin=(unit hint)
      ^-  eval-state
      ?~  mhin
        state
      =/  inner=(map phash hint)
        (~(gut by h.state) sroot *(map phash hint))
      =/  newh
        %+  ~(put by h.state)
          sroot
        (~(put by inner) froot u.mhin)
      state(h newh)
    ::  +merk-sibs from bottom to top
    ::
    ++  merk-sibs
      |=  [s=* axis=@]
      =|  path=(list phash)
      |-  ^-  (list phash)
      ?:  =(1 axis)
        path
      ?~  axis  !!
      ?@  s  !!
      =/  pick  (cap axis)
      =/  sibling=phash
        %-  ~(got by a)
        ?-(pick %2 +.s, %3 -.s)
      =/  child  ?-(pick %2 -.s, %3 +.s)
      %=  $
        s     child
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

