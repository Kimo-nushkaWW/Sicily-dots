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

  # Home Manager activation installs packages with the nix CLI.
  # Declare the features explicitly instead of relying on the invoking user's
  # nix.conf, which may not enable them during a system activation.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  systemd.services.tg-ws-proxy = {
    description = "Local Telegram MTProto WebSocket proxy";
    after = ["network-online.target" "nss-lookup.target"];
    wants = ["network-online.target" "nss-lookup.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      # The secret must persist: Telegram Desktop stores it in its proxy
      # settings and would lose access after every systemd restart otherwise.
      StateDirectory = "tg-ws-proxy";
      StateDirectoryMode = "0700";
      ExecStart = pkgs.writeShellScript "tg-ws-proxy-start" ''
        set -eu

        secret_file=/var/lib/tg-ws-proxy/secret
        if [ ! -s "$secret_file" ]; then
          umask 077
          ${pkgs.openssl}/bin/openssl rand -hex 16 > "$secret_file"
        fi

        secret="$(${pkgs.coreutils}/bin/tr -d '\n' < "$secret_file")"
        exec ${inputs.tg-ws-proxy.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/tg-ws-proxy \
          --host 127.0.0.1 --port 1443 --secret "$secret"
      '';
      Restart = "on-failure";
      RestartSec = "10s";
      DynamicUser = true;
      CapabilityBoundingSet = "";
      NoNewPrivileges = true;
    };
  };

  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };

  networking.firewall.checkReversePath = "loose";

  # System-wide transparent DPI bypass for Discord and YouTube only. Game
  # filtering stays disabled.
  services.zapret-discord-youtube = {
    enable = true;
    configName = "discord-youtube";
    gameFilter = "null";

    extraHostlists."list-discord-youtube.txt" = [
      # Discord client, CDN, invites, media, and status endpoints.
      "discord.app"
      "discord.com"
      "discord.co"
      "discord.gg"
      "discord.media"
      "discord.new"
      "discord.status"
      "discordapp.com"
      "discordapp.net"
      "discordcdn.com"
      "discord-attachments-uploads-prd.storage.googleapis.com"
      "stable.dl2.discordapp.net"

      # YouTube playback, API, thumbnails, embeds, and short links.
      "youtube.com"
      "youtu.be"
      "youtube-nocookie.com"
      "youtube.googleapis.com"
      "youtubei.googleapis.com"
      "youtubeembeddedplayer.googleapis.com"
      "youtubekids.com"
      "googlevideo.com"
      "ytimg.com"
      "yt3.googleusercontent.com"
      "yt3.ggpht.com"
      "yt4.ggpht.com"
      "wide-youtube.l.google.com"
      "youtube-ui.l.google.com"
      "yt-video-upload.l.google.com"
      "jnn-pa.googleapis.com"

    ];

    # YouTube needs a dedicated Google TLS strategy below; keep it separate
    # from Discord so that the stricter profile does not affect Discord.
    extraHostlists."list-youtube.txt" = [
      "youtube.com"
      "youtu.be"
      "youtube-nocookie.com"
      "youtube.googleapis.com"
      "youtubei.googleapis.com"
      "youtubeembeddedplayer.googleapis.com"
      "youtubekids.com"
      "googlevideo.com"
      "ytimg.com"
      "ytimg.l.google.com"
      "yt3.googleusercontent.com"
      "yt3.ggpht.com"
      "yt4.ggpht.com"
      "wide-youtube.l.google.com"
      "youtube-ui.l.google.com"
      "yt-video-upload.l.google.com"
      "jnn-pa.googleapis.com"
    ];

    # This is the upstream "general" strategy narrowed to the target host
    # list above. It handles TCP/HTTPS, QUIC, and Discord voice without
    # enabling broad game filters.
    extraConfigs."discord-youtube" = ''
      FWTYPE=iptables
      SET_MAXELEM=4096
      IPSET_OPT="hashsize 4096 maxelem $SET_MAXELEM"
      MDIG_THREADS=8
      GZIP_LISTS=1
      DESYNC_MARK=0x40000000
      DESYNC_MARK_POSTNAT=0x20000000

      TPWS_SOCKS_ENABLE=0
      TPWS_ENABLE=0

      NFQWS_ENABLE=1
      NFQWS_PORTS_TCP=80,443
      NFQWS_PORTS_UDP=443,19294-19344,50000-50100
      GAME_FILTER_TCP=12
      GAME_FILTER_UDP=12
      NFQWS_TCP_PKT_OUT=9
      NFQWS_TCP_PKT_IN=3
      NFQWS_UDP_PKT_OUT=9
      NFQWS_UDP_PKT_IN=0

      NFQWS_OPT="
      --filter-udp=443 --hostlist=/opt/zapret/hostlists/list-discord-youtube.txt --dpi-desync=fake --dpi-desync-repeats=6 --dpi-desync-fake-quic=/opt/zapret/files/fake/quic_initial_www_google_com.bin --new
      --filter-udp=19294-19344,50000-50100 --filter-l7=discord --dpi-desync=fake --dpi-desync-fake-discord=/opt/zapret/files/fake/ACTIVE_DISCORD_UDP.bin --dpi-desync-repeats=6 --new
      --filter-tcp=2053,2083,2087,2096,8443 --hostlist-domains=discord.media --dpi-desync=multisplit --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-split-seqovl-pattern=/opt/zapret/files/fake/tls_clienthello_www_google_com.bin --new
      --filter-tcp=443 --hostlist=/opt/zapret/hostlists/list-youtube.txt --ip-id=zero --dpi-desync=hostfakesplit --dpi-desync-fooling=ts --dpi-desync-hostfakesplit-mod=host=www.google.com --new
      --filter-tcp=80,443 --hostlist=/opt/zapret/hostlists/list-discord-youtube.txt --dpi-desync=multisplit --dpi-desync-split-seqovl=568 --dpi-desync-split-pos=1 --dpi-desync-split-seqovl-pattern=/opt/zapret/files/fake/tls_clienthello_4pda_to.bin
      "

      MODE_FILTER=none
      FLOWOFFLOAD=donttouch
      INIT_APPLY_FW=1
    '';
  };

  # ── Locale / Time ────────────────────────────────────────────────────────────
  time.timeZone = "Asia/Yekaterinburg";
  i18n.defaultLocale = "ru_RU.UTF-8";

  # ── GPU — graphics (Intel CPU, integrated or discrete) ──────────────────────
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
  systemd.services."getty@tty1" = {
    wants = [ "home-manager-kimo.service" ];
    after = [ "home-manager-kimo.service" ];
  };

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
 fonts.packages = with pkgs; [
  corefonts
  liberation_ttf
  dejavu_fonts
 ]; 

 programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    protontricks.enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };


  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in {
    enable = true;
    
    # Выбор темы (например, популярная Catppuccin)
#    theme = spicePkgs.themes.catppuccin;
#    colorScheme = "mocha";

    # Включение полезных расширений (по желанию)
    enabledExtensions = with spicePkgs.extensions; [
      adblockify # Блокировка рекламы
      hidePodcasts # Скрыть подкасты
      shuffle # Улучшенный шаффл
    ];
  };

  services.flatpak.enable = true;

  environment.systemPackages = with pkgs; [
    git wget curl vim

    (writeShellScriptBin "throne" ''
      exec ${config.programs.throne.package}/bin/Throne "$@"
    '')
    (writeShellScriptBin "thwsproxy" ''
      exec ${inputs.tg-ws-proxy.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/tg-ws-proxy "$@"
    '')
    (writeShellScriptBin "tg-ws-proxy-link" ''
      set -eu
      secret="$(sudo ${pkgs.coreutils}/bin/tr -d '\n' < /var/lib/tg-ws-proxy/secret)"
      printf 'tg://proxy?server=127.0.0.1&port=1443&secret=dd%s\n' "$secret"
    '')
    (writeShellScriptBin "zapret-toggle" ''
      set -eu

      service="zapret-discord-youtube.service"
      action="''${1:-toggle}"

      case "$action" in
        toggle)
          if ${pkgs.systemd}/bin/systemctl is-active --quiet "$service"; then
            exec sudo ${pkgs.systemd}/bin/systemctl stop "$service"
          else
            exec sudo ${pkgs.systemd}/bin/systemctl start "$service"
          fi
          ;;
        on|start)
          exec sudo ${pkgs.systemd}/bin/systemctl start "$service"
          ;;
        off|stop)
          exec sudo ${pkgs.systemd}/bin/systemctl stop "$service"
          ;;
        restart)
          exec sudo ${pkgs.systemd}/bin/systemctl restart "$service"
          ;;
        status)
          exec ${pkgs.systemd}/bin/systemctl status "$service"
          ;;
        *)
          echo "Usage: zapret-toggle [on|off|toggle|restart|status]" >&2
          exit 2
          ;;
      esac
    '')

    # Antigravity IDE (from antigravity-nix flake input)
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-ide
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli

    # Apps
    libreoffice-fresh
    kdePackages.kolourpaint
#    onlyoffice-desktopeditors
    unrar
    qbittorrent
    steam
    nftables
    gamescope
    mangohud
    vulkan-tools
    vscodium
    discord
    obsidian
    direnv
    nix-direnv    

    # Zen browser (from zen-browser flake input)
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    inputs.elypl.packages.${pkgs.stdenv.hostPlatform.system}.prismlauncher

    # Telegram
    telegram-desktop

    # AdsPower's maintained FHS launcher from NUR.
    nur.repos.xddxdd.adspower

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
