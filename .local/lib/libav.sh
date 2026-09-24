
# Utilise driver Intel moderne (vs i965 ancien)
LIBVA_DRIVER_NAME=iHD

# Autorise processus RDD à accéder VA-API
# (LibreWolf a sandbox strict)
MOZ_DISABLE_RDD_SANDBOX=1

# Active pipeline EGL pour accélération
MOZ_X11_EGL=1

# Force X11 (VA-API plus stable sur X11)
MOZ_ENABLE_WAYLAND=0
