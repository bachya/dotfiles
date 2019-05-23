eval `ssh-agent -s`
ssh-add

if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi
