
## commands
Set up Python env
```
python3.9 -m venv ~/cairo_venv
source ~/cairo_venv/bin/activate
```

Compile
```
cairo-compile hash_noun.cairo --output out.hash_noun.json
```

Run
```
cairo-run --program out.hash_noun.json --layout=small --print_output
```
