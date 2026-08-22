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

  # ── Autostart via Hyprland exec-once ─────────────────────────────────────────
  # Written to ~/.config/hypr/conf.d/k4.conf and imported by hyprland.nix.
  # We use exec-once so k4 only starts once per session.
  home.file.".config/hypr/conf.d/k4.conf".text = ''
    # k4 Dynamic Island — started by Hyprland
    exec-once = quickshell -p $HOME/.config/quickshell/k4

    # Layer rules so Hyprland treats k4 as a shell overlay, not a window
    layerrule = blur, k4*
    layerrule = ignorealpha 0.5, k4*
    layerrule = xray 0, k4*
  '';
}
