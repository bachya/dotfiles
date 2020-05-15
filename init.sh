#!/bin/bash
set -e

echo "Initializing dotfiles..."

echo ""
echo "Initializing Homebrew..."
/usr/bin/ruby -e \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo ""
echo "Cloning a copy of dotfiles..."
if [ ! -d "$HOME/dotfiles" ]; then
    git clone git@github.com:bachya/dotfiles.git
    cd dotfiles
    git checkout osx
fi

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

mkdir -p "$HOME/.config/nvim"
if [ -f "$HOME/.config/nvim/coc-settings.json" ]; then
    mv -v "$HOME/.config/nvim/coc-settings.json" \
        "$HOME/.config/nvim/coc-settings.json.bak"
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

ln -s "$HOME/dotfiles/bash_profile" "$HOME/.bash_profile"
ln -s "$HOME/dotfiles/bashrc" "$HOME/.bashrc"
ln -s "$HOME/dotfiles/coc-settings.json" "$HOME/.config/nvim/coc-settings.json"
ln -s "$HOME/dotfiles/ctags" "$HOME/.ctags"
ln -s "$HOME/dotfiles/editrc" "$HOME/.editrc"
ln -s "$HOME/dotfiles/git_template" "$HOME/.git_template"
ln -s "$HOME/dotfiles/gitconfig" "$HOME/.gitconfig"
ln -s "$HOME/dotfiles/inputrc" "$HOME/.inputrc"
ln -s "$HOME/dotfiles/tmux.conf" "$HOME/.tmux.conf"
ln -s "$HOME/dotfiles/vim_snippets" "$HOME/.config/nvim/"
ln -s "$HOME/dotfiles/vimrc" "$HOME/.vimrc"

echo ""
echo "Setting up FZF..."
"$(brew --prefix)/opt/fzf/install"

echo ""
echo "Adding One Dark color scheme..."
curl -fLO https://raw.githubusercontent.com/joshdick/onedark.vim/master/term/One%20Dark.itermcolors \
	&& open One%20Dark.itermcolors \
	&& rm -rf One%20Dark.itermcolors

echo ""
echo "Adding quicker key repeat (reqires re-login)..."
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

echo ""
echo "Using the latest version of bash..."
echo "/usr/local/bin/bash" | sudo tee -a /etc/shells
chsh -s /usr/local/bin/bash

echo ""
echo "Installing Python packages..."
/usr/local/bin/pip install neovim
/usr/local/bin/pip3 install \
    "flake8" \
    black \
    docformatter \
    gitlint \
    isort \
    neovim \
    pylint \
    pyls-black \
    pyls-isort \
    python-language-server \
    virtualenv \
    yamllint \
curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | /usr/local/bin/python3
poetry self:update --preview
poetry completions bash > "$(brew --prefix)/etc/bash_completion.d/poetry.bash-completion"

echo ""
echo "Installing nvm..."
mkdir -p  "$HOME/.nvm"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
# shellcheck source=bash_profile
source "$HOME/.bash_profile"
nvm install 8
nvm install 10
nvm alias default 10

echo ""
echo "Installing npm packages..."
npm install -g \
    fixjson \
    neovim \
    serverless

echo ""
echo "Installing yarn..."
curl -o- -L https://yarnpkg.com/install.sh | bash

mkdir -p "$HOME/.config/coc/extensions"
cd "$HOME/.config/coc/extensions"
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
echo "source $HOME/.vimrc" > "$HOME/.config/nvim/init.vim"
curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" \
    --create-dirs https://raw.github.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +UpdateRemotePlugins +CocUpdateSync +qa

echo ""
echo "Configuring espanso..."
espanso install all-emojis

# shellcheck source=bash_profile
source "$HOME/.bash_profile"
