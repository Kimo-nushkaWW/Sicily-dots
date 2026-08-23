{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    nautilus                  # file manager
    glib                      # provides gio (needed by nautilus for MTP, trash)
    gnome-disk-utility        # optional: disk management GUI
    file-roller               # archive manager (nautilus integration)
    xdg-utils                 # xdg-open default handlers
  ];

  # ── XDG default application for directories ──────────────────────────────────
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "org.gnome.Nautilus.desktop";
      "application/x-gnome-saved-search" = "org.gnome.Nautilus.desktop";
    };
  };

  # ── GTK theme (updated by matugen on wallpaper change) ───────────────────────
  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
    font = {
      package = pkgs.noto-fonts;
      name = "Noto Sans";
      size = 11;
    };
  };

  # Point QT apps to use the GTK theme so the whole desktop looks consistent
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };
}
