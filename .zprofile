if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
  # exec startx qtile
  exec startx xmonad
fi
