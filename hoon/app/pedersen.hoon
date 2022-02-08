::
/+  dbug, default-agent
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
+$  child  *
+$  parent  *
+$  phash  @                     ::  Pedersen hash
+$  hash-req
  $%  [%cell head=phash tail=phash]
      [%atom val=@]
  ==
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
  ~&  >  '%pedersen initialized successfully'
  `this(state [%0 *(map * phash) *(jug child parent) *(map wire *)])
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%pedersen recompiled successfully'
  `this(state !<(versioned-state old-state))
::
++  on-poke 
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl) 
  ?.  ?=(%pedersen-hash-noun mark)
    (on-poke:def mark vase)
  =/  n=*  !<(noun vase) 
  ~&  >>  n
  =*  c  cache.state
  |^
  ?:  (~(has by c) n)
    `this
  ?@  n
    `this  ::(req-hash [%atom n])
  =/  [hhead=(unit phash) htail=(unit phash)]
    [(~(get by c) -.n) (~(get by c) +.n)]
  ?:  ?&(!=(~ hhead) !=(~ htail))
    `this  ::(req-hash [%cell hhead htail])
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
    :~  :*  %pass  /(scot %da now.bowl)  %agent  [our.bowl %pedersen] 
            %poke  %pedersen-hash-noun  !>(child)
        ==
    ==
  ::
  ++  req-hash
    |=  h=hash-req
    ^-  (quip card _this)
    =|  out=outbound-config:iris
    =/  wir=wire  /(scot %da now.bowl)
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
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
::  to handle a number coming back from Python
::  > =j (json [%n '23456'])
::  > (ni:dejs:format j)
::
++  on-fail   on-fail:def
--
