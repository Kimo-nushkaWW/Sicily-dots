{ pkgs, config, lib, ... }:

{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Nerd Fonts (icon-patched developer fonts)
    nerd-fonts.jetbrains-mono  # primary coding font
    nerd-fonts.fira-code        # alternative with great ligatures
    nerd-fonts.meslo-lg         # "MesloLGS Nerd Font Mono" — k4's iconFont

    # k4 UI font — k4/core/Theme.qml hardcodes "Adwaita Sans"
    adwaita-fonts

    # CJK (Chinese, Japanese, Korean) support
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji

    # UI fonts
    inter                # clean sans-serif for GTK
    roboto               # fallback sans

    # Icon fonts used by some apps
    font-awesome
  ];
}
