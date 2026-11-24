{ pkgs, ... }:

{
  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

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

  # ── GTK defaults ─────────────────────────────────────────────────────────────
  # Do not import K4's wallpaper palette here.  GTK applications use the
  # normal Adwaita light/dark preference, while K4 keeps its own dynamic UI.
  gtk = {
    enable = true;
    # Current PC mode is light; this is deliberately independent of wallpaper
    # colours.  The wallpaper palette is still used by K4 and Foot only.
    colorScheme = "light";
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
    font = {
      package = pkgs.noto-fonts;
      name = "Noto Sans";
      size = 11;
    };
  };

  # Let Qt follow the GTK system light/dark setting.  Do not force a colour
  # style: the wallpaper palette belongs to K4 only.
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };
}
