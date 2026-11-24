{ pkgs, ... }:

# Hyprland configuration.
# Run `hyprctl monitors` to list them after first boot.

{
  home.packages = [
    (pkgs.writeShellScriptBin "k4-comms-workspace" ''
      #!/bin/sh
      set -eu

      # In Lua mode `hyprctl dispatch` parses its argument as a Lua expression.
      # toggle_special intentionally uses whichever monitor is focused, so
      # SUPER+D opens the communication workspace where the key is pressed.
      hyprctl dispatch 'hl.dsp.workspace.toggle_special("comms")'

      if ! hyprctl clients -j | jq -e \
        'any(.[]; .class == "TelegramDesktop" or .initialClass == "TelegramDesktop" or .class == "org.telegram.desktop" or .initialClass == "org.telegram.desktop")' \
        >/dev/null 2>&1; then
        Telegram >/dev/null 2>&1 &
      fi

      if ! hyprctl clients -j | jq -e \
        'any(.[]; .class == "discord" or .initialClass == "discord")' \
        >/dev/null 2>&1; then
        Discord >/dev/null 2>&1 &
      fi
    '')
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    # Hyprland 0.57 removes the legacy .conf format.  Generate the current
    # native Lua configuration instead of relying on the old stateVersion
    # default.
    configType = "lua";

    # The Lua API is kept here as a single extraConfig block.  This avoids
    # asking Home Manager to reinterpret legacy comma-separated hyprlang
    # strings as Lua calls.
    extraConfig = ''
      -- Monitors
      hl.monitor({ output = "DP-2", mode = "1920x1080@239", position = "2560x180", scale = 1 })
      hl.monitor({ output = "DP-1", mode = "2560x1440@165", position = "0x0", scale = 1 })

      -- Look and feel
      hl.config({
        general = {
          gaps_in = 4,
          gaps_out = 8,
          border_size = 2,
          col = {
            active_border = { colors = { "rgba(89b4faff)", "rgba(cba6f7ff)" }, angle = 45 },
            inactive_border = "rgba(313244ff)",
          },
          resize_on_border = true,
          layout = "dwindle",
        },
        decoration = {
          rounding = 12,
          blur = { enabled = true, size = 8, passes = 2, new_optimizations = true, xray = false },
          shadow = { enabled = true, range = 20, render_power = 3, color = "rgba(1a1a2eee)" },
        },
        input = {
          kb_layout = "us,ru",
          kb_options = "grp:alt_shift_toggle",
          follow_mouse = 1,
          touchpad = { natural_scroll = true },
          sensitivity = -0.5,
        },
        dwindle = { preserve_split = true },
        misc = { force_default_wallpaper = 1, disable_hyprland_logo = true },
        animations = { enabled = true },
      })

      -- Animation curves and animations
      hl.curve("ease", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1 } } })
      hl.curve("overshoot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.1 } } })
      hl.curve("bounce", { type = "bezier", points = { { 0.3, 1.4 }, { 0.3, 1 } } })
      hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "overshoot", style = "slide" })
      hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "ease", style = "slide" })
      hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "ease" })
      hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "ease" })
      hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "ease", style = "slide" })

      -- Applications and window management
      local mod = "SUPER"
      hl.bind(mod .. " + T", hl.dsp.exec_cmd("foot"))
      hl.bind(mod .. " + E", hl.dsp.exec_cmd("nautilus"))
      hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
      hl.bind(mod .. " + D", hl.dsp.exec_cmd("k4-comms-workspace"))
      hl.bind(mod .. " + Q", hl.dsp.window.close())
      hl.bind(mod .. " + M", hl.dsp.exit())

      hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
      hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
      hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
      hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
      hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
      hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

      for i = 1, 9 do
        hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
        hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
      end

      hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
      hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

      -- Media keys
      hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"), { repeating = true, locked = true })
      hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"), { repeating = true, locked = true })
      hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"), { repeating = true, locked = true })
      hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 5%+"), { repeating = true, locked = true })
      hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { repeating = true, locked = true })
      hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
      hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
      hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

      -- Startup
      hl.on("hyprland.start", function()
        hl.exec_cmd("awww-daemon")
        hl.exec_cmd("$HOME/.local/bin/wallpaper")
        hl.exec_cmd("wlsunset -l 37.5 -L 15.1")
        hl.exec_cmd("zen-beta --name zen-beta")
        hl.exec_cmd("steam -silent")
        hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
        hl.exec_cmd("systemctl --user start graphical-session.target")
      end)

      -- Workspace
      hl.workspace_rule({ workspace = "1", monitor = "DP-1" })
      hl.workspace_rule({ workspace = "2", monitor = "DP-2" })
      hl.workspace_rule({ workspace = "3", monitor = "DP-1" })
      hl.workspace_rule({ workspace = "4", monitor = "DP-2" })
      hl.workspace_rule({ workspace = "5", monitor = "DP-1" })
      hl.workspace_rule({ workspace = "6", monitor = "DP-2" })
      hl.workspace_rule({ workspace = "7", monitor = "DP-1" })
      hl.workspace_rule({ workspace = "8", monitor = "DP-2" })
      hl.workspace_rule({ workspace = "9", monitor = "DP-1" })
      hl.workspace_rule({ workspace = "10", monitor = "DP-2" })


      -- Window rules
      hl.window_rule({ name = "zen-on-second-monitor", match = { class = "^(zen-beta)$" }, monitor = "DP-2" })
      hl.window_rule({ name = "telegram-comms", match = { class = "^(TelegramDesktop|org.telegram.desktop)$" }, workspace = "special:comms" })
      hl.window_rule({ name = "discord-comms", match = { class = "^(discord)$" }, workspace = "special:comms" })
      hl.window_rule({ name = "file-roller-float", match = { class = "^(file-roller)$" }, float = true })
      hl.window_rule({ name = "blueman-float", match = { class = "^(blueman-manager)$" }, float = true })
      hl.window_rule({ name = "network-editor-float", match = { class = "^(nm-connection-editor)$" }, float = true })
      hl.window_rule({ name = "pip-float", match = { title = "^(Picture-in-Picture)$" }, float = true })
    '';
  };
}
