::
::  usage
::  :zink &eval [[1 2 3] [0 2]]
::  :zink &hash-noun [1 2 3]
::  :zink &eval-hoon /gen/fib/hoon
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
  `this(state [%0 pre-comp])
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
  ?.  ?=(?(%eval %hash-noun %eval-hoon) mark)
    (on-poke:def mark vase)
  =/  n=*  !<(noun vase)
  =*  c  cache.state
  ::  evaluate raw nock passed in to the poke
  ?:  ?=(%eval mark)
    ?>  ?=(^ n)
    ::~&  >  c
    =/  [js=json res=* c=(map * phash)]  (~(create-hints zink [*hints c]) n)
    ~&  >  "result={<res>}"
    ~&  >  (crip (en-json:html js))
    `this(cache.state c)
  ::  read a hoon source file and evaluate
  ?:  ?=(%eval-hoon mark)
    =/  file  !<(path vase)
    ::=/  base  /(scot %p our.bowl)/[q.byk.bowl]/(scot %da now.bowl)
    ::=/  path  (weld base file)
    ~&  >  file
    =/  src  .^(@t %cx file)
    =/  cs  (slap !>(~) (ream src))
    =/  nock  [q.cs q:(~(mint ut p.cs) %noun (ream '(fib 5)'))]
    ::~&  >  (ream '(fib 5)')
    ::=/  nock  q:(slap cs (ream '.'))  ::  build AST by hand
    ?>  ?=(^ nock)
    ::~&  >  nock
    ::=/  compiled-src  .*(3 `*`(make src))
   :: =/  nock  [compiled-src 9 2 10 [6 1 5] 9 10 0 1]
    =/  [js=json res=* c=(map * phash)]  (~(create-hints zink [*hints c]) nock)
    ~&  >  "result={<res>}"
    ~&  >  (crip (en-json:html js))
   :: =/  json-file  (weld file /json)
    ::=/  json-file  (weld base (weld /hints (flop file))
   :: ~&  >  json-file
    ::=/  wire  /(scot %uv (cut 5 [0 6] eny.bowl))
    `this(cache.state c)
    :::~  [%pass wire %arvo %c %info %base %& [json-file %ins %json !>(js)]~]
    ::==
  ::  else %hash-noun
    =^  h  c  (hash:zink n)
    ~&  >>>  `cord`(rsh [3 2] (scot %ui h))
    `this(cache.state c)
::
++  on-arvo  on-arvo:def
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
