{ pkgs, config, lib, ... }:

# Wallpaper-driven theming:
#   awww     — displays wallpaper with smooth transitions
#   matugen  — Material You colors from wallpaper (not used for app theming)
#   pywal    — extracts ~/.cache/wal/colors.json for K4 and Foot
#   wlsunset — blue-light filter (configured in hyprland.nix exec-once)
#
# Usage:  wallpaper ~/Pictures/my-photo.jpg
# That alias calls awww + matugen + pywal in sequence, then refreshes the
# writable Foot include and notifies K4.  GTK/Qt keep their own system mode.

{
  home.packages = with pkgs; [
    awww        # wallpaper daemon and client
    matugen     # Material You color generator
    pywal       # wal color templates
    wlsunset    # blue-light filter / color temperature
    imagemagick # thumbnail generation, used by pywal for color extraction
  ];

  # ── wallpaper helper script ──────────────────────────────────────────────────
  # Call with:  wallpaper /path/to/image.jpg
  home.file.".local/bin/wallpaper" = {
    executable = true;
    text = ''#!/usr/bin/env bash
      set -euo pipefail
      if [ "$#" -gt 0 ]; then
        IMG="$(realpath "$1")"
      else
        IMG="$("${pkgs.python3}/bin/python3" - <<'PY'
import json
import os

for filename in ("~/.local/state/k4/hyprtheme.json", "~/.cache/wal/colors.json"):
    try:
        with open(os.path.expanduser(filename), encoding="utf-8") as handle:
            path = json.load(handle).get("wallpaper", "")
        if path and os.path.isfile(path):
            print(os.path.realpath(path))
            break
    except (OSError, ValueError, TypeError):
        pass
PY
        )"
        if [ -z "$IMG" ]; then
          for candidate in "$HOME"/wallpapers/* "$HOME"/Sicily-dots/wallpapers/*; do
            if [ -s "$candidate" ]; then
              IMG="$(realpath "$candidate")"
              break
            fi
          done
        fi
      fi
      [ -n "$IMG" ] || { echo "No wallpaper found" >&2; exit 1; }

      # 1. Set wallpaper with animated transition. Hyprland may start this
      # helper at the same time as awww-daemon, so allow the socket to appear.
      for attempt in $(seq 1 20); do
        if awww img "$IMG" \
          --transition-type grow \
          --transition-pos 0.5,0.5 \
          --transition-duration 1.2; then
          break
        fi
        [ "$attempt" -eq 20 ] && exit 1
        sleep 0.1
      done

      # 2. Generate Material You palette and write templates
      matugen image "$IMG"

      # 3. Generate the single palette source used by K4 and Foot.
      wal --backend imagemagick -i "$IMG" -n --saturate 0.7

      # 4. Foot is managed by Home Manager, so do not overwrite foot.ini.
      #    Foot supports an absolute/~/ include; this file is deliberately
      #    writable and is replaced atomically after every wallpaper change.
      "$HOME/.local/bin/k4-palette"

      # 5. Keep K4's persisted wallpaper in sync when the helper is called
      #    directly. The IPC handler only updates state; it does not call this
      #    helper again.
      for attempt in $(seq 1 50); do
        if quickshell ipc -p "$HOME/.config/quickshell/k4/shell.qml" \
          call k4.theme wallpaper "$IMG" >/dev/null 2>&1; then
          break
        fi
        sleep 0.1
      done

      echo "Theme applied: $IMG"
    '';
  };

  # Render the palette once and keep all generated files outside the Nix store.
  # K4 reads colors.json directly; Foot imports the generated fragment.
  home.file.".local/bin/k4-palette" = {
    executable = true;
    text = ''
      #!${pkgs.python3}/bin/python3
      import json
      import os
      import subprocess
      import sys
      import tempfile

      source = os.path.expanduser("~/.cache/wal/colors.json")
      target = os.path.expanduser("~/.local/state/k4/foot-colors.ini")

      with open(source, encoding="utf-8") as handle:
          data = json.load(handle)

      colors = data.get("colors", {})

      def color(name, fallback):
          value = str(colors.get(name, fallback)).lstrip("#")
          return value if len(value) == 6 else fallback

      def system_is_light():
          # GTK's preference is the system light/dark source.  Home Manager
          # activation may run without the user's D-Bus session, so never
          # silently replace a working palette with the dark default.
          try:
              result = subprocess.run(
                  ["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"],
                  check=False, capture_output=True, text=True,
              )
              if "prefer-light" in result.stdout:
                  return True
              if "prefer-dark" in result.stdout:
                  return False
          except OSError:
              pass

          for variable in ("GTK_THEME", "QT_STYLE_OVERRIDE"):
              value = os.environ.get(variable, "").lower()
              if "light" in value:
                  return True
              if "dark" in value:
                  return False

          # Preserve the last known mode when this is called by hrs/nrs
          # outside the graphical session.  This prevents a light terminal
          # from flashing to black merely because activation could not query
          # gsettings.
          try:
              with open(target, encoding="utf-8") as handle:
                  for line in handle:
                      if line.strip() == "initial-color-theme=light":
                          return True
                      if line.strip() == "initial-color-theme=dark":
                          return False
          except OSError:
              pass

          # First-run fallback matches home.nautilus.nix's current system
          # colorScheme = "light".  The next interactive palette refresh uses
          # gsettings and follows any later system-theme change.
          return True

      def rgb(value):
          return tuple(int(value[index:index + 2], 16) / 255 for index in (0, 2, 4))

      def luminance(value):
          channels = []
          for channel in rgb(value):
              channels.append(channel / 12.92 if channel <= 0.03928
                              else ((channel + 0.055) / 1.055) ** 2.4)
          return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]

      def contrast(first, second):
          one = luminance(first)
          two = luminance(second)
          return (max(one, two) + 0.05) / (min(one, two) + 0.05)

      light_theme = system_is_light()
      # The terminal base is deliberately independent from the wallpaper.
      # Wallpaper colours are used only as the accent/secondary palette.
      background = "ffffff" if light_theme else "000000"
      foreground = "111111" if light_theme else "ffffff"

      palette_candidates = [
          color(name, "808080")
          for name in ("color4", "color12", "color8", "color1", "color2", "color3",
                       "color5", "color6", "color9", "color10", "color11", "color13",
                       "color14")
      ]
      accent = max(palette_candidates, key=lambda value: contrast(value, background))
      # Keep the wallpaper accent useful for labels and fastfetch keys even
      # when the wallpaper produces a very pale (or very dark) ANSI palette.
      accent_fallback = "005f87" if light_theme else "7dd3fc"
      if contrast(accent, background) < 3:
          accent = accent_fallback
      foot_colors = [
          "alpha=1.0",
          "background=" + background,
          "foreground=" + foreground,
          # Foot's cursor value is "text-on-cursor cursor-background".
          # Invert the terminal pair so the cursor is visible in both modes.
          "cursor=" + background + " " + foreground,
      ]
      for prefix in ("regular", "bright"):
          offset = 0 if prefix == "regular" else 8
          for index in range(8):
              value = color(f"color{index + offset}", foreground)
              if index == 0:
                  value = background
              elif index == 2:
                  # Fastfetch's `green` and `bright_green` names use ANSI
                  # slots 2 and 10; make those names the wallpaper accent.
                  value = accent
              elif index == 4:
                  value = color(f"color{index + offset}", foreground)
              elif index == 7:
                  value = foreground
              foot_colors.append(f"{prefix}{index}=" + value)
      foot_colors.append("")

      foot_lines = [
          "[main]",
          "initial-color-theme=" + ("light" if light_theme else "dark"),
          "",
          "[colors-dark]",
      ] + foot_colors + [
          "[colors-light]",
      ] + foot_colors

      # Keep Hyprland's live border palette on the same source as K4 and Foot.
      # This is intentionally best-effort: home-manager activation can run
      # outside a graphical session, while `wallpaper` runs inside one.
      if os.environ.get("WAYLAND_DISPLAY"):
          hyprctl = "${pkgs.hyprland}/bin/hyprctl"
          inactive = color("color8", foreground)
          commands = [
              [hyprctl, "keyword", "general:col.active_border",
               "rgba(" + background + "ff) rgba(" + accent + "ff) 45deg"],
              [hyprctl, "keyword", "general:col.inactive_border",
               "rgba(" + inactive + "ff)"],
          ]
          for command in commands:
              subprocess.run(command, check=False, stdout=subprocess.DEVNULL,
                             stderr=subprocess.DEVNULL)

      # The wallpaper palette belongs to K4 and Foot only.  GTK/Qt must keep
      # their normal light/dark system theme instead of receiving these colors.
      targets = {target: "\n".join(foot_lines)}
      directory = os.path.dirname(target)
      os.makedirs(directory, exist_ok=True)
      for output, content in targets.items():
          output_directory = os.path.dirname(output)
          os.makedirs(output_directory, exist_ok=True)
          with tempfile.NamedTemporaryFile("w", encoding="utf-8",
                                           dir=output_directory,
                                           prefix=".k4-colors.", delete=False) as handle:
              handle.write(content)
              temporary = handle.name
          os.replace(temporary, output)

      # Reload the generated [colors-dark] section in existing Foot instances.
      # The section name is kept stable so SIGUSR1 works for both dark and
      # light system modes without deprecated [colors] warnings.
      signal = "-USR2" if light_theme else "-USR1"
      for process in ("foot", "footclient"):
          subprocess.run(["${pkgs.procps}/bin/pkill", signal, "-x", process], check=False,
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

      # Foot applies OSC color changes to the terminal that ran `wallpaper`.
      # New terminals use the include above; this keeps the current shell in
      # sync too, without pretending SIGUSR1 reloads foot.ini.
      if sys.stdout.isatty():
          def osc(code, value):
              sys.stdout.write(f"\\033]{code};{value}\\a")

          osc("10", "#" + foreground)
          osc("11", "#" + background)
          osc("12", "#" + foreground)
          for index in range(8):
              osc(f"4;{index}", "#" + color(f"color{index}", foreground))
              osc(f"4;{index + 8}", "#" + color(f"color{index + 8}", foreground))
          sys.stdout.flush()
    '';
  };

  # ── matugen config ───────────────────────────────────────────────────────────
  home.file.".config/matugen/config.toml".text = ''
    [config]
    # Matugen 4.x needs a deterministic source choice in non-interactive
    # sessions. Wallpaper ownership remains with the helper below.
    prefer = "darkness"

    [config.wallpaper]
    set = false
    command = "true"

    [templates]
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
}
