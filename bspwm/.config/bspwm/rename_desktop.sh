DESKTOP_NAME=$(echo "" | $HOME/dmenu_cmd.sh "Rename Desktop")

if [ -z $DESKTOP_NAME ]; then
    exit 0
fi

bspc desktop -n "$DESKTOP_NAME"
