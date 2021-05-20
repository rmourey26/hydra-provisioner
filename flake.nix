{
  description = "Hydra Provisioner";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.hydra-provisioner = nixpkgs.legacyPackages.x86_64-linux.callPackage self {};

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.hydra-provisioner;
  };
}
