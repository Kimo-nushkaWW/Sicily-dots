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
        exec Hyprland
      end
    '';

    shellAliases = {
      # Wallpaper + theme change in one command
      wallpaper = "$HOME/.local/bin/wallpaper";

      # Nix shortcuts
      rebuild = "sudo nixos-rebuild switch --flake /home/kimo/Sicily-dots#sicily";
      hm-switch = "home-manager switch --flake /home/kimo/Sicily-dots#kimo@sicily";
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
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      format = lib: "$all";

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
}
