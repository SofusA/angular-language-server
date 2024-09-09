# angular-language-server
a nix flake for angular language server.

## Usage
Works as a standalone executable. 

### Helix
```toml
[language-server.angular]
command = "angular-language-server"

[[language]]
name = "typescript"
language-servers = ["tailwindcss-ls"]

```
