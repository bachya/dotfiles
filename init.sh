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
    exuberant-ctags \
    git \
    jq \
    neovim \
    python-pip \
    python3-dev \
    python3-pip \
    python3-pip \
    python3-setuptools \
    thefuck \
    tmux \
    tree

echo ""
echo "Cloning a copy of dotfiles..."
if [ ! -d "$HOME/dotfiles" ]; then
    git clone git@github.com:bachya/dotfiles.git
    cd dotfiles
    git checkout linux
fi

echo ""
echo "Linking configuration files..."
if [ -f "$HOME/.bashrc" ]; then
    mv -v "$HOME/.bashrc" "$HOME/.bashrc.bak"
fi

if [ -f "$HOME/.bash_profile" ]; then
    mv -v "$HOME/.bash_profile" "$HOME/.bash_profile.bak"
fi

if [ -f "$HOME/.config/nvim/coc-settings.json" ]; then
    mv -v "$HOME/.config/nvim/coc-settings.json" "$HOME/.config/nvim/coc-settings.json.bak"
fi

if [ -d "$HOME/.config/nvim/vim_snippets" ]; then
    rm -rf "$HOME/.config/nvim/vim_snippets"
fi

if [ -f "$HOME/.ctags" ]; then
    mv -v "$HOME/.ctags" "$HOME/.ctags.bak"
fi

if [ -f "$HOME/.editrc" ]; then
    mv -v "$HOME/.editrc" "$HOME/.editrc.bak"
fi

if [ -d "$HOME/.git_template" ]; then
    rm -rf "$HOME/.git_template"
fi

if [ -f "$HOME/.gitconfig" ]; then
    mv -v "$HOME/.gitconfig" "$HOME/.gitconfig.bak"
fi

if [ -f "$HOME/.inputrc" ]; then
    mv -v "$HOME/.inputrc" "$HOME/.inputrc.bak"
fi

if [ -f "$HOME/.tmux.conf" ]; then
    mv -v "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak"
fi

if [ -f "$HOME/.vimrc" ]; then
    mv -v "$HOME/.vimrc" "$HOME/.vimrc.bak"
fi

ln -s "$HOME/dotfiles/bash_profile" ~/.bash_profile
ln -s "$HOME/dotfiles/bashrc" ~/.bashrc
mkdir -p ~/.config/nvim
ln -s "$HOME/dotfiles/coc-settings.json" ~/.config/nvim/coc-settings.json
ln -s "$HOME/dotfiles/ctags" ~/.ctags
ln -s "$HOME/dotfiles/editrc" ~/.editrc
ln -s "$HOME/dotfiles/git_template" ~/.git_template
ln -s "$HOME/dotfiles/gitconfig" ~/.gitconfig
ln -s "$HOME/dotfiles/inputrc" ~/.inputrc
ln -s "$HOME/dotfiles/tmux.conf" ~/.tmux.conf
ln -s "$HOME/dotfiles/vim_snippets" ~/.config/nvim/
ln -s "$HOME/dotfiles/vimrc" ~/.vimrc

echo ""
echo "Installing Docker..."
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker "$(whoami)"

echo ""
echo "Installing ripgrep..."
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/11.0.1/ripgrep_11.0.1_amd64.deb
sudo dpkg -i ripgrep_11.0.1_amd64.deb
rm ripgrep_11.0.1_amd64.deb

echo ""
echo "Installing Python packages..."
pip install neovim
pip3 install \
    "flake8" \
    black \
    gitlint \
    isort \
    neovim \
    pydocstyle \
    pylint \
    pyls-black \
    pyls-isort \
    python-language-server \
    virtualenv \
    yamllint \

echo ""
echo "Installing nvm..."
mkdir -p  "$HOME/.nvm"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
source "$HOME/.bash_profile"
nvm install 8
nvm install 10
nvm alias default 10

echo ""
echo "Installing npm packages..."
npm install -g \
    fixjson \
    neovim

echo ""
echo "Installing yarn..."
curl -o- -L https://yarnpkg.com/install.sh | bash

mkdir -p "$HOME/.config/coc/extensions"
cd ~/.config/coc/extensions
if [ ! -f package.json ]
then
    echo '{"dependencies":{}}'> package.json
fi

yarn add \
    coc-python \
    coc-json \
    coc-snippets

echo ""
echo "Installing vim..."
mkdir -p "$HOME/.config/nvim"
echo "source ~/.vimrc" > "$HOME/.config/nvim/init.vim"
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim \
    --create-dirs https://raw.github.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +UpdateRemotePlugins +CocUpdateSync +qa


sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
sudo update-alternatives --config vi
sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
sudo update-alternatives --config vim
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
sudo update-alternatives --config editor

echo ""
echo "Configuring espanso..."
wget https://github.com/federico-terzi/espanso/releases/latest/download/espanso-debian-amd64.deb
sudo apt install ./espanso-debian-amd64.deb
rm ./espanso-debian-amd64.deb
espanso install all-emojis

echo ""
echo "Installing Starship"
curl -fsSL https://starship.rs/install.sh | bash

# shellcheck source=bash_profile
source ~/.bash_profile
