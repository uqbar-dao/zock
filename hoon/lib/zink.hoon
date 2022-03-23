/-  *zink
|%
++  zink
  |_  cache=(map * phash)
  ::  pederson hash noun
  ++  hash-noun
    |=  n=*
    ^-  [phash (map * phash)]
    (~(hash eval-door [~ *zc-state ~ cache]) n)
  ::  evaluate nock with zink
  ++  eval-noun
    |=  n=^
    ^-  [res=* hint-js=@t c=(map * phash)]
    =/  [res=* st=[h=hints zc=zc-state merks=merk-tree c=(map * phash)]]
          (~(eval eval-door [~ *zc-state ~ cache]) n)
    =/  ch  (create-hints n h.st zc.st merks.st)
    [res (crip (en-json:html js.ch)) cache.ch]
  ::  compile a hoon file and evaluate it with zink
  ++  eval-hoon
    |=  [file=path arm=@tas sample=@t]
    ^-  [res=* hint-js=@t c=(map * phash)]
    =/  src  .^(@t %cx file)
    =/  cs  (slap !>(~) (ream src))
    =/  nock  [q.cs q:(~(mint ut p.cs) %noun (make-hoon arm sample))]
    (eval-noun nock)
  ::  create hoon AST to call core
  ++  make-hoon
    |=  [arm=@tas sample=@t]
    ^-  hoon
    [%cncl [%wing ~[arm]] ~[(ream sample)]]
  ::  create full hint json
  ++  create-hints
    |=  [n=^ h=hints zc=zc-state merks=merk-tree]
    ^-  [js=json cache=(map * phash)]
    =^  hs  cache  (~(hash eval-door [~ *zc-state ~ cache]) -.n)
    =^  hf  cache  (~(hash eval-door [~ *zc-state ~ cache]) +.n)
    :-  %-  pairs:enjs:format
        :~
          ['subject' s+(num:enjs hs)]
          ['formula' s+(num:enjs hf)]
          ['hints' (all:enjs h)]
          ['zero-cache' (zc:enjs zc)]
          ['merks' (merks:enjs merks)]
        ==
    cache
  ::
  ++  eval-door
    |_  st=[h=hints zc=zc-state merks=merk-tree c=(map * phash)]
    ++  eval
      |=  [s=* f=*]
      ^-  [res=* st=[h=hints zc=zc-state merks=merk-tree c=(map * phash)]]
      =*  c  c.st
      =*  h  h.st
      =*  zc  zc.st
      =*  merks  merks.st
      =^  sroot  c  (hash s)
      =^  froot  c  (hash f)
      |^
      ::~&  >  "s={<s>}"
      ::~&  >  "f={<f>}"
      ?+    -.f  !!
        ::  formula is a cell; do distribution
        ::
          ^
        =/  [subf1=* subf2=*]  [-.f +.f]
        =^  res-head  st
          (eval [s subf1])
        =^  res-tail  st
          (eval [s subf2])
        =^  hsubf1  c  (hash subf1)
        =^  hsubf2  c  (hash subf2)
        :-  [res-head res-tail]
            [(put-hint [%cons hsubf1 hsubf2]) zc merks c]
        ::
          %0
        ?>  ?=(@ +.f)
        =/  res  .*(s f)
        =/  axis  +.f
        ::~&  >  "%0 s={<sroot>} axis={<+.f>}"
        :*  res
            (put-hint [%0 axis])
            (put-zero [sroot axis])
            (put-merks s axis)
        ==
        ::
          %1
        =^  hres  c  (hash +.f)
        [+.f [(put-hint [%1 hres]) zc merks c]]
        ::
          %2
        =/  [subf1=* subf2=*]  [+<.f +>.f]
        =^  hsubf1  c  (hash subf1)
        =^  hsubf2  c  (hash subf2)
        =^  res1  st
          (eval [s subf1])
        =^  res2  st
          (eval [s subf2])
        =^  res3  st
          (eval [res1 res2])
        [res3 [(put-hint [%2 hsubf1 hsubf2]) zc merks c]]
        ::
          %3
        =^  res  st
          (eval [s +.f])
        =^  hsubf  c  (hash +.f)
        ?@  res     ::  1 for false
          [1 [(put-hint [%3 hsubf %atom res]) zc merks c]]
        =^  hhash  c  (hash -.res)
        =^  thash  c  (hash +.res)
        [0 [(put-hint [%3 hsubf %cell hhash thash]) zc merks c]]
        ::
          %4
        =^  res  st
          (eval [s +.f])
        =^  hsubf  c  (hash +.f)
        ?>  ?=(@ res)
        [(add 1 res) [(put-hint [%4 hsubf res])] zc merks c]
        ::
          %5
        =/  [subf1=* subf2=*]  [+<.f +>.f]
        =^  hsubf1  c  (hash subf1)
        =^  hsubf2  c  (hash subf2)
        =^  res1  st
          (eval [s subf1])
        =^  res2  st
          (eval [s subf2])
        [=(res1 res2) [(put-hint [%5 hsubf1 hsubf2]) zc merks c]]
        ::
          %6
        =/  [subf1=* subf2=* subf3=*]  [+<.f +>-.f +>+.f]
        =^  hsubf1  c  (hash subf1)
        =^  hsubf2  c  (hash subf2)
        =^  hsubf3  c  (hash subf3)
        =^  res1  st
          (eval [s subf1])
        ?>  ?|(=(0 res1) =(1 res1))
        =^  res2  st
          ?:  =(0 res1)
            (eval [s subf2])
            (eval [s subf3])
        [res2 [(put-hint [%6 hsubf1 hsubf2 hsubf3])] zc merks c]
        ::
          %7
        =/  [subf1=* subf2=*]  [+<.f +>.f]
        =^  hsubf1  c  (hash subf1)
        =^  hsubf2  c  (hash subf2)
        =^  res1  st
          (eval [s subf1])
        =^  res2  st
          (eval [res1 subf2])
        [res2 [(put-hint [%7 hsubf1 hsubf2])] zc merks c]
        ::
          %8
        =/  [subf1=* subf2=*]  [+<.f +>.f]
        =^  hsubf1  c  (hash subf1)
        =^  hsubf2  c  (hash subf2)
        =^  res1  st
          (eval [s subf1])
        =^  res2  st
          (eval [[res1 s] subf2])
        [res2 [(put-hint [%8 hsubf1 hsubf2])] zc merks c]
        ::
          %9
        =/  [axis=* subf1=*]  [+<.f +>.f]
        ?>  ?=(@ axis)
        =^  hsubf1  c  (hash subf1)
        =^  res1  st
          (eval [s subf1])
        =^  f2  st
          (eval [res1 [0 axis]])
        =^  res2  st
          (eval [res1 f2])
        =^  hres1  c  (hash res1)
        :*  res2
            (put-hint [%9 axis hsubf1])
            (put-zero hres1 axis)
            (put-merks res1 axis)
        ==
        ::
          %10
        =/  [axis=* subf1=* subf2=*]  [+<-.f +<+.f +>.f]
        ?>  ?=(@ axis)
        =^  hsubf1  c  (hash subf1)
        =^  hsubf2  c  (hash subf2)
        =^  res1  st
          (eval [s subf1])
        =^  res2  st
          (eval [s subf2])
        =/  res  .*(s f)
        =^  hres  c  (hash res)
        =^  newmerks  c  (put-merks res2 axis)
        =.  merks  newmerks
        :*  res
            (put-hint [%10 axis hsubf1 hsubf2 hres])
            zc
            (put-merks res axis)
        ==
        ::
          %11
        =/  subf1=*  +>.f
        (eval [s subf1])
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
      ::
      ++  put-zero
        |=  [s=phash axis=@ud]
        ^-  zc-state
        =/  inner=(map @ud @ud)
          (~(gut by zc.zc) s ~)
        ?:  (~(has by inner) axis)  zc
        :+
          %+  ~(put by zc.zc)  s
            (~(put by inner) axis num.zc)
          %+  ~(put by rzc.zc)  num.zc
            (my ~[[s axis]])
          +(num.zc)
      ::  build merkel children while walking down the axis of the noun
      ++  put-merks
        |=  [s=* axis=@]
        ^-  [merk-tree (map * phash)]
        ?@  s  [merks.st c]
        ?:  =(axis 1)  [merks.st c]
        ?~  axis  !!
        =/  pick  (cap axis)
        =/  child  ?-(pick %2 -.s, %3 +.s)
        =^  newmerks  c  (put-merks child (mas axis))
        =^  hs  c  (hash s)
        =^  hl  c  (hash -.s)
        =^  hr  c  (hash +.s)
        =.  merks  (~(put by newmerks) hs [hl hr])
        [merks c]
      ::  +merk-sibs from bottom to top
      ::
      ++  merk-sibs
        |=  [s=* axis=@]
        =|  path=(list phash)
        |-  ^-  [(list phash) (map * phash)]
        ?:  =(1 axis)
          [path c]
        ?~  axis  !!
        ?@  s  !!
        =/  pick  (cap axis)
        =^  sibling=phash  c
          %-  hash
             ?-(pick %2 +.s, %3 -.s)
        =/  child  ?-(pick %2 -.s, %3 +.s)
        %=  $
          s     child
          axis  (mas axis)
          path  [sibling path]
        ==
    --
    ::  if x is an atom then hash(x)=h(x, 0)
    ::  else hash([x y])=h(h(x), h(y))
    ::  where h = pedersen hash
    ++  hash
      |=  [n=*]
      ^-  [phash (map * phash)]
      =*  c  c.st
      =/  mh  (~(get by c) n)
      ?.  ?=(~ mh)
        [u.mh c]
      ?@  n
        =/  h  (hash:pedersen:secp:crypto n 0)
        [h (~(put by c) n h)]
      =^  hh  c  $(n -.n)
      =^  ht  c  $(n +.n)
      =/  h  (hash:pedersen:secp:crypto hh ht)
        [h (~(put by c) n h)]
  --
