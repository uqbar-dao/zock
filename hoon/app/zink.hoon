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
    =/  [js=json res=* c=(map * phash)]  (create-hints:zink n c)
    ~&  >  "result={<res>}"
    ~&  >  (crip (en-json:html js))
    `this(cache.state c)
  ::  read a hoon source file and evaluate
  ?:  ?=(%eval-hoon mark)
    =/  file  !<(path vase)
    =/  path  (weld /(scot %p our.bowl)/[q.byk.bowl]/(scot %da now.bowl) file)
    =/  src  .^(@t %cx path)
    =/  compiled-src  .*(3 `*`(make src))
    =/  nock  [compiled-src 9 2 10 [6 1 5] 9 10 0 1]
    =/  [js=json res=* c=(map * phash)]  (create-hints:zink nock c)
    ~&  >  "result={<res>}"
    ~&  >  (crip (en-json:html js))
    `this(cache.state c)
  ::  else %hash-noun
    =^  h  c  (hash:zink n c)
    ~&  >>>  `cord`(rsh [3 2] (scot %ui h))
    `this
::
++  on-arvo  on-arvo:def
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
