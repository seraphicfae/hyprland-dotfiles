#!/usr/bin/env bash

## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x
#
## Rofi   : Launcher (Modi Drun, Run, File Browser)
#
## Available Styles
#
## style-1

dir="$HOME/.config/rofi/launcher"
theme='launcher-style-1'

## Run
rofi \
    -show drun \
    -theme ${dir}/${theme}.rasi