{ pkgs, config, lib, ... }:

# grim + slurp + swappy screenshot stack
# Keybinds are declared in hyprland.nix.
# This module just installs the packages and configures swappy.

{
  home.packages = with pkgs; [
    grim      # Wayland screenshot compositor
    slurp     # interactive region/window selector
    swappy    # screenshot annotation and edit tool
  ];

  # ── swappy config ─────────────────────────────────────────────────────────────
  home.file.".config/swappy/config".text = ''
    [Default]
    save_dir=$HOME/Pictures/Screenshots
    save_filename_format=swappy-%Y%m%d-%H%M%S.png
    show_panel=true
    line_size=5
    text_size=20
    text_font=JetBrainsMono Nerd Font
    paint_mode=brush
    early_exit=false
    fill_shape=false
  '';

  # Make sure screenshot directory exists
  home.activation.mkScreenshotDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/Pictures/Screenshots
  '';
}
