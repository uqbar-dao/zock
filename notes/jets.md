# Jets in zink
Gate matching is simple, because gates always have the same default sample and context, for a given version of the stdlib.

Gates in doors are harder, since their core changes depending on the gate's sample.

One way to solve this is to always replace axis 6 with `0` before checking that it matches a registered jetted core.

## Gate matching
Basic idea: we always get something of the form:
`[9 A 10 [6 sub-formula] formula-get-jetted-gate]`

Where:
- **A**: arm to pull in jetted-core
- **sub-formula**: sets up the arguments in axis 6 of jetted-core. Can be further picked apart depending on the specific jet
- **jetted-core**: core we have pre-registered as a jet, based on the Merkleization of its noun

### Examples
```
> !=((add 20 21))
[8 [9 36 0 2.047] 9 2 10 [6 [7 [0 3] 1 20] 7 [0 3] 1 21] 0 2]

> !=((add 20 (add 21 22)))
[8 [9 36 0 2.047] 9 2 10 [6 [7 [0 3] 1 20] 7 [0 3] 8 [9 36 0 2.047] 9 2 10 [6 [7 [0 3] 1 21] 7 [0 3] 1 22] 0 2] 0 2]
```

### Matching Algorithm
Run in Nock 9.  Same algorithm is used for preprocessing and proving.

- check that tail formula is Nock 10 
- check that tail formula of the Nock 10 produces a jetted core
- check that 10 is editing axis 6
- sub-res = recursively run the subformula in 6
- check sub-res structure is appropriate as input for this jet (is this necessary)?
- generate `%jet` hint *or* run jet prover

## Edge Cases
`;:` produces:
```
> !=(;:(add 3 4 5))
[ 8
  [9 36 0 2.047]
  8
  [0 2]
  9
  2
  10
  [6 [7 [0 3] 7 [0 3] 1 3] 7 [0 3] 8 [0 2] 9 2 10 [6 [7 [0 3] 7 [0 3] 1 4] 7 [0 3] 7 [0 3] 1 5] 0 2]
  0
  2
 ]
```

This works fine for our matching algorithm. `[0 2]` of the Nock 10 matches the `add` core, and the rest of the sample generation can be run recursively.

## Doors
Doors are trickier, because arms in a door are jetted, but the door sample is already replaced, so it's harder to match a hash.

The door sample is in axis 30, for all the doors we'd be jetting.  The trick is detecting this during the preprocessing phase. 

A *brute-force* option is to extend the jet matching algorithm. Run the normal gate one, and if the jetted-core lookup fails, replace axis `30` with `0` and check again. Also requires fetching the sample in axis 30 and passing it as the door sample to the jet. 

### Examples
```
> =m (~(put by *(map @t @)) 'tim' 21)
[[7.170.420 21] 0 0]
> =m2 (~(put by m) 'tg' 93)
[[26.484 93] 0 [7.170.420 21] 0 0]

::  instruction to create the put gate, arm 340 in the by core
::    
> !=(~(put by m))
[8 [9 89.596 0 1.023] 9 340 10 [6 0 12] 0 2]
> !=(~(put by m2))
[8 [9 89.596 0 1.023] 9 340 10 [6 0 222] 0 2]

> !=((~(put by m) 't' 22))
[8 [8 [9 89.596 0 1.023] 9 340 10 [6 0 12] 0 2] 9 2 10 [6 [7 [0 3] 1 116] 7 [0 3] 1 22] 0 2]

> =put-nock1 .*(. !=(~(put by m)))
> =put-nock2 .*(. !=(~(put by m2)))

:: door sample is in axis 30
> +30:put-nock1
[[7.170.420 21] 0 0]
> +30:put-nock2
[[26.484 93] 0 [7.170.420 21] 0 0]
```
