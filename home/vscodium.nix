{ pkgs, config, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    userSettings = {
      # Editor
      "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'Noto Color Emoji'";
      "editor.fontSize" = 14;
      "editor.lineHeight" = 1.6;
      "editor.fontLigatures" = true;
      "editor.formatOnSave" = true;
      "editor.cursorBlinking" = "smooth";
      "editor.cursorSmoothCaretAnimation" = "on";
      "editor.minimap.enabled" = false;
      "editor.bracketPairColorization.enabled" = true;
      "editor.guides.bracketPairs" = "active";
      "editor.renderWhitespace" = "trailing";
      "editor.wordWrap" = "off";
      "editor.tabSize" = 2;
      "editor.stickyScroll.enabled" = true;

      # Terminal (uses foot via xterm)
      "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font'";
      "terminal.integrated.fontSize" = 13;

      # Workbench
      "workbench.startupEditor" = "none";
      "workbench.colorTheme" = "Default Dark Modern";
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.tree.indent" = 16;
      "workbench.activityBar.location" = "top";

      # Window
      "window.titleBarStyle" = "custom";
      "window.menuBarVisibility" = "toggle";
      "window.zoomLevel" = 0;

      # Files
      "files.autoSave" = "onFocusChange";
      "files.trimTrailingWhitespace" = true;
      "files.insertFinalNewline" = true;

      # Telemetry — off (VSCodium already strips most, belt-and-suspenders)
      "telemetry.telemetryLevel" = "off";
    };

    extensions = with pkgs.vscode-extensions; [
      # Language support
      jnoortheen.nix-ide           # Nix
      ms-python.python             # Python
      svelte.svelte-vscode         # Svelte (if needed)
      esbenp.prettier-vscode       # Prettier formatter
      dbaeumer.vscode-eslint       # ESLint

      # QML (k4 editing)
      # No official QML extension in nixpkgs yet — install manually from
      # Open VSX: bbenoist.qml or similar

      # UI
      pkief.material-icon-theme    # icons

      # Tools
      eamodio.gitlens              # Git lens
      gruntfuggly.todo-tree        # TODO tracking
    ];
  };
}
