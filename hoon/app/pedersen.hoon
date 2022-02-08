::
/+  dbug, default-agent, p=pedersen
|%
+$  versioned-state
    $%  state-0
    ==
::
  :: - (map * hash) : hashes of nouns
  :: - child, parent: nouns
  :: - (jug child parent) : parents who need children to hash
  :: - (map wire/cord * ) : hashes coming back from Python
::
+$  state-0  
  $:  %0
      cache=(map * hash)
      deps=(map child parent)
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
++  req-hash
  |=  h=hash-req
  ^-  card
  =|  out=outbound-config:iris
  |^
  [%pass /(scot %da now) %arvo %i %request [%'GET' (mk-url h) out]
  ++  mk-noun-url 
    =/  base=tape  "http://localhost:3000/pedersen?"
    %+  weld  base
      ?-  -.h
        %atom  "atom={(scow %ud val.h)}"
        %cell  "head={(scow %ud head.h)}&tail={(scow %ud tail.h)}"
      ==
    ==
  --
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
  `this
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%pedersen recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>(team:title our.bowl src.bowl) 
  ?.  ?=(%pedersen-hash-noun mark)
    (on-poke:def mark vase)
  =/  n=*  !<(noun vase) 
  =*  c  cache.state
  ?:  (~(has by c) n)
    `this
  ?@  n
    :: TODO do iris req
    `this
  =/  [head=(unit phash) tail=(unit phash)]
    [(~(get by c) -:n) (~(get by c) +:n)]
  ?:  ?&(!=(~ head) !=(~ tail))
    ::  TODO do iris req for cell
    `this
  ::  else do %hash-noun again
::
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
