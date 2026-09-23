# Check .zprofile is configured properly (as per README.md)
if [[ -z "$ZSH_CONFIG_DIR" ]]; then
echo "ERROR: ZSH_CONFIG_DIR is not set."
echo "Ensure you have a `.zprofile` in \$HOME"
echo "See .zprofile-example"
return 1
fi
