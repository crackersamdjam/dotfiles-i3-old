#!/bin/bash
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

DEFAULT_SESSION='i3 --shmlog-size 0'

# merge in defaults and keymaps
if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi
if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi
if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi
if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# Ensure that GTK themes are applied uniformly in the Desktop Environment
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"

# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

eval $(/usr/bin/gnome-keyring-daemon --start)
export SSH_AUTH_SOCK

# Set scaling
# https://ricostacruz.com/til/fractional-scaling-on-xorg-linux
export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_AUTO_SCREEN_SET_FACTOR=0
export QT_SCALE_FACTOR=2
export QT_FONT_DPI=96

# https://wiki.archlinux.org/index.php/IBus#Other_desktop_environments
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS="@im=ibus"
# https://programmersought.com/article/24415201436/
#export GTK_IM_MODULE=fcitx
#export QT_IM_MODULE=fcitx
#export XMODIFIERS="@im=fcitx"


get_session(){
	local dbus_args=(--sh-syntax --exit-with-session)
	case $1 in
		awesome) dbus_args+=(awesome) ;;
		bspwm) dbus_args+=(bspwm-session) ;;
		budgie) dbus_args+=(budgie-desktop) ;;
		cinnamon) dbus_args+=(cinnamon-session) ;;
		deepin) dbus_args+=(startdde) ;;
		enlightenment) dbus_args+=(enlightenment_start) ;;
		fluxbox) dbus_args+=(startfluxbox) ;;
		gnome) dbus_args+=(gnome-session) ;;
		i3|i3wm) dbus_args+=(i3 --shmlog-size 0) ;;
		jwm) dbus_args+=(jwm) ;;
		kde) dbus_args+=(startplasma-x11) ;;
		lxde) dbus_args+=(startlxde) ;;
		lxqt) dbus_args+=(lxqt-session) ;;
		mate) dbus_args+=(mate-session) ;;
		xfce) dbus_args+=(xfce4-session) ;;
		openbox) dbus_args+=(openbox-session) ;;
		*) dbus_args+=($DEFAULT_SESSION) ;;
	esac

	echo "dbus-launch ${dbus_args[*]}"
}

# https://github.com/Askannz/optimus-manager/wiki/FAQ,-common-issues,-troubleshooting#i-do-not-use-a-display-manager-i-use-startx-or-xinit
# https://github.com/Askannz/optimus-manager/issues/205#issuecomment-627364593
#/usr/bin/prime-offload
# to switch, run script 'switch'

# THESE ARE NEEDED FOR OPTIMUS TO FIND THE DISPLAY!
#xrandr --setprovideroutputsource modesetting NVIDIA-0
#xrandr --auto
#xrandr -q > test.txt
intern=eDP-1-1
extern0=DP-0
extern1=DP-1
if xrandr | grep "$extern0 connected"; then
    xrandr --output $intern --off --output $extern0 --auto --output $extern1 --off
    echo "Switched to external display 0" > info/display.txt
elif xrandr | grep "$extern1 connected"; then
    xrandr --output $intern --off --output $extern0 --off --output $extern1 --auto
    echo "Switched to external display 1" > info/display.txt
else
    xrandr --output $intern --auto --output $extern0 --off --output $extern1 --off
    echo "Switched to internal display" > info/display.txt
fi

exec $(get_session "$1")
