[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

eval `ssh-agent`
ssh-add -k

feh --bg-fill --randomize ~/.wallpapers/*
setxkbmap -option caps:escape
sxhkd &
compton -cG --respect-prop-shadow &
udiskie -2 &
thunar --daemon &
exec bspwm
