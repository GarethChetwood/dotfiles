# Development setup

## Lazygit

Install via scoop. Then,

### Add 'gg' alias

```powershell
"`nNew-Alias gg lazygit" | add-content $profile
```

## Neovim

Install via scoop, then configure.

### Configure profile

Use [NVIM_APPNAME (Docs)](https://neovim.io/doc/user/starting/#%24NVIM_APPNAME) to run neovim with different 'profiles'

Set env var `NVIM_APPNAME` to whatever you want your profile to be called.

e.g. `NVIM_APPNAME=nvim-configs\default`

#### Create 'junction' between this repo and the nvim config folder

Use [junction](https://superuser.com/a/1020825)

- `cmd /c mklink /j "$ENV:LocalAppData\$ENV:NVIM_APPNAME" "$WORKSPACE\dotfiles\nvim\nvChad\starter"`

### Install profile dependencies

```powershell
scoop install cmake
```
