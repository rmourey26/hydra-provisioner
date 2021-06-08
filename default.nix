{ nixopsUnstable 
, stdenv
, nixUnstable
}:

stdenv.mkDerivation {
  name = "hydra-provisioner";

  buildInputs = [
    nixopsUnstable.python.pkgs.wrapPython
    nixopsUnstable.python
    nixopsUnstable
  ];

  pythonPath = [ nixopsUnstable nixUnstable ];

  unpackPhase = "true";
  buildPhase = "true";

  installPhase =
    ''
      mkdir -p $out/bin $out/share/nix/hydra-provisioner
      cp ${./hydra-provisioner} $out/bin/hydra-provisioner
      cp ${./auto-shutdown.nix} $out/share/nix/hydra-provisioner/auto-shutdown.nix
      wrapPythonPrograms
    '';
}
