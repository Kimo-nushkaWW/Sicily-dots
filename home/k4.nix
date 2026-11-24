{ pkgs, config, lib, ... }:

# k4 — Dynamic Island bar (source lives in Sicily-dots/k4/)
#
# Quickshell reads QML files at runtime from ~/.config/quickshell/k4.
# home.file creates a symlink there that points back into this repo,
# so editing anything in Sicily-dots/k4/ is reflected immediately on reload.

{
  # ── Runtime dependencies k4 needs on PATH ────────────────────────────────────
  home.packages = with pkgs; [
    # Core runtime
    quickshell          # QML shell runtime (from the quickshell flake overlay)
    python3             # tools/plugins.py and other k4 scripts
    git                 # k4 plugin install/update system

    # Qt multimedia — needed for the video editor / capture preview
    # These are pulled in as Qt plugins; quickshell itself needs them at runtime.
    # On NixOS they are included via the qt6 packages below.
    kdePackages.qtmultimedia

    # Media / audio control
    playerctl           # MPRIS media controls (play/pause/next/prev)
    pamixer             # volume control via PulseAudio/PipeWire
    wireplumber         # already a system service; provides wpctl on PATH

    # System info
    brightnessctl       # screen brightness
    networkmanager      # provides nmcli for wifi control

    # Clipboard (k4 built-in clipboard manager reads wl-clipboard)
    wl-clipboard        # wl-copy / wl-paste

    # Screen capture (k4's capture module)
    grim                # screenshot compositor
    slurp               # region selector
    wf-recorder         # Wayland screen recorder
    ffmpeg              # microphone/camera and track handling
    pulseaudio          # provides pactl for PipeWire/PulseAudio discovery
    satty               # screenshot annotation
    zenity               # file chooser dialogs used by the editor
    xdg-utils            # xdg-open for captured files and folders

    # Bluetooth
    bluez               # bluetoothctl
    blueman             # blueman-manager (optional GUI)

    # Misc tools k4 scripts use
    fd                  # fast find (used by launcher for file search)
    imagemagick         # thumbnail generation
    socat               # Hyprland IPC socket communication
    libnotify           # notify-send
    curl                # Gemini API adapter
    jq                  # Gemini API JSON assembly/parsing
    util-linux           # uuidgen for Gemini conversation ids

    # Whisper transcription (optional, for video editor subtitles)
    # whisper-cpp       # uncomment if you want this feature
  ];

  # ── Link Sicily-dots/k4/ → ~/.config/quickshell/k4 ──────────────────────────
  # source = the absolute path to k4/ in this repo.
  # Nix evaluates this relative to the flake's source tree.
  home.file.".config/quickshell/k4" = {
    source = ../k4;
    recursive = true;   # symlink each file individually → edits in-place work
  };

  # gemini.sh is kept explicit so it is included even when the flake source
  # is evaluated from a dirty Git worktree before the file is committed.
  home.file.".config/quickshell/k4/gemini.sh" = {
    text = builtins.readFile ../k4/gemini.sh;
    executable = true;
  };

  # New built-in plugins must be listed explicitly while the worktree is
  # dirty: a flake Git source contains tracked files, but not a new
  # uncommitted directory under the recursive k4 link.
  home.file.".config/quickshell/k4/plugins/Notas/NotasPlugin.qml".text =
    builtins.readFile ../k4/plugins/Notas/NotasPlugin.qml;
  home.file.".config/quickshell/k4/plugins/Notas/NotasView.qml".text =
    builtins.readFile ../k4/plugins/Notas/NotasView.qml;
  home.file.".config/quickshell/k4/plugins/Notas/qmldir".text =
    builtins.readFile ../k4/plugins/Notas/qmldir;
  home.file.".config/quickshell/k4/plugins/Notas/notas.py" = {
    text = builtins.readFile ../k4/plugins/Notas/notas.py;
    executable = true;
  };

  # Keep the old fragment available during the transition from an already
  # running .conf session. The new Lua config does not source it, so it cannot
  # trigger Hyprland's deprecation warning; it only prevents a live old
  # session from losing its K4 binds when Home Manager updates the symlink.
  home.file.".config/hypr/conf.d/k4.conf".text =
    let
      k4dir = "$HOME/.config/quickshell/k4";
      k4conf = builtins.readFile ../k4/hypr/k4.conf;
      withoutExecOnce = builtins.replaceStrings
        [ "exec-once = @RAIZ@/arrancar --no-duplicate -d\n" ]
        [ "" ]
        k4conf;
    in
    builtins.replaceStrings [ "@RAIZ@" ] [ k4dir ] withoutExecOnce
    + ''
      # Compatibility startup for a session that still has the legacy config
      # loaded. New Lua sessions start K4 from config/k4.lua instead.
      exec-once = $HOME/.config/quickshell/k4/arrancar --no-duplicate -d

      layerrule = match:namespace ^k4.*$, blur true
      layerrule = match:namespace ^k4.*$, ignore_alpha 0.5
      layerrule = match:namespace ^k4.*$, xray true
    '';

  # ── Hyprland Lua integration ────────────────────────────────────────────────
  # Hyprland 0.56+ loads Lua as the primary configuration format. The k4
  # template already uses the native Lua API, so autoload it as a module
  # instead of sourcing the deprecated k4.conf fragment.
  wayland.windowManager.hyprland.extraLuaFiles."config.k4" = {
    content = builtins.replaceStrings
      [ "@RAIZ@" ]
      [ "$HOME/.config/quickshell/k4" ]
      (builtins.readFile ../k4/hypr/k4.lua);
    autoLoad = true;
  };
}
