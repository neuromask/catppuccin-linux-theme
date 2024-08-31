# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/nmask/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# brew environment variables
 [ -d /home/linuxbrew/.linuxbrew ] && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
 export XDG_DATA_DIRS="/home/linuxbrew/.linuxbrew/share:$XDG_DATA_DIRS"

# Install zsh and ohmyposh curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/bin
export PATH=$PATH:/home/nmask/bin
eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/config.json)"