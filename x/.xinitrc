[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

feh --bg-fill --randomize ~/.wallpapers/*
sxhkd &
compton -cG --respect-prop-shadow &
udiskie -2 &
thunar --daemon &
exec bspwm
