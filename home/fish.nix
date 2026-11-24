{ pkgs, config, ... }:

{
  programs.fish = {
    enable = true;

    shellInit = ''
      # pywal color integration: source the fish color script on shell start
      if test -f "$HOME/.cache/wal/colors.fish"
        source "$HOME/.cache/wal/colors.fish"
      end

      # Hyprland: start on tty1 login (no display manager)
      if status is-login
        and test (tty) = /dev/tty1
        and not set -q WAYLAND_DISPLAY
        exec start-hyprland -- -c "$HOME/.config/hypr/hyprland.lua"
      end
    '';

    shellAliases = {
      # Wallpaper + theme change in one command
      wallpaper = "$HOME/.local/bin/wallpaper";

      nix-clean = "sudo nix-collect-garbage -d";

      # Common
      ls = "ls --color=auto";
      ll = "ls -lah --color=auto";
      ".." = "cd ..";
      "..." = "cd ../..";
    };

    functions = {
      # Quick note: `take dir` creates and enters a directory
      take = {
        body = "mkdir -p $argv[1] && cd $argv[1]";
      };

      # Keep the terminal greeting in the flake instead of relying on the old
      # external Caelestia checkout. Fastfetch prints the PC summary beside
      # the raw ASCII logo configured in ~/.config/fastfetch.
      fish_greeting = {
        body = ''
          if command -q fastfetch
            env -u NO_COLOR fastfetch --config "$HOME/.config/fastfetch/config.jsonc"
          end
        '';
      };

      # A rebuild can replace Starship and Fish's generated prompt while this
      # shell is still alive.  Restart only Fish after a successful switch so
      # no prompt function keeps calling an old Nix store path.
      nrs = {
        body = ''
          sudo nixos-rebuild switch --flake /home/kimo/Sicily-dots#sicily $argv
          or return $status
          # Hyprland keeps its running configuration; reload it after the
          # rebuild so changes to home/hyprland.nix apply without rebooting.
          if set -q WAYLAND_DISPLAY; and command -q hyprctl
            hyprctl reload >/dev/null 2>&1; or true
          end
          exec fish
        '';
      };

      hrs = {
        body = ''
          nix run --no-update-lock-file /home/kimo/Sicily-dots#home-manager -- \
            switch --flake /home/kimo/Sicily-dots#kimo@sicily -b hm-backup $argv
          or return $status
          # Home Manager installs the new Hyprland config but does not
          # reload the compositor automatically.
          if set -q WAYLAND_DISPLAY; and command -q hyprctl
            hyprctl reload >/dev/null 2>&1; or true
          end
          exec fish
        '';
      };
    };
  };

  programs.starship = {
    enable = true;
    # Home Manager's generated integration embeds a store/profile path in the
    # Fish prompt.  That path can disappear after a rebuild while an existing
    # shell still holds the old function.  Initialise through PATH below.
    enableFishIntegration = false;

    settings = {
      format = "$all";

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      directory = {
        truncate_to_repo = true;
        style = "bold blue";
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
      };

      nix_shell = {
        symbol = "❄️ ";
        style = "bold cyan";
      };

      cmd_duration = {
        min_time = 2000;
        style = "bold yellow";
      };
    };
  };

  programs.fish.interactiveShellInit = ''
    if test "$TERM" != dumb
      if command -q starship
        starship init fish | source
      end
    end
  '';
}
