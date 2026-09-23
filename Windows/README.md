# Windows setup

## Setup

### Create workspace and clone dotfiles

#### Add "which" command to powershell

```powershell
"`nNew-Alias which get-command" | add-content $profile
```

If profile has not been created:

```powershell
New-Item -path $PROFILE -type File -force
```

Set workspace root path:

```powershell
"`n`$WORKSPACE = 'X:\Development'" | add-content $profile
```

### Disable Office365 key

Using an elevated shell:

- `REG ADD HKCU\Software\Classes\ms-officeapp\Shell\Open\Command /t REG_SZ /d rundll32`


### Core Apps

#### [Scoop](https://scoop.sh/)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop bucket add extras
```

#### [Komorebi](https://github.com/LGUG2Z/komorebi)

Install komorebi as detailed in the readme

##### Create symbolic link to the config file

- `cmd /c mklink "$ENV:UserProfile\komorebi.json" "$WORKSPACE\dotfiles\Windows\config\komorebi.json"`

### Other apps

[Development](docs/development)
- [Typescript](docs/development/typescript)
