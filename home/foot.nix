{ pkgs, config, lib, ... }:

{
  # The palette is rendered by ~/.local/bin/wallpaper from pywal's
  # ~/.cache/wal/colors.json. Keep foot.ini Nix-managed and include only the
  # writable color fragment, so a wallpaper change never mutates the store
  # symlink.
  programs.foot = {
    enable = true;
    settings = {
      main = {
        include = "~/.local/state/k4/foot-colors.ini";
        # The generated include follows the system theme.  Light is the safe
        # first-run choice and prevents a black terminal during activation.
        "initial-color-theme" = "light";
        term = "xterm-256color";
        font = "JetBrainsMono Nerd Font:size=12";
        dpi-aware = "yes";
        pad = "12x10";
        # The custom greeting is 46 rows tall and about 101 columns wide;
        # leave enough room for Fastfetch's PC summary on its right.
        initial-window-size-chars = "150x48";
        title = "Терминал";
        bold-text-in-bright = "no";
      };

      mouse = {
        hide-when-typing = "yes";
      };

      "colors-dark" = {
        # Fallback used before the first palette helper run.  The helper
        # replaces these sections with a wallpaper accent and a contrasting
        # foreground/cursor according to the system mode.
        alpha = "1.0";
        blur = "yes";
        background = "000000";
        foreground = "ffffff";
        cursor = "000000 ffffff";
        regular0 = "000000";
        regular1 = "f38ba8";
        regular2 = "a6e3a1";
        regular3 = "f9e2af";
        regular4 = "89b4fa";
        regular5 = "f5c2e7";
        regular6 = "94e2d5";
        regular7 = "ffffff";
        bright0 = "000000";
        bright1 = "f38ba8";
        bright2 = "a6e3a1";
        bright3 = "f9e2af";
        bright4 = "89b4fa";
        bright5 = "f5c2e7";
        bright6 = "94e2d5";
        bright7 = "ffffff";
      };

      "colors-light" = {
        alpha = "1.0";
        blur = "yes";
        background = "ffffff";
        foreground = "111111";
        cursor = "ffffff 111111";
        regular0 = "ffffff";
        regular1 = "9f1239";
        regular2 = "166534";
        regular3 = "854d0e";
        regular4 = "075985";
        regular5 = "86198f";
        regular6 = "0f766e";
        regular7 = "111111";
        bright0 = "ffffff";
        bright1 = "9f1239";
        bright2 = "166534";
        bright3 = "854d0e";
        bright4 = "075985";
        bright5 = "86198f";
        bright6 = "0f766e";
        bright7 = "111111";
      };

      cursor = {
        style = "beam";
        blink = "yes";
      };

      scrollback = {
        lines = 10000;
      };

      key-bindings = {
        scrollback-up-page = "shift+Page_Up";
        scrollback-down-page = "shift+Page_Down";
        scrollback-home = "Control+Home";
        scrollback-end = "Control+End";
        search-start = "Control+Shift+f";
        show-urls-launch = "Control+Shift+o";
        spawn-terminal = "Control+Shift+n";
        clipboard-copy = "Control+Shift+c XF86Copy";
        clipboard-paste = "Control+Shift+v XF86Paste";
        font-increase = "Control+plus Control+equal";
        font-decrease = "Control+minus";
        font-reset = "Control+0";
      };
    };
  };

  # Make the include valid even before the first wallpaper change or when
  # Foot starts ahead of the graphical-session startup helper.
  home.activation.k4FootPalette = lib.hm.dag.entryAfter [ "writeBoundary" "linkGeneration" ] ''
    palette="$HOME/.local/state/k4/foot-colors.ini"
    if [ -r "$HOME/.cache/wal/colors.json" ]; then
      "$HOME/.local/bin/k4-palette" || true
    fi
    if [ ! -s "$palette" ]; then
      mkdir -p "$(dirname "$palette")"
      cat > "$palette" <<'EOF'
[main]
initial-color-theme=light

[colors-dark]
alpha=1.0
background=000000
foreground=ffffff
cursor=000000 ffffff
regular0=000000
regular1=bf616a
regular2=a3be8c
regular3=ebcb8b
regular4=81a1c1
regular5=b48ead
regular6=88c0d0
regular7=ffffff
bright0=4c566a
bright1=bf616a
bright2=a3be8c
bright3=ebcb8b
bright4=81a1c1
bright5=b48ead
bright6=8fbcbb
bright7=ffffff

[colors-light]
alpha=1.0
background=ffffff
foreground=111111
cursor=ffffff 111111
regular0=ffffff
regular1=9f1239
regular2=166534
regular3=854d0e
regular4=075985
regular5=86198f
regular6=0f766e
regular7=111111
bright0=ffffff
bright1=9f1239
bright2=166534
bright3=854d0e
bright4=075985
bright5=86198f
bright6=0f766e
bright7=111111
EOF
    fi
  '';
}
