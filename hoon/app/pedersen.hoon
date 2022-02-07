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
+$  state-0  [%0 counter=@]
::
+$  card  card:agent:gall
::
+$  noun-to-hash
  $%  [%cell head=@ tail=@]
      [%atom val=@]
  ==
::
++  req-hash
  |=  n=noun-to-hash
  ^-  card
  =|  out=outbound-config:iris
  |^
  [%pass /(scot %da now) %arvo %i %request [%'GET' (mk-url n) out]
  ++  mk-noun-url 
    =/  base=tape  "http://localhost:3000/pedersen?"
    %+  weld  base
      ?-  -.n
        %atom  "atom={(scow %ud val.n)}"
        %cell  "head={(scow %ud head.n)}&tail={(scow %ud tail.n)}"
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
  !<(noun vase) 
  `this
::
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
