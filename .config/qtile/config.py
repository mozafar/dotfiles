# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from libqtile.widget import backlight
from typing import List
from Xlib import display as xdisplay
from libqtile import hook
import os
import subprocess

mod = "mod4"
terminal = guess_terminal()

## LAYOUT VARIABLES ##
bwidth=2
bcnormal='#282828'
bcfocused='#ff5c57'
margin=10
mono_font='Roboto Mono for Powerline'

## BAR COLORS ##
bar_colors = {
    "black":  "#282828",      # black
    "red":    "#cc241d",      # red
    "green":  "#98971a",      # green
    "yellow": "#d79921",      # yellow
    "blue":   "#458588",      # blue
    "magenta":"#b16286",      # magenta
    "cyan":   "#689d6a",      # cyan
    "gray":   "#a89984",      # gray
    "orange": "#d65d0e",      # orange
    "white":  "#ebdbb2"       # white
}

dark_colors = [
    "#282828",
    "#3c3836",
    "#504945",
    "#665c54",
    "#7c6f64"
]

light_colors = [
    "#a89984",
    "#bdae93",
    "#d5c4a1",
    "#ebdbb2",
    "#fbf1c7"
]

keys = [

    # Change the volume if your keyboard has special volume keys.
    Key(
        [], "XF86AudioRaiseVolume",
        lazy.spawn("amixer -c 0 -q set Master 2dB+")
    ),
    Key(
        [], "XF86AudioLowerVolume",
        lazy.spawn("amixer -c 0 -q set Master 2dB-")
    ),
    Key(
        [], "XF86AudioMute",
        lazy.spawn("amixer -c 0 -q set Master toggle")
    ),

    # Also allow changing volume the old fashioned way.
    Key([mod], "equal", lazy.spawn("amixer -c 0 -q set Master 2dB+")),
    Key([mod], "minus", lazy.spawn("amixer -c 0 -q set Master 2dB-")),

    Key([], "XF86MonBrightnessUp", lazy.widget['backlight'].change_backlight(backlight.ChangeDirection.UP)),
    Key([], "XF86MonBrightnessDown", lazy.widget['backlight'].change_backlight(backlight.ChangeDirection.DOWN)),

    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(),
        desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(),
        desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(),
        desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(),
        desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(),
        desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(),
        desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(),
        desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack"),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),

    Key([mod, "control", "shift"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "control"], "Escape", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod, "control", "shift"], "Escape", lazy.spawn("shutdown now"), desc="Shutdown System"),
    Key([mod, "control", "shift"], "x", lazy.spawn("blurlock"), desc="Lock"),
    Key([mod], "r", lazy.spawncmd(),
        desc="Spawn a command using a prompt widget"),
    Key([mod], "d", lazy.spawn("dmenu_recency"), desc="Launch Dmenu"),
    Key([], "Caps_Lock", lazy.widget["keyboardlayout"].next_keyboard(), desc="Next keyboard layout."),
]

def init_group_names():
    return [
        {"name": "1", "label": "", 'layout': 'bsp'},        #TERM  
        {"name": "2", "label": "", 'layout': 'xmonadtall'}, #WEB
        {"name": "3", "label": "﬏", 'layout': 'xmonadtall'}, #DEV
        {"name": "4", "label": "", 'layout': 'max'},        #DOC
        {"name": "5", "label": "", 'layout': 'floating'},   #MUS
        {"name": "6", "label": "", 'layout': 'max'},        #GFX
        {"name": "7", "label": "", 'layout': 'xmonadtall'}, #VID
        {"name": "8", "label": "", 'layout': 'treetab'},    #SYS
        {"name": "9", "label": "", 'layout': 'bsp'},        #CHAT
        {"name": "0", "label": "", 'layout': 'max'},        #RDP
    ]

def init_groups():
    return [Group(**group) for group in group_names]

# if __name__ in ["config", "__main__"]:
group_names = init_group_names()
groups = init_groups()

