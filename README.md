
## commands
[Install CAIRO -- use python3.9, not 3.7](https://www.cairo-lang.org/docs/quickstart.html)

Set up Python env to code
```
python3.9 -m venv ~/cairo_venv
source ~/cairo_venv/bin/activate
```

Compile
```
cairo-compile hash_noun.cairo --output out.hash_noun.json

cairo-compile zock.cairo --output out.zock.json
```

Run
```
cairo-run --program out.hash_noun.json --layout=small --print_output

cairo-run --program out.zock.json --layout=small --print_output
```

## what you're looking at when you run

### hash_noun
The first two outputs are Pedersen hashes of the atoms 2 & 3, respectively. The third output is the Merkle root of the noun with those atoms in head+tail position.

### zock
Outputs:
1. merkle root from checking axis 2
2. merkle root from checking axis 3
3. a bad merkle root (check axis 3 with the wrong proof)
4. the desired merkle root
