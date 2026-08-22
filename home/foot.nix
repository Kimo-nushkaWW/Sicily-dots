{ pkgs, config, ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "JetBrainsMono Nerd Font:size=12";
        dpi-aware = "yes";
        pad = "8x8";
      };

      mouse = {
        hide-when-typing = "yes";
      };

      colors = {
        # Base16 dark — overridden dynamically by pywal's foot template.
        # pywal writes ~/.config/foot/foot.ini which foot reads on launch.
        background = "1e1e2e";
        foreground = "cdd6f4";
        regular0 = "45475a";
        regular1 = "f38ba8";
        regular2 = "a6e3a1";
        regular3 = "f9e2af";
        regular4 = "89b4fa";
        regular5 = "f5c2e7";
        regular6 = "94e2d5";
        regular7 = "bac2de";
        bright0 = "585b70";
        bright1 = "f38ba8";
        bright2 = "a6e3a1";
        bright3 = "f9e2af";
        bright4 = "89b4fa";
        bright5 = "f5c2e7";
        bright6 = "94e2d5";
        bright7 = "a6adc8";
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
        clipboard-copy = "Control+Shift+c XF86Copy";
        clipboard-paste = "Control+Shift+v XF86Paste";
        font-increase = "Control+plus Control+equal";
        font-decrease = "Control+minus";
        font-reset = "Control+0";
      };
    };
  };
}
