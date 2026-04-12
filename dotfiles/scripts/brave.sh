#!/bin/bash
export GTK_IM_MODULE=xim
export XMODIFIERS="@im=none"
export QT_IM_MODULE=xim
exec brave-browser "$@" &
