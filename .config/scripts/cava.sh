#!/bin/bash

cava -p ~/.config/cava/config-waybar | awk -F';' '{
        bars = ""
        for (i = 1; i <= NF; i++) {
            if ($i == 0) bars = bars "▁"
            else if ($i == 1) bars = bars "▂"
            else if ($i == 2) bars = bars "▃"
            else if ($i == 3) bars = bars "▄"
            else if ($i == 4) bars = bars "▅"
            else if ($i == 5) bars = bars "▆"
            else if ($i == 6) bars = bars "▇"
            else if ($i == 7) bars = bars "█"
            else bars = bars " "
        }
        print bars
        fflush()
    }'
fi