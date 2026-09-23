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
