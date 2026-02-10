# Force X11 everywhere (avoid hybrid paths)
export XDG_SESSION_TYPE=x11
export GDK_BACKEND=x11
export QT_QPA_PLATFORM=xcb

# Electron sanity
export ELECTRON_DISABLE_SECURITY_WARNINGS=true
export ELECTRON_NO_ASAR=1
export ELECTRON_TRASH=gio

# Discord-specific
export DISCORD_DISABLE_GPU=1
export DISCORD_DISABLE_CRASH_REPORTER=1
