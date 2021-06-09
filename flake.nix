{
  description = "Hydra Provisioner";

  inputs.utils.url = "github:kreisys/flake-utils";

  outputs = { self, nixpkgs, utils, ... }:
  utils.lib.simpleFlake {
    inherit nixpkgs;
    systems = [ "x86_64-linux" ];

    overlay = final: prev: {
      hydra-provisioner = final.poetry2nix.mkPoetryApplication {
        meta.mainProgram = "hydra-provisioner";

        projectDir = ./.;

        postInstall = ''
          mkdir -p $out/share/nix/hydra-provisioner
          cp ${./nix/auto-shutdown.nix} $_/auto-shutdown.nix
        '';
      };
    };

    packages = { hydra-provisioner }: {
      defaultPackage = hydra-provisioner;
      inherit hydra-provisioner;
    };

    nixosModules = {
      hydra-provisioner = import ./module.nix;
      overlay = { nixpkgs.overlays = [ self.overlay ]; };
      default.imports = with self.nixosModules; [ overlay hydra-provisioner ];
    };
  };
}
