{
  description = "NixOS: i3 + home-manager + disko (config that works across machines)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Automatic tweaks per laptop model (t420, x220, etc.)
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # OpenCode V2 (dev branch = 2.x). DISABLED for now: it downloads the whole
    # repo even when the module is not used, which makes installing from the
    # ISO slow. Uncomment this line (and ./modules/opencode.nix below) when you
    # want to use it.
    # opencode.url = "github:anomalyco/opencode/dev";
  };

  outputs = { self, nixpkgs, home-manager, disko, nixos-hardware, ... }@inputs:
    let
      # ⚠️  Change your username here, and also in install.sh
      user = "manssell";

      mkHost = host: extraModules: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs user; };
        modules = [
          ./modules/common.nix
          ./modules/desktop.nix
          # ./modules/opencode.nix   # <- uncomment to install OpenCode V2 (builds from source)
          ./hosts/${host}
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs user; };
            home-manager.users.${user} = import ./home;
          }
        ] ++ extraModules;
      };
    in
    {
      # System that is already installed (uses hosts/<host>/hardware-configuration.nix)
      nixosConfigurations.t420 = mkHost "t420" [ ];
      # Clean install with disko (used by install.sh)
      nixosConfigurations.t420-install = mkHost "t420" [
        disko.nixosModules.disko
        ./hosts/t420/disko.nix
      ];

      # For another machine: create hosts/<name>/ and add it here:
      # nixosConfigurations.<name> = mkHost "<name>" [ ];
    };
}
