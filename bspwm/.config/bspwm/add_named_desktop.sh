DESKTOP_NAME=$(bspc query -D --names | $HOME/dmenu_cmd.sh "Desktop")

if [ -z $DESKTOP_NAME ]; then
    exit 0
fi

for existing_desktop in $(bspc query -D --names); do
    if [ "$DESKTOP_NAME" == "$existing_desktop" ]; then
        bspc desktop "$DESKTOP_NAME" -m $(bspc query -M -m focused)
        bspc desktop -f "$DESKTOP_NAME"
        exit 0
    fi
done

# Add the desktop to the focused monitor
bspc monitor -a "$DESKTOP_NAME"
bspc desktop -f "$DESKTOP_NAME"
