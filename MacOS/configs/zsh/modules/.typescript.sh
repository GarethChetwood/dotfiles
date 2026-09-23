# Add yarn to $PATH
# path_append "$HOME/.config/yarn/global/node_modules/.bin"

# Add deno to $PATH
# path_append "$HOME/.deno/bin"

# nvm
command -v brew >/dev/null 2>&1 ||
{ echo "Homebrew is not installed or not on PATH"; return 1; }
HOMEBREW_PREFIX="$(brew --prefix)"
export NVM_DIR="$HOME/.nvm"

: "${HOMEBREW_PREFIX:?HOMEBREW_PREFIX is not set}"
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" # This loads nvm (WITH BREW PREFIX)
[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion (WITH BREW PREFIX)

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
