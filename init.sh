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
sudo apt-get update && sudo apt-get install -y \
    bash-completion \
    build-essential \
    git \
    libffi-dev \
    libssl-dev \
    python-dev \
    python3-dev \
    tmux \
    tree \
    vim.tiny

echo ""
echo "Cloning a copy of dotfiles..."
if [ ! -d $HOME/dotfiles ]; then
    git clone git@github.com:bachya/dotfiles.git
    cd dotfiles
    git checkout rpi
fi

echo ""
echo "Linking configuration files..."
if [ -f "$HOME/.bashrc" ]; then
	mv -v "$HOME/.bashrc" "$HOME/.bashrc.bak"
fi

if [ -f "$HOME/.bash_profile" ]; then
	mv -v "$HOME/.bash_profile" "$HOME/.bash_profile.bak"
fi

if [ -f "$HOME/.editrc" ]; then
	mv -v "$HOME/.editrc" "$HOME/.editrc.bak"
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

ln -s $HOME/dotfiles/bash_profile ~/.bash_profile
ln -s $HOME/dotfiles/bashrc ~/.bashrc
ln -s $HOME/dotfiles/editrc ~/.editrc
ln -s $HOME/dotfiles/gitconfig ~/.gitconfig
ln -s $HOME/dotfiles/inputrc ~/.inputrc
ln -s $HOME/dotfiles/tmux.conf ~/.tmux.conf

echo ""
echo "Installing Docker..."
curl -sSL https://get.docker.com | sh
usermod -aG docker $(whoami)
mkdir -p /etc/systemd/system/docker.service.d
echo -n """
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H unix:// -H tcp://0.0.0.0:2376
""" > /etc/systemd/system/docker.service.d/override.conf
systemctl daemon-reload
systemctl restart docker.service

echo ""
echo "Installing vim.tiny..."
sudo update-alternatives --install /usr/bin/vi vi /usr/bin/vim.tiny 60
sudo update-alternatives --config vi
sudo update-alternatives --install /usr/bin/vim vim /usr/bin/vim.tiny 60
sudo update-alternatives --config vim
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/vim.tiny 60
sudo update-alternatives --config editor

echo ""
echo "Installing Python packages..."
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py
sudo python3 get-pip.py
rm get-pip.py
pip install --user --upgrade docker-compose

source ~/.bash_profile
