::
::  usage
::  :zink &eval [[1 2 3] [0 2]]
::  :zink &hash-noun [1 2 3]
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
  ?.  ?=(?(%eval %hash-noun) mark)
    (on-poke:def mark vase)
  =/  n=*  !<(noun vase)
  =*  c  cache.state
  ::
  ?:  ?=(%eval mark)
    ?>  ?=(^ n)
    =/  [res=* h=hints c=(map * phash)]  (eval:zink n [*hints c])
    =^  hs  c  (hash -.n c)
    =^  hf  c  (hash +.n c)
    =/  js=json
        %-  pairs:enjs:format
        :~
          ['subject' s+(num:enjs hs)]
          ['formula' s+(num:enjs hf)]
          ['hints' (all:enjs h)]
        ==
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
