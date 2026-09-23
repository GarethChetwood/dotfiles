# Add yarn to $PATH
# path_append "$HOME/.config/yarn/global/node_modules/.bin"

# Add deno to $PATH
# path_append "$HOME/.deno/bin"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" # This loads nvm (WITH BREW PREFIX)
[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion (WITH BREW PREFIX)

# pnpm

# Mise (pnpm)
eval "$(/opt/homebrew/bin/mise activate zsh)"

export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

# Allow basic lodash emulation in terminal
lodash() {
  node --input-type=module --experimental-network-imports -e "
import _ from 'https://esm.sh/lodash';
import repl from 'repl';

const r = repl.start();
r.context._ = _;
r.displayPrompt();
"
}
