{ pkgs, config, lib, ... }:

{
  home.packages = with pkgs; [
    hyprlock    # lock screen
    hypridle    # idle daemon (triggers lock, dim, suspend)
  ];

  # ── hyprlock config ──────────────────────────────────────────────────────────
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = false;
        hide_cursor = true;
        grace = 2;
      };

      background = [
        {
          monitor = "";
          path = "$HOME/wallpapers/default.jpg";
          blur_passes = 3;
          blur_size = 8;
          brightness = 0.6;
          noise = 0.01;
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "250, 50";
          outline_thickness = 2;
          dots_size = 0.33;
          dots_spacing = 0.15;
          outer_color = "rgb(89b4fa)";
          inner_color = "rgb(1e1e2e)";
          font_color = "rgb(cdd6f4)";
          fade_on_empty = true;
          placeholder_text = "<i>Password...</i>";
          hide_input = false;
          rounding = 12;
          check_color = "rgb(a6e3a1)";
          fail_color = "rgb(f38ba8)";
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          position = "0, -120";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        {
          monitor = "";
          text = "$TIME";
          font_size = 72;
          font_family = "JetBrainsMono Nerd Font";
          color = "rgba(cdd6f4ff)";
          position = "0, 300";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:3600000] date '+%A, %B %d'";
          font_size = 18;
          font_family = "Noto Sans";
          color = "rgba(cdd6f4cc)";
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  # ── hypridle config ──────────────────────────────────────────────────────────
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "hyprlock";
        before_sleep_cmd = "hyprlock";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
      };

      listener = [
        {
          timeout = 300;   # 5 min: dim screen
          on-timeout = "brightnessctl -s set 30%";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 600;   # 10 min: lock screen
          on-timeout = "hyprlock";
        }
        {
          timeout = 1800;  # 30 min: suspend
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
