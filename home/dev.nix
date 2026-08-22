{ pkgs, config, lib, ... }:

{
  # ── Git ──────────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    userName = "kimo";                        # change to your name
    userEmail = "you@example.com";            # change to your email

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      merge.conflictstyle = "zdiff3";
      core.editor = "codium --wait";
    };

    # delta: pretty git diffs
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        line-numbers = true;
        side-by-side = false;
        syntax-theme = "Monokai Extended";
      };
    };

    aliases = {
      st = "status -sb";
      lg = "log --oneline --graph --decorate --all";
      co = "checkout";
      br = "branch";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
    };
  };

  # ── SSH ──────────────────────────────────────────────────────────────────────
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    serverAliveInterval = 60;
    hashKnownHosts = true;

    matchBlocks = {
      "*" = {
        # Default identity — place your key at ~/.ssh/id_ed25519
        identityFile = "~/.ssh/id_ed25519";
      };
      # Add host-specific blocks below, e.g.:
      # "github.com" = {
      #   user = "git";
      #   identityFile = "~/.ssh/github_ed25519";
      # };
    };
  };

  # ── GPG ──────────────────────────────────────────────────────────────────────
  programs.gpg = {
    enable = true;
    settings = {
      default-key = "";        # set to your key fingerprint after import
      auto-key-retrieve = true;
      no-symkey-cache = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
    defaultCacheTtl = 3600;
    maxCacheTtl = 86400;
  };

  # ── Extra dev tools ───────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    delta          # git diff pager
    gh             # GitHub CLI
    jq             # JSON processor
    ripgrep        # fast grep (rg)
    fd             # fast find
    bat            # cat with syntax highlighting
    eza            # modern ls replacement
    htop           # process monitor
    ncdu           # disk usage analyzer
    unzip zip      # archive tools
  ];

  # ── eza aliases (replaces ls in fish) ────────────────────────────────────────
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git = true;
    icons = "auto";
  };
}
