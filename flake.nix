{
  description = "Sicily-dots — NixOS + Hyprland + k4 island";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tg-ws-proxy.url = "github:pialtor/tg-ws-proxy-flake";
  };

  outputs = { self, nixpkgs, home-manager, quickshell, antigravity-nix, spicetify-nix, zen-browser, tg-ws-proxy,... }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      overlays = [ quickshell.overlays.default ];
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.sicily = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hosts/sicily/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.kimo = import ./home;
            extraSpecialArgs = { inherit quickshell; };
          };
        }
      ];
      # Pass both pkgs (with overlays) and all flake inputs so configuration.nix
      # can reference tg-ws-proxy.packages, zen-browser, antigravity-nix, etc.
      specialArgs = {
        inherit pkgs;
        inputs = { inherit antigravity-nix spicetify-nix zen-browser tg-ws-proxy; };
      };
    };
  };
}
