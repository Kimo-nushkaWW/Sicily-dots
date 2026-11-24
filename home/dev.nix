{ pkgs, config, lib, ... }:

{
  # ── Git ──────────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user.name  = "kimo";                    # CHANGE to your name
      user.email = "you@example.com";         # CHANGE to your email
      init.defaultBranch   = "main";
      pull.rebase          = true;
      push.autoSetupRemote = true;
      merge.conflictstyle  = "zdiff3";
      core.editor          = "codium --wait";
      alias = {
        st      = "status -sb";
        lg      = "log --oneline --graph --decorate --all";
        co      = "checkout";
        br      = "branch";
        unstage = "reset HEAD --";
        last    = "log -1 HEAD";
      };
    };
  };

  # ── delta (git diff pager) ───────────────────────────────────────────────────
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate     = true;
      light        = false;
      line-numbers = true;
      side-by-side = false;
      syntax-theme = "Monokai Extended";
    };
  };

  # ── SSH ──────────────────────────────────────────────────────────────────────
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent    = "yes";
        ServerAliveInterval = 60;
        HashKnownHosts    = true;
        IdentityFile      = "~/.ssh/id_ed25519";  # CHANGE if your key is elsewhere
      };
      # Add host-specific blocks below, e.g.:
      # "github.com" = { User = "git"; IdentityFile = "~/.ssh/github_ed25519"; };
    };
  };

  # ── GPG ──────────────────────────────────────────────────────────────────────
  programs.gpg = {
    enable = true;
    settings = {
      default-key     = "";          # CHANGE: set your key fingerprint after import
      auto-key-retrieve = true;
      no-symkey-cache = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-gnome3;
    defaultCacheTtl  = 3600;
    maxCacheTtl      = 86400;
  };

  # ── Extra dev tools ───────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    python3      # Python interpreter
    gh             # GitHub CLI
    jq             # JSON processor
    ripgrep        # fast grep (rg)
    fd             # fast find
    bat            # cat with syntax highlighting
    htop           # process monitor
    ncdu           # disk usage analyzer
    fastfetch      # compact system summary beside the terminal greeting art
    unzip zip      # archive tools
  ];

  # ── eza aliases (replaces ls in fish) ────────────────────────────────────────
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git   = true;
    icons = "auto";
  };
}
