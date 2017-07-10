[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

N_MONITORS=$(xrandr -q | grep '\bconnected\b' | wc -l)
if [[ $N_MONITORS == "3" ]]; then
    ./.screenlayout/triplemonitor.sh
fi
feh --bg-fill --randomize ~/.wallpapers/*
sxhkd &
compton -cG --respect-prop-shadow &
udiskie -2 &
thunar --daemon &
exec bspwm
