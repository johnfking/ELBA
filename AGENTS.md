This repository contains Lua code. Use the `busted` test framework for testing.

If `busted` is not available, install Lua 5.1 and luarocks then install busted:

```
sudo apt-get update && sudo apt-get install -y lua5.1 luarocks
luarocks install busted
```

Run tests with:

```
busted -v spec
```

The setup process installs dependencies from these domains:
- `archive.ubuntu.com`
- `security.ubuntu.com`
- `apt.llvm.org`
- `luarocks.org`
