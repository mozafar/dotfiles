Config { font = "xft:JetBrainsMono Nerd Font Mono:size=10:bold:antialias=true"
       , additionalFonts = [ 
              "xft:JetBrainsMono Nerd Font Mono:size=20:medium:antialias=true"
       ]
       , bgColor = "#282828"
       , fgColor = "#ebdbb2"
       , position = Top
       , lowerOnStart = True
       , allDesktops = True
       , commands = [  Run Alsa "default" "Master" [
                            "-t","<action=`amixer set Master toggle` button=1><action=`amixer set Master 5%+ unmute` button=4><action=`amixer set Master 5%- unmute` button=5><fc=#83a598><status> <volume>%</fc></action></action></action>",
                            "--",
                            "--on", "<fn=1>墳</fn>",
                            "--off", "<fn=1>婢</fn>",
                            "--onc", "#83a598",
                            "--offc", "#fb4934"
                     ]
                     , Run Brightness [
                            "-t", "<action=`brightnessctl set +10% --device=acpi_video0` button=4><action=`brightnessctl set 10%- --device=acpi_video0` button=5><fc=#fabd2f><fn=1>盛</fn> <percent></fc></action></action>"
                     ] 10
                     , Run Wireless "wlp3s0" [
                            "-t", "<fc=#d3869b><fn=1>直</fn> <ssid></fc>" 
                     ] 10
                     , Run Cpu [
                            "-L","3",
                            "-H","50",
                            "--normal","#8ec07c",
                            "--high","#fb4934",
                            "-t", "<fc=#8ec07c><fn=1></fn> <total>%</fc>"
                     ] 10
                     , Run CoreTemp [
                            "-L", "40", "-H", "70",
                            "-l", "#83a598", "-n", "#8ec07c", "-h", "#fb4934",
                            "-t", "<fc=#8ec07c><fn=1></fn> <core0>°C</fc>"
                     ] 50
                    , Run Memory [
                            "-t","<fc=#98971a><fn=1></fn> <usedratio>%</fc>"
                     ] 10
                    , Run Date "<fc=#fe8019><fn=1></fn> %a %Y-%m-%d %H:%M</fc>" "date" 10
                    , Run Kbd [
                            ("us","US"),
                            ("ir","IR")
                     ]
                    , Run UnsafeStdinReader
                    -- , Run Com "/home/mozi/.config/xmobar/trayer-padding-icon.sh" [] "trayerpad" 10
                    , Run DiskU [("/", "<fc=#d79921><fn=1></fn> <usedp>%</fc>")]
                            ["-L", "10", "-H", "70", "-l", "#d79921", "-h", "#fb4934"] 20
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%UnsafeStdinReader% }{  %cpu% %coretemp% | %memory% | %disku% | %wlp3s0wi% | %alsa:default:Master% | %bright% | %date% | %kbd% "
       }

