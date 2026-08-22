{ pkgs, config, lib, ... }:

{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Nerd Fonts (icon-patched developer fonts)
    (nerdfonts.override { fonts = [
      "JetBrainsMono"   # primary coding font
      "FiraCode"        # alternative with great ligatures
      "Meslo"           # popular terminal font
    ]; })

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
