[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa

N_MONITORS=$(xrandr -q | grep '\bconnected\b' | wc -l)
if [[ $N_MONITORS == "3" ]]; then
    ./.screenlayout/triplemonitor.sh
fi
if [[ $N_MONITORS == "2" ]]; then
    ./.screenlayout/dual-monitors-dorm.sh
fi

# For dunst to work
systemctl --user set-environment DISPLAY=:0

feh --bg-fill --randomize ~/.wallpapers/*
setxkbmap -option caps:escape
xinput --set-prop "SYNA8004:00 06CB:CD8B Touchpad" "libinput Natural Scrolling Enabled" 1
sxhkd &
# compton --config $HOME/.config/compton.conf -b
# udiskie -2 &
thunar --daemon &
exec bspwm
