{ pkgs, config, lib, ... }:

# Wallpaper-driven theming:
#   swww     — displays wallpaper with smooth transitions
#   matugen  — Material You colors from wallpaper → writes ~/.config/matugen/colors.json
#   pywal    — wal color templates for apps matugen doesn't cover
#   wlsunset — blue-light filter (configured in hyprland.nix exec-once)
#
# Usage:  wallpaper ~/Pictures/my-photo.jpg
# That alias calls swww + matugen + pywal in sequence.

{
  home.packages = with pkgs; [
    awww        # wallpaper daemon (pkg renamed from swww; binary still swww) with animated transitions
    matugen     # Material You color generator
    pywal       # wal color templates
    wlsunset    # blue-light filter / color temperature
    imagemagick # thumbnail generation, used by pywal for color extraction
  ];

  # ── wallpaper helper script ──────────────────────────────────────────────────
  # Call with:  wallpaper /path/to/image.jpg
  home.file.".local/bin/wallpaper" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      IMG="$(realpath "$1")"

      # 1. Set wallpaper with animated transition (swww or awww)
      swww img "$IMG" \
        --transition-type grow \
        --transition-pos 0.5,0.5 \
        --transition-duration 1.2

      # 2. Generate Material You palette and write templates
      matugen image "$IMG"

      # 3. Generate pywal palette (for foot, other apps)
      wal --backend imagemagick -i "$IMG" -n --saturate 0.7

      # 4. Tell k4's HyprTheme plugin about the new wallpaper so it tracks it
      #    and can re-apply on next login. Silently skip if k4 isn't running.
      qs ipc call k4.theme wallpaper "$IMG" 2>/dev/null || true

      echo "Theme applied: $IMG"
    '';
  };

  # ── matugen config ───────────────────────────────────────────────────────────
  home.file.".config/matugen/config.toml".text = ''
    [config]
    reload_apps = true

    [config.reload_apps_list]
    # matugen reloads gtk settings on color change
    gtk_theme = true
  '';

  # ── Auto light/dark by time ──────────────────────────────────────────────────
  # Systemd user timer: switches matugen mode at 07:00 (light) / 19:00 (dark).
  # The wallpaper stays the same; only the palette changes.

  systemd.user.services = {
    theme-light = {
      Unit.Description = "Switch to light color scheme";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.matugen}/bin/matugen image %h/.cache/wal/wal --mode light";
      };
    };
    theme-dark = {
      Unit.Description = "Switch to dark color scheme";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.matugen}/bin/matugen image %h/.cache/wal/wal --mode dark";
      };
    };
  };

  systemd.user.timers = {
    theme-light = {
      Unit.Description = "Switch to light theme at 07:00";
      Timer = {
        OnCalendar = "*-*-* 07:00:00";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
    theme-dark = {
      Unit.Description = "Switch to dark theme at 19:00";
      Timer = {
        OnCalendar = "*-*-* 19:00:00";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };

  # ── Default wallpaper (placeholder — symlink at activation) ──────────────────
  # Place your actual wallpaper at Sicily-dots/wallpapers/default.jpg
  home.activation.linkDefaultWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/wallpapers
    if [ ! -f $HOME/wallpapers/default.jpg ]; then
      # Copy placeholder from dots repo; replace with your own image
      run cp ${../wallpapers/default.jpg} $HOME/wallpapers/default.jpg 2>/dev/null || true
    fi
  '';
}
