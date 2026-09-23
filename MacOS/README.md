
# MacOS setup

## Setup

### Create workspace and clone dotfiles

```bash
mkdir ~/Documents/Workspace && cd ~/Documents/Workspace/ && git clone https://github.com/Gazareth/dotfiles.git;
```

Once we have all config files locally, we can start setting up sym links to them. This makes the repo the single source of truth.

### zsh config

```bash
CONFIGS_PATH="$HOME/Documents/Workspace/dotfiles/MacOS/configs" # Edit this to match your setup
ln -s "$CONFIGS_PATH/.zshrc" "$HOME/.zshrc"
ln -s "$CONFIGS_PATH/.zsh" "$HOME/.zsh"
```

Verify

```bash
ls -la ~ | grep zsh
```

### Brew

Follow steps at https://brew.sh/

> [!NOTE]
> XCode is a dependency, and its installation may hang, but it completed anyway; just cancel the command and re-run the brew installation command

> [!IMPORTANT]
> Once installed, run `export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"` to ensure all future apps are installed to
>
> Alternatively, link .zshconfig from `/configs/.zshconfig
>
> ````bash
>
> ```
>

### Warp

Fully featured modern terminal, with text-editor-style input.

https://formulae.brew.sh/cask/warp#default

### Karabiner

Config-based low-level keyboard remaps, with community snippets

[Homebrew Formulae - Karabiner Elements](https://formulae.brew.sh/cask/karabiner-elements)

#### Install (via brew)

```bash
brew install --cask karabiner-elements
```

My config is at `configs/.config/karabiner`

### Blink

Instant desktop ("space") switching



### Hammerspoon

Scripting system that allows me to:

- Toggle windows (bring to front/send to back)
  - Finder
  - System settings
  - Slack
    - On multi monitor, moves mouse to & from slack monitor
- Drag to scroll when holding middle mouse
- Shortcuts for going to start/end of line, with optional highlighting

#### Install (via brew)
