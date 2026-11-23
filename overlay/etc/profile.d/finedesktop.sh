# on tty1, after login, start the desktop; a shell on any other tty stays a shell. Exit the desktop = back to the login.
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = /dev/tty1 ] && command -v finedesktop-session >/dev/null; then
    exec finedesktop-session
fi
