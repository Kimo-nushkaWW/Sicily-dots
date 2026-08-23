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

    # Bluetooth
    bluez               # bluetoothctl
    blueman             # blueman-manager (optional GUI)

    # Misc tools k4 scripts use
    fd                  # fast find (used by launcher for file search)
    imagemagick         # thumbnail generation
    socat               # Hyprland IPC socket communication
    libnotify           # notify-send

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

  # ── Autostart + Hyprland rules ───────────────────────────────────────────────
  # arrancar sets QML_IMPORT_PATH so plugins can `import K4`. Calling quickshell
  # directly skips this and every plugin fails silently at runtime.
  #
  # k4.conf (from k4/hypr/k4.conf) ships with @RAIZ@ placeholders. We substitute
  # them here at eval time and write the result into conf.d/ so Hyprland sources
  # it automatically. The exec-once line from k4.conf is EXCLUDED — we write our
  # own below so we don't duplicate the process on Hyprland reload.
  home.file.".config/hypr/conf.d/k4.conf".text =
    let
      k4dir = "$HOME/.config/quickshell/k4";
      k4conf = builtins.readFile ../k4/hypr/k4.conf;
      # Strip the exec-once line from k4.conf — we write our own.
      withoutExecOnce = builtins.replaceStrings
        [ "exec-once = @RAIZ@/arrancar --no-duplicate -d\n" ]
        [ "" ]
        k4conf;
    in
    builtins.replaceStrings [ "@RAIZ@" ] [ k4dir ] withoutExecOnce
    + ''

      # ── Startup (managed by Nix, not k4's installer) ──────────────────────────
      # arrancar sets QML_IMPORT_PATH for the K4 module. --no-duplicate prevents
      # a second instance on Hyprland config reload.
      exec-once = $HOME/.config/quickshell/k4/arrancar --no-duplicate -d

      # ── Layer rules ───────────────────────────────────────────────────────────
      layerrule = blur, k4*
      layerrule = ignorealpha 0.5, k4*
      layerrule = xray 0, k4*
    '';
}
