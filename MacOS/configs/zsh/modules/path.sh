# Helper function for appending to $PATH
path_append() {
path+=("$1")
}

path=(
"/opt/homebrew/bin"                                                         # brew
"$HOME/Applications/Visual Studio Code.app/Contents/Resources/app/bin"      # vs code
"/usr/bin/python3"                                                          # python
"$HOME/Library/aws-cli"                                                     # aws-cli
$path
)
