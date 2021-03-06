
#!/bin/bash

# $HOME/config/display/screen-detector.sh
#
# 1. Script assumes monitors are aligned left[primary] to right
#    (HDMI1, HDMI2, HDMI(N)).
# 2. Script assumes all resolution will be 1920x1080 by
#    default except for LVDS (for my old macbook 1280x800,
#    turn the boolean to false below to disable)
# 3. Script will always add 1920px on the x-axis regardless
#    of the monitors resolution
# 4. Script assumes all display will be HDMI, if not HDMI
#    I am not sure about the order on xrandr list. 
#    Currently mine is:
#      LVDS1 > DP1 > DP2 > DP(n) > HDMI1 > HDMI2 > HDMI(n)
#    There are plenty of display types depending on your
#    driver.
# 
# modify if it doesnt suit your needs. or just use arandr.


# primary monitor assigned as argument
primary=$(echo $1 | awk '{print toupper($0)}')

# use macbook low resolution? set to false if not using 1280x800
lowresmac=IS_LOW_RES_MAC

if [[ $1 == "" ]] ;
then
    echo "Primary not changed. No primary will be assigned"
fi

if ! [ -f $HOME/.config/display/active-screens ];
then
    echo "Not found. Initializing."
    touch $HOME/.config/display/active-screens
fi


if ! [ -f $HOME/.config/display/active-screens ];
then
    exit;
fi

echo "Found. Proceed."

# get disconnected monitors
xrandr | grep disconnected | while read -r line ; do
    # get device id
    device=$(echo $line | cut -f 1 -d ' ')

    # if inside $HOME/.config/display/active-screens. don't output grep results
    if cat $HOME/.config/display/active-screens | grep -q $device ; 
    then
    echo "Turning off $device"
    xrandr --output $device --off
    sed -i "s/$device //g" $HOME/.config/display/active-screens
    fi
done

# starting x axis position
posx=0
posy=0

# get disconnected monitors
xrandr | grep connected | grep -v disconnected | while read -r line ; do
    # get device id
    device=$(echo $line | cut -f 1 -d ' ')

    # if inside $HOME/.config/display/active-screens. don't output grep results
    if ! (cat $HOME/.config/display/active-screens | grep -q $device) ; 
    then
    echo "Turning on $device"
    echo -n "$device " >> $HOME/.config/display/active-screens
    fi
    
    resolution="WIDTHxHEIGHT"
    if echo $device | grep -q "LVDS" ;
    then
        if $lowresmac = true ;
        then
            resolution="1280x800"
        fi
    fi

    if [ -z "$primary" ]; then
        primary=$device
    fi

    if [[ $primary == $device ]] ;
    then
        echo "Setting $device as primary"
    xrandr --output "$device" --mode "$resolution" --pos "$(echo $posx)x$(echo $posy)" --primary
    else
    xrandr --output "$device" --mode "$resolution" --pos "$(echo $posx)x$(echo $posy)"
    fi

    posx=$((posx+WIDTH))
done

compton --config $HOME/.config/compton/config.conf
xrdb $HOME/.Xresources
feh --bg-fill $HOME/Pictures/wallpapers/wallpaper.jpg
bash $HOME/.config/i3/polybar.sh &
bash $HOME/.config/conky/reinitialize-conky.sh
