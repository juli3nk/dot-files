# Screen sharing on Wayland

For desktop audio and video management, they decided to introduce a new multimedia framework called PipeWire (links to the archlinux documentation, the website is pipewire.org). This framework differs in using a PolKit-like security model asking Wayland for permission to record screen or audio instead of relying on user groups (audio and video).

Pipewire will become the new way to communicate with the desktop applications, at least on linux systems. In Chromium, you can enable it using the enable-webrtc-pipewire-capturer flag (in chrome://flags). On firefox today you need this patch, available as fedora-firefox-wayland-bin in the AUR.

Now this pipewire needs some additional packages to support pulseaudio (pipewire-pulse) or say wlroots-based window manager like sway. For this to work, you need “portals” using xdg-desktop-portal with a “backend”, which is one of:

    GTK backend xdg-desktop-portal-gtk
    KDE backend xdg-desktop-portal-kde
    Liri backend xdg-desktop-portal-liri
    wlroots xdg-desktop-portal-wlr

Now you can test these via this (webrtc test page)[https://mozilla.github.io/webrtc-landing/gum_test.html].

https://soyuka.me/make-screen-sharing-wayland-sway-work/
https://pwmt.org/projects/zathura/screenshots/
https://wiki.archlinux.org/title/PipeWire#WebRTC_screen_sharing
