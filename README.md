# dotfiles
to store personal config files

My Dotfiles
This repository contains my personal configurations for Zsh, including my .zshrc, custom themes, and plugins.

Setting Up on a Fresh Environment

Clone the Repository:

git clone https://github.com/brunesi/dotfiles ~/github/dotfiles

Install Zsh and Oh My Zsh:
If not already installed, install Zsh and Oh My Zsh:

sudo apt install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

Link .zshrc:

Create a symbolic link for the .zshrc file from the repository:

ln -sf ~/dotfiles/.zshrc ~/.zshrc

Set Up Custom Themes and Plugins:

cp -r ~/dotfiles/themes/* ~/.oh-my-zsh/custom/themes/
cp -r ~/dotfiles/plugins/* ~/.oh-my-zsh/custom/plugins/

Switch to Zsh:

chsh -s $(which zsh)

Updating Configurations

If you make changes to your configurations and want to update your repository:

Navigate to Your Repository:

cd ~/github/dotfiles

Stage and Commit Changes:

git add .
git commit -m "Your meaningful commit message here"

Push to GitHub:

git push origin main
