{ pkgs, lib, config, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ── Boot ─────────────────────────────────────────────────────────────────────
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # ── Network ──────────────────────────────────────────────────────────────────
  networking = {
    hostName = "sicily";
    networkmanager.enable = true;
  };

  # ── Locale / Time ────────────────────────────────────────────────────────────
  time.timeZone = "Europe/Rome"; # change to your zone
  i18n.defaultLocale = "en_US.UTF-8";

  # ── GPU — AMD ────────────────────────────────────────────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ── Audio — PipeWire ─────────────────────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # ── Hyprland ─────────────────────────────────────────────────────────────────
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # ── XDG portals (file picker, screen share, etc.) ────────────────────────────
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # ── User ─────────────────────────────────────────────────────────────────────
  users.users.kimo = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "input" ];
    shell = pkgs.fish;
  };

  # ── TTY autologin → Hyprland starts on tty1 ─────────────────────────────────
  services.getty.autologinUser = "kimo";

  # ── Security ─────────────────────────────────────────────────────────────────
  security.polkit.enable = true;
  security.pam.services.hyprlock = {}; # allow hyprlock to authenticate via PAM

  # ── Bluetooth ────────────────────────────────────────────────────────────────
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # ── System packages (minimal — user packages live in home-manager) ────────────
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    vim
  ];

  # ── Shell ────────────────────────────────────────────────────────────────────
  programs.fish.enable = true;

  # ── Misc ─────────────────────────────────────────────────────────────────────
  # Needed for NetworkManager applet / k4 wifi control
  programs.nm-applet.enable = false; # k4 handles wifi UI

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}
