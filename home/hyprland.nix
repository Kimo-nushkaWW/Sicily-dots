{ pkgs, config, lib, ... }:

# Hyprland configuration
# Monitor names are placeholders — adjust to your actual outputs.
# Run `hyprctl monitors` to list them after first boot.

{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    configType = "hyprlang";   # silence stateVersion warning; we use hyprlang format

    settings = {
      # ── Monitors ───────────────────────────────────────────────────────────
      # Format: name, resolution@refresh, position, scale
      # Adjust these for your actual monitors.
      monitor = [
        "DP-2,1920x1080@239,0x0,1"
        "DVI-D-1,1920x1080@60,1920x0,1"
      ];

      # ── General ────────────────────────────────────────────────────────────
      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "rgba(89b4faff) rgba(cba6f7ff) 45deg";
        "col.inactive_border" = "rgba(313244ff)";
        resize_on_border = true;
        layout = "dwindle";
      };

      # ── Decoration ─────────────────────────────────────────────────────────
      decoration = {
        rounding = 12;
        blur = {
          enabled = true;
          size = 8;
          passes = 2;
          new_optimizations = true;
          xray = false;
        };
        drop_shadow = true;
        shadow_range = 20;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a2eee)";
      };

      # ── Animations ─────────────────────────────────────────────────────────
      animations = {
        enabled = true;
        bezier = [
          "ease,0.25,0.1,0.25,1"
          "overshoot,0.05,0.9,0.1,1.1"
          "bounce,0.3,1.4,0.3,1"
        ];
        animation = [
          "windows,1,4,overshoot,slide"
          "windowsOut,1,3,ease,slide"
          "border,1,10,ease"
          "fade,1,4,ease"
          "workspaces,1,5,ease,slide"
        ];
      };

      # ── Input ──────────────────────────────────────────────────────────────
      input = {
        kb_layout = "us,ru";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
        sensitivity = 0;
      };

      # ── Dwindle layout ─────────────────────────────────────────────────────
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # ── Misc ───────────────────────────────────────────────────────────────
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        vfr = true;
      };

      # ── Keybinds ───────────────────────────────────────────────────────────
      "$mod" = "SUPER";

      bind = [
        # Apps
        "$mod, T, exec, foot"
        "$mod, E, exec, nautilus"
        "$mod, F, togglefloating"
        "$mod, Q, killactive"
        "$mod, M, exit"
        # NOTE: $mod+Space → k4 launcher  (conf.d/k4.conf)
        # NOTE: $mod+L     → k4 lock      (conf.d/k4.conf)

        # Window focus
        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"

        # Window move
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, L, movewindow, r"

        # Workspaces 1-9
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # Move window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"

        # Screenshot
        "$mod SHIFT, S, exec, grim -g \"$(slurp)\" - | swappy -f -"
        "$mod, Print, exec, grim - | swappy -f -"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Media keys
      bindel = [
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86MonBrightnessUp, exec, brightnessctl s 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
      ];

      bindl = [
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # ── Startup ────────────────────────────────────────────────────────────
      exec-once = [
        "swww-daemon"
        # Only load wallpaper if file exists and is non-empty (placeholder is empty)
        "bash -c 'f=$HOME/wallpapers/default.jpg; [ -s \"$f\" ] && swww img \"$f\" --transition-type grow'"
        "wlsunset -l 37.5 -L 15.1"   # Sicily coordinates — adjust as needed
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user start graphical-session.target"
      ];

      # ── Window rules ───────────────────────────────────────────────────────
      windowrulev2 = [
        "float, class:^(file-roller)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(nm-connection-editor)$"
        "float, title:^(Picture-in-Picture)$"
        "float, class:^(swappy)$"
        "size 900 600, class:^(swappy)$"
        "center, class:^(swappy)$"
      ];
    };

    # Import per-app conf.d snippets (k4 writes its own here)
    extraConfig = ''
      source = $HOME/.config/hypr/conf.d/*.conf
    '';
  };
}
