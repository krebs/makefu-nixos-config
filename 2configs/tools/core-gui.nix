{ pkgs, ... }:

{
  nixpkgs.config.firefox = {
    enableAdobeFlash = true;
  };

  krebs.per-user.makefu.packages = with pkgs; [
    chromium
    clipit
    feh
    firefox
    keepassx
    pcmanfm
    skype
    mirage
    tightvnc
    gnome3.dconf
    vlc
    wireshark
    xdotool
    scrot
    
  ];
}