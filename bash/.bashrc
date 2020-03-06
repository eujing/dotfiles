#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W] > '

if [ -f ~/.bash_aliases ]; then
. ~/.bash_aliases
fi

export PATH=/home/eujing/.local/bin:$PATH

# Virtualenvwrapper settings
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Projects
source $HOME/.local/bin/virtualenvwrapper.sh

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export EDITOR=nvim
export PYTHONSTARTUP=~/.pythonrc

# To fix running of Java programs in bspwm
wmname LG3D
