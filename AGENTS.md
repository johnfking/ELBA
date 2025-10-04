This repository contains Lua code. Use the `busted` test framework for testing.

Install prerequisites in a fresh Debian/Ubuntu container with:
```
sudo apt-get update
sudo apt-get install -y lua5.4 luarocks
sudo luarocks install busted
```
Make sure `~/.luarocks/bin` is on your `PATH` so the `busted` executable is available.

Run tests with:

```
busted -v spec
```

The setup process installs dependencies from these domains:
- `archive.ubuntu.com`
- `security.ubuntu.com`
- `apt.llvm.org`
- `luarocks.org`
