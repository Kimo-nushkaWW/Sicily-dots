{ pkgs, lib, config, inputs, ... }:

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

  systemd.services.tg-ws-proxy = {
    description = "Telegram MTProto WS Proxy";
    after = ["network-online.target" "nss-lookup.target"];
    wants = ["network-online.target" "nss-lookup.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${inputs.tg-ws-proxy.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/tg-ws-proxy";
      Restart = "always";
      RestartSec = "10s";
      DynamicUser = true;
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;
    };
  };

  # ── Locale / Time ────────────────────────────────────────────────────────────
  time.timeZone = "Asia/Yekaterinburg";
  i18n.defaultLocale = "ru_RU.UTF-8";

  # ── GPU — AMD ────────────────────────────────────────────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true;    # 32-bit Vulkan for Steam/Wine (uses mesa radv by default)
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
    git wget curl vim

    # Antigravity IDE (from antigravity-nix flake input)
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-ide
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli

    # Apps
    kdePackages.kolourpaint
    libreoffice-qt-stable   # replace onlyoffice if not in nixpkgs-unstable
    unrar
    qbittorrent
    steam
    discord

    # Zen browser (from zen-browser flake input)
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Telegram
    telegram-desktop

    # tg-ws-proxy (started as systemd service above; also useful on PATH)
    inputs.tg-ws-proxy.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # ── Shell ────────────────────────────────────────────────────────────────────
  programs.fish.enable = true;

  # ── Misc ─────────────────────────────────────────────────────────────────────
  # Needed for NetworkManager applet / k4 wifi control
  programs.nm-applet.enable = false; # k4 handles wifi UI

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}
