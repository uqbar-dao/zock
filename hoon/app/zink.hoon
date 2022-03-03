::
::  usage
::  :zink &hash-noun !>([1 2 3])
::  :zink &get-hash !>([1 2 3]
::
/+  *zink, dbug, default-agent
|%
+$  versioned-state
    $%  state-0
    ==
::
+$  state-0  
  $:  %0
      cache=(map * phash)
      deps=(jug child parent)
      reqs=(map wire *)           ::  hashes coming back from localhost/Python
  ==
::
+$  card  card:agent:gall
::
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this      .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%zink initialized successfully'
  `this(state [%0 pre-comp *(jug child parent) *(map wire *)])
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%zink recompiled successfully'
  `this(state !<(versioned-state old-state))
::
++  on-poke 
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl) 
  ?.  ?=(?(%eval %hash-noun %get-hash) mark)  
    (on-poke:def mark vase)
  =/  n=*  !<(noun vase) 
  =*  c  cache.state
  ::
  ?:  ?=(%eval mark)
    ?>  ?=(^ n)
    =|  h=hints
    =^  res  h
      (~(eval zink cache.state) n h)
    ~&  >  res
    ~&  >  (crip (en-json:html (all:enjs h)))
    `this
  ::
  ?:  ?=(%get-hash mark)
    ~&  >>>  `cord`(rsh [3 2] (scot %ui (~(got by c) n)))
    `this  
  ::  else, %hash-noun
  ::
  |^
  ?:  (~(has by c) n)
    `this
  ?@  n
    (req-hash [%atom n])
  =/  [hhead=(unit phash) htail=(unit phash)]
    [(~(get by c) -.n) (~(get by c) +.n)]
  ?:  ?&(?=([~ phash] hhead) ?=([~ phash] htail))
    (req-hash [%cell u.hhead u.htail])
  =^  c1  this  (hash-child -.n hhead)
  =^  c2  this  (hash-child +.n htail)
  [(weld c1 c2) this]
  ::
  ::
  ++  hash-child
    |=  [child=* hn=(unit phash)]
    ^-  (quip card _this)
    ?^  hn 
      `this
    :_  this(deps.state (~(put ju deps.state) child n))
    :~  :*  %pass  /(scot %uv (cut 5 [0 6] eny.bowl))  %agent  
            [our.bowl %zink]  %poke  %hash-noun  !>(child)
        ==
    ==
  ::
  ++  req-hash
    |=  h=hash-req
    ^-  (quip card _this)
    =|  out=outbound-config:iris
    =/  wir=wire  /(scot %uv (cut 5 [0 6] eny.bowl))
    :_  this(reqs.state (~(put by reqs.state) wir n))
    ~[[%pass wir %arvo %i %request [%'GET' (mk-url h) ~ ~] out]]
  ::
  ++  mk-url
    |=  h=hash-req
    ^-  cord
    =/  base=tape  "http://localhost:3000/pedersen?"
    %-  crip
    %+  weld  base
      ?-  -.h
        %atom  "atom={(scow %ud val.h)}"
        %cell  "head={(scow %ud head.h)}&tail={(scow %ud tail.h)}"
      ==
  --
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?.  ?=(%http-response +<.sign-arvo)
    (on-arvo:def wire sign-arvo)
  ?.  ?=(%finished -.client-response.sign-arvo)
    `this
  =/  uf  full-file.client-response.sign-arvo
  ?~  uf  `this
  =/  h=phash  (rash q.data.u.uf dem)
  =/  un=(unit *)  (~(get by reqs.state) wire)
  ?~  un  `this
  =*  n  u.un
  =.  reqs.state  (~(del by reqs.state) wire)
  =.  cache.state  (~(put by cache.state) n h)
  =/  ps=(list parent)
    %~  tap  in
    (~(gut by deps) n *(set parent))
  =.  deps.state  (~(del by deps.state) n)
  =|  cards=(list card)
  ::  if parent is hashed, skip
  ::  if parent has unhashed child, skip
  ::  if parent has both hashed children, call hash-noun
  ::
  |-
  ?~  ps  [cards this]
  ?:  (~(has by cache.state) i.ps)
    $(ps t.ps)
  =/  other=child
    ?:(=(n -.i.ps) +.i.ps -.i.ps)
  ?.  (~(has by cache.state) other)
    $(ps t.ps)
  %_  $
    ps  t.ps
    cards
    :*  :*  %pass  /(scot %uv (cut 5 [0 6] eny.bowl))  %agent  
            [our.bowl %zink]  %poke  %hash-noun  !>(i.ps)
        ==
        cards
    ==
  ==
::
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
