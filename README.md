# dotfiles
## Prepare enviroment
```sh
git clone --bare https://github.com/mozafar/dotfiles.git $HOME/.dotfiles

# You can add this alias to your .zshrc
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

dotfiles checkout
```
## Install requirements
```sh
sudo pacman -S alacritty dmenu imagemagick i3lock nitrogen
```

## Fonts
- [Nerd Fonts](https://www.nerdfonts.com/#home)
- [Powerline Fonts](https://github.com/powerline/fonts)
