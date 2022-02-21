
## commands
[Install CAIRO -- use python3.9, not 3.7](https://www.cairo-lang.org/docs/quickstart.html)

### Set up Python env to code
```
python3.9 -m venv ~/cairo_venv
source ~/cairo_venv/bin/activate
```

### Hash Nouns with Pedersen Hash
```
python3.9
from utils.merkle import hash_noun
hash_noun([2, 6, 7])
```

### Check Merkle Proof
```
python3.9
from utils.merkle import check_axis, hash_noun
root = 1832969563318038202482355323522607828463192350149403022354941371033553420549
leaf = 2258442912665439649622769515993460039756024697697714582745734598954638194578
check_axis('input.json', root, leaf, 7)
```

### Compile CAIRO Code
```
cairo-compile zock.cairo --output out.zock.json
```

Run
```
cairo-run --program out.zock.json --layout=small --print_output --program_input input.json
# Cairo PIE (compressed format??)
cairo-run --program out.zock.json --layout=small --cairo_pie_output pie.zip --print_output --program_input input.json
```

### Submit CAIRO Code and Input to SHARed Prover

First,
```
cairo-sharp submit --source zock.cairo \
    --program_input input.json
```
Expected output similar to:
```
Compiling...
Running...
2258442912665439649622769515993460039756024697697714582745734598954638194578
Submitting to SHARP...
Job sent.
Job key: 94601714-9546-4930-8756-ea66deddc885
Fact: 0x27f52a827c297c3d6036dacf8e715f50a6eadb4035ea2fc83cf081f41a176c1d
```
Then use the job key to check status:
```
cairo-sharp status 94601714-9546-4930-8756-ea66deddc885
```
When ready it will say ```PROCESSED```

### Verify the fact on SHARP 

```
cairo-sharp is_verified --node_url https://eth-goerli.alchemyapi.io/v2/HYoJ9w4vu0iEOru4z0XcceAcedvcXj4a 0x27f52a827c297c3d6036dacf8e715f50a6eadb4035ea2fc83cf081f41a176c1d
```
Ignore the example format in the CAIRO documentation: ```node_url``` apparently needs to come  before ```fact``` (as of 2022.02.21)

## troubleshooting

Use python3.7

### handling Cairo negative numbers
in cairo you only have values in the range [0,p-1], integers in the range [(p-1)/2,p-1] are "treated as" negative. Use `as_int` from `common.math_utils` to handle this.
```
%{ 
  from starkware.cairo.common.math_utils import as_int 
  print(as_int(ids.x, PRIME)) 
%}
```
