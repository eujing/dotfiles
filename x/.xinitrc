[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

feh --bg-fill --randomize ~/.wallpapers/*
sxhkd &
compton -cG &
udiskie -2 &
thunar --daemon &
exec bspwm