for group in group_names:
    name = group["name"]
    keys.extend([
        Key([mod], name, lazy.group[name].toscreen()),
        Key([mod, "shift"], name, lazy.window.togroup(name, switch_group=True)),
        Key([mod, "control", "shift"], name, lazy.window.togroup(name, switch_group=False)),
    ])

layouts = [
    layout.Max(),
    layout.MonadTall(
        name='xmonadtall',
        border_width=bwidth,
        border_normal=bcnormal,
        border_focus=bcfocused,
        ratio=0.5,
        margin=margin
    ),
    layout.MonadWide(
        name='xmonadwide',
        border_width=bwidth,
        border_normal=bcnormal,
        border_focus=bcfocused,
        ratio=0.5,
        margin=margin
    ),
    layout.Bsp(
        name='bsp',
        border_width=bwidth,
        border_normal=bcnormal, 
        border_focus=bcfocused, 
        fair=False,
        margin=margin
    ),
    layout.Floating(
        name='floating',
        border_width=bwidth,
        border_normal=bcnormal, 
        border_focus=bcfocused,
        max_border_width=bwidth
    ),
    layout.Zoomy(

        margin=17
    ),
    #TODO Customise this as much as posible, for it might end up being a very useful layout
    layout.TreeTab(
        name='treetab',
        sections=["First", "Second", "Third"],
        border_normal=bcnormal,
        border_focus=bcfocused,
        margin_y=margin,
        margin_left=margin,
        padding_x=0,
        padding_y=10,
        panel_width=160,
        font=mono_font,
        fontsize=10
    )
    # layout.Stack(num_stacks=2)
]

## BAR DEFAULTS ##
widget_defaults = dict(
    font='Roboto Mono for Powerline',
    # font='droid sans',
    # font='ubuntu',
    fontsize=13,
    padding=3,
)
extension_defaults = widget_defaults.copy()

def ChevronSpacer(background, foreground):
        return widget.TextBox(
            text='',
            background = background,
            foreground = foreground,
            padding=-15,
            fontsize=75
        )

