{
  description = "Sicily-dots — NixOS + Hyprland + k4 island";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Maintained third-party packages, including AdsPower's FHS launcher.
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Quickshell — the QML runtime that powers k4.
    # Exposes an overlay with pkgs.quickshell.
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    elypl = {
      url = "github:ElyPrismLauncher/Launcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tg-ws-proxy.url = "github:pialtor/tg-ws-proxy-flake";

    # Declarative, system-wide DPI bypass for Discord and YouTube.
    zapret-discord-youtube = {
      url = "github:kartavkun/zapret-discord-youtube";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nur, home-manager, quickshell, antigravity-nix, spicetify-nix, zen-browser, elypl,tg-ws-proxy, zapret-discord-youtube, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ quickshell.overlays.default nur.overlays.default ];
      config.allowUnfree = true;
    };
  in {
    # Export the exact Home Manager CLI used by this flake.  This keeps the
    # standalone `hrs` helper usable before this Home Manager generation is
    # activated in the user's PATH.
    packages.${system}.home-manager = home-manager.packages.${system}.home-manager;

    homeConfigurations."kimo@sicily" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit quickshell; };
      modules = [ ./home ];
    };

    nixosConfigurations.sicily = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/sicily/configuration.nix
        spicetify-nix.nixosModules.default
        zapret-discord-youtube.nixosModules.default
        {
          nixpkgs.overlays = [ quickshell.overlays.default nur.overlays.default ];
        }
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-backup";
            users.kimo = import ./home;
            extraSpecialArgs = { inherit quickshell; };
          };
        }
      ];
      # Pass flake inputs so configuration.nix can reference tg-ws-proxy.packages,
      # zen-browser, antigravity-nix, etc.
      specialArgs = {
        inputs = { inherit antigravity-nix spicetify-nix elypl zen-browser tg-ws-proxy; };
      };
    };
  };
}
