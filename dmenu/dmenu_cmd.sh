function get_resolution {
    xrandr --query | grep -w $(bspc query -M -m --names) | sed -n 's/.* \([0-9]\+x[0-9]\+\).*/\1/p'
}

function width {
    get_resolution | cut -d 'x' -f 1
}

function height {
    get_resolution | cut -d 'x' -f 2
}

prompt="$1"
if [ -z $prompt ]; then
    prompt="Run"
fi

# For custom menus that are piped into this script
if [ -p /dev/stdin ]; then
    piped=$(cat)
    echo "$piped" | dmenu -dim 0.10 -h 30 -nb "#3B4252" -nf "#D8DEE9" -sb "#81A1C1" -sf "#E5E9F0" -y $(($(height)/2)) -x $(($(width)/3)) -w $(($(width)/3)) -p "$prompt" -l 5 -fn "SauceCodePro"

# For running executables in $PATH
else
    # Check if desktop is empty before we launched anything
    wids=$(bspc query -N -n .window -d focused | cut -d$'\n' -f1)
    if [[ $wids ]]; then
        empty=false
    else
        empty=true
    fi

    dmenu_run -dim 0.10 -h 30 -nb "#3B4252" -nf "#D8DEE9" -sb "#81A1C1" -sf "#E5E9F0" -y $(($(height)/2)) -x $(($(width)/3)) -w $(($(width)/3)) -p "$prompt" -l 5 -fn "SauceCodePro"

    # Rename a desktop if the launched program is the sole window in it
    if [ $empty = true ]; then
        i=0
        # Sleep until a window appears
        until [ $(bspc query -N -n .window -d focused | cut -d$'\n' -f1) ] || [ i -gt 60 ]; do
            let i++
            sleep 0.5
        done
        instance=$(xprop WM_CLASS -id $(bspc query -N -n .window -d focused) | cut -d' ' -f3 | cut -d'"' -f2)
        bspc desktop -n "$instance"
    fi
fi