def defaultWidgets():
    return [
        widget.CurrentLayoutIcon(
            foreground=light_colors[0],
            background=dark_colors[0]
        ),
        widget.GroupBox(
            foreground=light_colors[4],
            background=dark_colors[0],
            highlight_method="block",
            highlight_color=light_colors[4],
            block_highlight_text_color=light_colors[4],
            active=light_colors[4],
            inactive=light_colors[0],
            this_current_screen_border=bar_colors['blue'],
            this_screen_border=bar_colors['orange'],
            other_current_screen_border=bar_colors['magenta'],
            other_screen_border=bar_colors['yellow'],
            rounded=False,
            fontsize=28
        ),

        ## WINDOW NAME ##
        widget.TaskList(
             border=light_colors[0],
             margin=1,
             padding=2,
             rounded=False,
             max_title_width=250,
             spacing=5,
             #foreground=bar_colors[1],
             background=dark_colors[0]
        ),
        widget.Spacer(
            foreground=bar_colors['black'],
            background=bar_colors['black']
        ),
        ChevronSpacer(bar_colors['black'], bar_colors['green']),
        widget.TextBox(
            text='',
            fontsize=28,
            background = bar_colors['green'],
            foreground = bar_colors['black'],
        ),
        widget.CPU(
            format='{load_percent:0>2.0f}%',
            background = bar_colors['green'],
            foreground = bar_colors['black'],
      ),
        widget.TextBox(
            text='',
            background = bar_colors['green'],
            foreground = bar_colors['black'],
            fontsize=18
        ),
        widget.ThermalSensor(
            background = bar_colors['green'],
            foreground = bar_colors['black'],
        ),
        ChevronSpacer(bar_colors['green'], bar_colors['white']),
        widget.TextBox(
            text='',
            background = bar_colors['white'],
            foreground = bar_colors['black'],
            font="Hack",
            fontsize=28
        ),
        widget.Memory(
            format='{MemUsed}MB',
            background = bar_colors['white'],
            foreground = bar_colors['black'],
        ),
        #widget.Sep(
        #    linewidth=4,
        #    foreground=_colors[6],
        #    background=bar_colors[6],
        #    size_percent=100
        #),
        ChevronSpacer(bar_colors['white'], bar_colors['cyan']),
        widget.TextBox(
                text='',
                background = bar_colors['cyan'],
                foreground = bar_colors['black'],
                font="Hack",
                padding=0,
                fontsize=24
        ),
        widget.DF(
            background = bar_colors['cyan'],
            foreground = bar_colors['black'],
            visible_on_warn=False
        ),
        ChevronSpacer(bar_colors['cyan'], bar_colors['magenta']),
        widget.TextBox(
                text='盛',
                background = bar_colors['magenta'],
                foreground = bar_colors['white'],
                fontsize=28
        ),
        widget.Backlight(
            foreground=bar_colors['white'],
            background=bar_colors['magenta'],
            backlight_name='acpi_video0',
            change_command='brightnessctl s {0} --device=acpi_video0',
            step=1
        ),
        ChevronSpacer(bar_colors['magenta'], bar_colors['yellow']),
        widget.Volume(
            # fmt="🔊 V{}",
            emoji=True,
            foreground=bar_colors['black'],
            background=bar_colors['yellow'],
            fontsize=16
        ),
        widget.Volume(
            # fmt="🔊 V{}",
            # emoji=True,
            foreground=bar_colors['black'],
            background=bar_colors['yellow'],
        ),
        ChevronSpacer(bar_colors['yellow'], bar_colors['blue']),
        #widget.TextBox(
        #    text='',
        #    foreground=bar_colors['white'],
        #    background=bar_colors['blue'],
        #    fontsize=28
        #),
        widget.Wlan2(
            interface='wlp3s0',
            show_glyph=True,
            disconnected_message='',
            foreground=bar_colors['white'],
            background=bar_colors['blue'],
            fontsize=24
        ),
        widget.Wlan2(
            interface='wlp3s0',
            show_glyph=False,
            disconnected_message='Dis',
            foreground=bar_colors['white'],
            background=bar_colors['blue']
        ),
       ChevronSpacer(bar_colors['blue'], bar_colors['orange']),
        widget.Clock(
            foreground=bar_colors['black'],
            background=bar_colors['orange'],
            format='%d/%m/%y [%H:%M]'
        ),
        ChevronSpacer(bar_colors['orange'], bar_colors['black']),
        widget.KeyboardLayout(
            foreground=bar_colors['white'],
            background=bar_colors['black'],
            configured_keyboards=['us', 'ir']
        ),
        widget.Sep(
            linewidth=4,
            foreground=bar_colors['black'],
            background=bar_colors['black'],
            size_percent=100
        ),
        widget.Wallpaper(
            label='',
            random_selection=True,
            directory='/usr/share/backgrounds',
            wallpaper_command=None,
            option='stretch'
        ),
        widget.Systray(
            foreground=bar_colors['black'],
            background=bar_colors['black'],
        ),
        widget.Sep(
            linewidth=4,
            foreground=bar_colors['black'],
            background=bar_colors['black'],
            size_percent=100
        ),
    ]

def get_num_monitors():
    num_monitors = 0
    try:
        display = xdisplay.Display()
        screen = display.screen()
        resources = screen.root.xrandr_get_screen_resources()

        for output in resources.outputs:
            monitor = display.xrandr_get_output_info(output, resources.config_timestamp)
            preferred = False
            if hasattr(monitor, "preferred"):
                preferred = monitor.preferred
            elif hasattr(monitor, "num_preferred"):
                preferred = monitor.num_preferred
            if preferred:
                num_monitors += 1
    except Exception as e:
        # always setup at least one monitor
        return 1
    else:
        return num_monitors

num_monitors = get_num_monitors()
default_widgets = defaultWidgets()

screens = [
    Screen(
        top=bar.Bar(
            default_widgets,
            24,
        ),
    ),
]

