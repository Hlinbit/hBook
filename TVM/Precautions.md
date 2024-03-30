# Install

- Install link

`tvmc` is not a executable file, it just a python file. So it a good idea to add 

```bash
alias tvmc='python -m tvm.driver.tvmc'
```

to `~/.bashrc`.

# Complie


- Problem

```
Failed to download tophub package for llvm: <urlopen error [Errno 111] Connection refused>
```

- Solution

```
git clone https://github.com/tlc-pack/tophub.git
cp -r tophub/tophub ~/.tvm/
```