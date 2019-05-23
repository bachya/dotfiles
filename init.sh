#!/bin/bash
set -e

echo "Initializing dotfiles..."

echo ""
echo "Initializing Homebrew..."
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo ""
echo "Installing dependencies..."
brew bundle

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

echo ""
echo "Setting up FZF..."
$(brew --prefix)/opt/fzf/install

echo ""
echo "Adding solarized..."
curl -O http://ethanschoonover.com/solarized/files/solarized.zip \
    && unzip solarized.zip \
    && open solarized/iterm2-colors-solarized/Solarized\ Dark.itermcolors \
    && rm -rf solarized solarized.zip

echo ""
echo "Adding quicker key repeat (reqires re-login)..."
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

echo ""
echo "Using the latest version of bash..."
echo "/usr/local/bin/bash" | sudo tee -a /etc/shells
chsh -s /usr/local/bin/bash
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
pip3 install \
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
