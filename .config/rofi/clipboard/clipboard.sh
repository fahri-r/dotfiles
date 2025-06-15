#!/usr/bin/env bash

if [[ -z $(wl-paste) ]]; then
    notify-send -u critical -t 4000 "Clipboard Manager" "Clipboard is empty"
    exit
fi

dir="$HOME/.config/rofi/clipboard"
theme='clipboard'

choice=$(echo -e "\t\uf1f8   Wipe Clipboard\n$(cliphist list)" | rofi -p "" -markup-rows -dmenu -display-columns 2 -theme ${dir}/${theme}.rasi)

if [[ $choice == *"Wipe Clipboard"* ]]; then
    yes=''
    no=''

    confirmation=$(echo -e "$yes\n$no" | rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
		-theme-str 'mainbox {spacing:15px; padding: 30px; background-color: transparent; children: [ "message", "listview" ];}' \
		-theme-str 'listview {columns: 2; lines: 1; spacing: 15px;}' \
		-theme-str 'textbox {horizontal-align: 0.5;}' \
		-theme-str 'element-text {font: "JetBrainsMono Nerd Font 32"; horizontal-align: 0.5;}' \
		-theme-str 'element {border-radius: 20px; padding: 40px 10px;background-color: @background-alt; text-color: @text;}' \
		-theme-str 'element selected active, element selected normal {border-radius: 20px;}' \
		-dmenu \
		-p 'Confirmation' \
		-mesg 'Are you Sure?' \
		-theme ${dir}/${theme}.rasi)

    if [[ "$confirmation" == "$yes" ]]; then
        cliphist wipe
        wl-copy -c
        notify-send -u critical -t 4000 "Clipboard Manager" "Clipboard has been wiped"
    else
		exit
	fi
elif [[ -n $choice ]]; then
    cliphist decode "$choice" | wl-copy
    wtype -M ctrl -M shift -P v -s 500 -p v -m shift -m ctrl
    notify-send -t 2000 "Clipboard Manager" "Copied to clipboard!"
else
    exit
fi
