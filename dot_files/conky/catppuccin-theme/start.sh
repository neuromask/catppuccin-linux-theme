#!/bin/bash

killall conky
sleep 2s
		
conky -c $HOME/.config/conky/catppuccin-theme/config.conf &> /dev/null &
