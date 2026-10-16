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
      lib = nixpkgs.lib;

      # ⚠️  Change your username here, and also in install.sh
      user = "manssell";

      # Every folder in hosts/ that has a default.nix becomes a machine,
      # automatically. You never edit this file to add a laptop.
      hosts = lib.filterAttrs
        (name: type: type == "directory" && builtins.pathExists (./hosts + "/${name}/default.nix"))
        (builtins.readDir ./hosts);

      mkHost = host: extraModules: lib.nixosSystem {
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

      # For each machine: ".#<name>" (installed system) and ".#<name>-install"
      # (fresh install with disko, used by install.sh).
      perHost = name: {
        "${name}" = mkHost name [ ];
        "${name}-install" = mkHost name [
          disko.nixosModules.disko
          ./hosts/${name}/disko.nix
        ];
      };
    in
    {
      nixosConfigurations =
        lib.foldl' (acc: name: acc // perHost name) { } (lib.attrNames hosts);
    };
}
