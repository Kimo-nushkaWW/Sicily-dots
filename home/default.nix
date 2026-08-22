{ pkgs, config, lib, ... }:

{
  imports = [
    ./hyprland.nix
    ./k4.nix
    ./theme.nix
    ./foot.nix
    ./fish.nix
    ./vscodium.nix
    ./nautilus.nix
    ./hyprlock.nix
    ./screenshots.nix
    ./fonts.nix
    ./dev.nix
  ];

  home = {
    username = "kimo";
    homeDirectory = "/home/kimo";
    stateVersion = "25.05";
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # XDG base dirs
  xdg.enable = true;

  # Global env vars visible to all Wayland apps
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";          # electron/chromium Wayland
    MOZ_ENABLE_WAYLAND = "1";      # firefox
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    GTK_THEME = "adw-gtk3-dark";   # updated by matugen on wallpaper change
  };
}
