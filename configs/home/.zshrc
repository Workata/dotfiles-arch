# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# set locales
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# fpath+=($HOME/.zsh/pure)
# autoload -U promptinit; promptinit
# prompt pure

# alias ls=ls --color=always
unset LSCOLORS
unset LS_COLORS

source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias ls='ls --color'

# ssh for github connection
{ eval `ssh-agent`; ssh-add ~/.ssh/github; } &>/dev/null

# autocomplete
autoload -Uz compinit
compinit
