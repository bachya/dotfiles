#!/bin/bash
set -e

function ask_for_sudo() {
    # Ask for the administrator password upfront:
    sudo -v &> /dev/null

  # Update existing `sudo` time stamp until this script has finished:
  # https://gist.github.com/cowboy/3118588
  while true; do
      sudo -n true
      sleep 60
      kill -0 "$$" || exit
  done &> /dev/null &
}

echo "Initializing dotfiles..."

echo ""
echo "Installing dependencies..."
sudo apt-add-repository -y ppa:neovim-ppa/stable
sudo apt-get update && sudo apt-get install -y \
    bash-completion \
    build-essential \
    git \
    neovim \
    python-pip \
    python3-dev \
    python3-pip \
    python3-pip \
    python3-setuptools \
    thefuck \
    tmux \
    tree

curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.1/ripgrep_11.0.1_amd64.deb
sudo dpkg -i ripgrep_11.0.1_amd64.deb
rm ripgrep_11.0.1_amd64.deb

sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
sudo update-alternatives --config vi
sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
sudo update-alternatives --config vim
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
sudo update-alternatives --config editor

echo ""
echo "Linking configuration files..."
if [ -f "$HOME/.bashrc" ]; then
    mv -v "$HOME/.bashrc" "$HOME/.bashrc.bak"
fi

if [ -f "$HOME/.bash_profile" ]; then
    mv -v "$HOME/.bash_profile" "$HOME/.bash_profile.bak"
fi

if [ -f "$HOME/.ctags" ]; then
    mv -v "$HOME/.ctags" "$HOME/.ctags.bak"
fi

if [ -f "$HOME/.editrc" ]; then
    mv -v "$HOME/.editrc" "$HOME/.editrc.bak"
fi

if [ -f "$HOME/.gitconfig" ]; then
    mv -v "$HOME/.gitconfig" "$HOME/.gitconfig.bak"
fi

if [ -f "$HOME/.tmux.conf" ]; then
    mv -v "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak"
fi

if [ -f "$HOME/.vimrc" ]; then
    mv -v "$HOME/.vimrc" "$HOME/.vimrc.bak"
fi

ln -s $HOME/dotfiles/bash_profile ~/.bash_profile
ln -s $HOME/dotfiles/bashrc ~/.bashrc
ln -s $HOME/dotfiles/ctags ~/.ctags
ln -s $HOME/dotfiles/editrc ~/.editrc
ln -s $HOME/dotfiles/gitconfig ~/.gitconfig
ln -s $HOME/dotfiles/tmux.conf ~/.tmux.conf
ln -s $HOME/dotfiles/vimrc ~/.vimrc

source ~/.bash_profile

mkdir -p "$HOME/.config/nvim"
echo "source ~/.vimrc" > "$HOME/.config/nvim/init.vim"

echo ""
echo "Installing vim..."
mkdir -p ~/.vim/autoload
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo ""
echo "Installing Python packages..."
sudo pip3 install \
    "autopep8" \
    "flake8" \
    coverage \
    gitlint \
    isort \
    neovim \
    pylint \
    pyls-isort \
    pyls-mypy \
    python-language-server \
    yamllint \
    yapf

vim +PlugUpdate