if num_monitors > 1:
    for m in range(num_monitors - 1):
        screens.append(
            Screen(
                top=bar.Bar(
                    default_widgets,
                    24,
                ),
            ),
        )

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None  # WARNING: this is deprecated and will be removed soon
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(float_rules=[
    # Run the utility of `xprop` to see the wm class and name of an X client.
    *layout.Floating.default_float_rules,
    Match(wm_class='confirmreset'),  # gitk
    Match(wm_class='makebranch'),  # gitk
    Match(wm_class='maketag'),  # gitk
    Match(wm_class='ssh-askpass'),  # ssh-askpass
    Match(title='alsamixer'),
    Match(wm_class='skype'),
    Match(title='branchdialog'),  # gitk
    Match(title='pinentry'),  # GPG key password entry
    Match(title='File Transfer*'),  # GPG key password entry
])
auto_fullscreen = True
focus_on_window_activation = "smart"


# Hooks

# ASSIGN APPLICATIONS TO A SPECIFIC GROUPNAME
# BEGIN

#########################################################
################ assgin apps to groups ##################
#########################################################
# @hook.subscribe.client_new
# def assign_app_group(client):
#     d = {}
#     #####################################################################################
#     ### Use xprop fo find  the value of WM_CLASS(STRING) -> First field is sufficient ###
#     #####################################################################################
#     d[group_names[0]] = ["Navigator", "Firefox", "Vivaldi-stable", "Vivaldi-snapshot", "Chromium", "Google-chrome", "Brave", "Brave-browser",
#               "navigator", "firefox", "vivaldi-stable", "vivaldi-snapshot", "chromium", "google-chrome", "brave", "brave-browser", ]
#     d[group_names[1]] = [ "Atom", "Subl", "Geany", "Brackets", "Code-oss", "Code", "TelegramDesktop", "Discord",
#                "atom", "subl", "geany", "brackets", "code-oss", "code", "telegramDesktop", "discord", ]
#     d[group_names[2]] = ["Inkscape", "Nomacs", "Ristretto", "Nitrogen", "Feh",
#               "inkscape", "nomacs", "ristretto", "nitrogen", "feh", ]
#     d[group_names[3]] = ["Gimp", "gimp" ]
#     d[group_names[4]] = ["Meld", "meld", "org.gnome.meld" "org.gnome.Meld" ]
#     d[group_names[5]] = ["Vlc","vlc", "Mpv", "mpv" ]
#     d[group_names[6]] = ["VirtualBox Manager", "VirtualBox Machine", "Vmplayer",
#               "virtualbox manager", "virtualbox machine", "vmplayer", ]
#     d[group_names[7]] = ["Thunar", "Nemo", "Caja", "Nautilus", "org.gnome.Nautilus", "Pcmanfm", "Pcmanfm-qt",
#               "thunar", "nemo", "caja", "nautilus", "org.gnome.nautilus", "pcmanfm", "pcmanfm-qt", ]
#     d[group_names[8]] = ["Evolution", "Geary", "Mail", "Thunderbird",
#               "evolution", "geary", "mail", "thunderbird" ]
#     d[group_names[9]] = ["Spotify", "Pragha", "Clementine", "Deadbeef", "Audacious",
#               "spotify", "pragha", "clementine", "deadbeef", "audacious" ]
#     ######################################################################################
#
# wm_class = client.window.get_wm_class()[0]
#
#     for i in range(len(d)):
#         if wm_class in list(d.values())[i]:
#             group = list(d.keys())[i]
#             client.togroup(group)
#             client.group.cmd_toscreen(toggle=False)

# END
# ASSIGN APPLICATIONS TO A SPECIFIC GROUPNAME

cwd = os.path.expanduser('~/.config/qtile/')

@hook.subscribe.startup_once
def startup_once():
    subprocess.call([cwd + 'autostart.sh'])
    # subprocess.call([cwd + 'monitor_setup.sh'])

@hook.subscribe.screen_change
def screen_change(qtile, ev):
    # subprocess.call([cwd + 'monitor_setup.sh'])
    qtile.cmd_restart()

# @hook.subscribe.startup_once
# def autostart():
#     home = os.path.expanduser('~/.config/qtile/autostart.sh')
#     subprocess.call([home])

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
