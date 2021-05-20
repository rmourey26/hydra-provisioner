# The "type" argument corresponds to the system type (such as 
# "x86_64-linux:benchmark"), and can be used for creating different
# kinds of machines from the same NixOps specification.
{ type, tag, ... }:

{

  machine =
    { config, lib, pkgs, ... }:
    {
      deployment.targetEnv = "virtualbox";
      
      # The queue runner will perform build actions via "nix-store --serve" 
      # on root@<machine>, so this machine needs an authorized key for that.
      users.extraUsers.root.openssh.authorizedKeys.keys = lib.singleton ''
        command="nix-store --serve --write" ssh-dss AAAAB3NzaC1...
      '';
      
      # Currently, Hydra works better with the Nix 1.10 prerelease.
      nix.package = pkgs.nixUnstable;
      
      # Frequent garbage collection is a good idea for build machines.
      nix.gc.automatic = true;
      nix.gc.dates = "*:0/30";
    };

}
