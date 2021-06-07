{
  description = "Hydra Provisioner";

  inputs.utils.url = "github:kreisys/flake-utils";

  outputs = { self, nixpkgs, utils, ... }:
    utils.lib.simpleFlake {
      inherit nixpkgs;
      systems = [ "x86_64-linux" ];

      overlay = final: prev: {
        hydra-provisioner = final.callPackage self {};
      };

      packages = { hydra-provisioner }: {
        defaultPackage = hydra-provisioner;
        inherit hydra-provisioner;
      };
    };
}
