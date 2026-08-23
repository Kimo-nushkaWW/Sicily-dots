{ pkgs, config, ... }:

{
  # Use programs.vscodium so config is written to VSCodium's own paths
  # (~/.config/VSCodium, not ~/.config/Code)
  programs.vscodium = {
    enable = true;

    profiles.default = {
      userSettings = {
        # Editor
        "editor.fontFamily"                    = "'JetBrainsMono Nerd Font', 'Noto Color Emoji'";
        "editor.fontSize"                      = 14;
        "editor.lineHeight"                    = 1.6;
        "editor.fontLigatures"                 = true;
        "editor.formatOnSave"                  = true;
        "editor.cursorBlinking"                = "smooth";
        "editor.cursorSmoothCaretAnimation"    = "on";
        "editor.minimap.enabled"               = false;
        "editor.bracketPairColorization.enabled" = true;
        "editor.guides.bracketPairs"           = "active";
        "editor.renderWhitespace"              = "trailing";
        "editor.wordWrap"                      = "off";
        "editor.tabSize"                       = 2;
        "editor.stickyScroll.enabled"          = true;

        # Terminal
        "terminal.integrated.fontFamily"       = "'JetBrainsMono Nerd Font'";
        "terminal.integrated.fontSize"         = 13;

        # Workbench
        "workbench.startupEditor"              = "none";
        "workbench.colorTheme"                 = "Default Dark Modern";
        "workbench.iconTheme"                  = "material-icon-theme";
        "workbench.tree.indent"                = 16;
        "workbench.activityBar.location"       = "top";

        # Window
        "window.titleBarStyle"                 = "custom";
        "window.menuBarVisibility"             = "toggle";
        "window.zoomLevel"                     = 0;

        # Files
        "files.autoSave"                       = "onFocusChange";
        "files.trimTrailingWhitespace"         = true;
        "files.insertFinalNewline"             = true;

        # Telemetry — off
        "telemetry.telemetryLevel"             = "off";
      };

      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide           # Nix
        ms-python.python             # Python
        esbenp.prettier-vscode       # Prettier
        dbaeumer.vscode-eslint       # ESLint
        # QML (k4 editing): no nixpkgs package yet — install from Open VSX manually
        pkief.material-icon-theme    # icons
        eamodio.gitlens              # Git lens
        gruntfuggly.todo-tree        # TODO tracking
      ];
    };
  };
}
