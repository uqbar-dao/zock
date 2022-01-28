
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

cairo-run --program out.zock.json --layout=small --print_output --program_input input.json
```

## troubleshooting

### handling Cairo negative numbers
in cairo you only have values in the range [0,p-1], integers in the range [(p-1)/2,p-1] are "treated as" negative. Use `as_int` from `common.math_utils` to handle this.
```
%{ 
  from starkware.cairo.common.math_utils import as_int 
  print(as_int(ids.x, PRIME)) 
%}
```