--
++  enjs
  |%
  ++  all
    |=  h=^hints
    ^-  json
    (hints h)
  ::  merkel kids to json
  ++  merks
    |=  m=merk-tree
    ^-  json
    %-  pairs:enjs:format
    %+  turn  ~(tap by m)
    |=  [root=phash l=phash r=phash]
    [(num root) a+[s+(num l) s+(num r) ~]]
  :: zero-cache to json
  ++  zc
    |=  zc=zc-state
    |^  ^-  json
    %-  pairs:enjs:format
    :~  ['zc' (zc-to-js zc.zc)]
        ['reverse-zc' (rzc-to-js rzc.zc)]
    ==
    ++  zc-to-js
      |=  m=zero-cache
      ^-  json
      %-  pairs:enjs:format
      %+  turn  ~(tap by m)
      |=  [sroot=phash v=(map @ud @ud)]
      :-  (num sroot)
      %-  pairs:enjs:format
      %+  turn  ~(tap by v)
      |=  [axis=@ud i=@ud]
      [(num axis) n+(num i)]
    ++  rzc-to-js
      |=  m=reverse-zc
      ^-  json
      %-  pairs:enjs:format
      %+  turn  ~(tap by m)
      |=  [i=@ud v=(map phash @ud)]
      :-  (num i)
      %-  pairs:enjs:format
      %+  turn  ~(tap by v)
      |=  [s=phash axis=@ud]
      [(num s) n+(num axis)]
    --
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
        ==
        ::
          %10
        :~  s+'10'
            s+(num axis.hin)
            s+(num subf1.hin)
            s+(num subf2.hin)
            s+(num newroot.hin)
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

