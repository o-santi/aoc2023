{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

   outputs = { self, nixpkgs }:
    let pkgs = import nixpkgs { system = "x86_64-linux"; };
        utils = pkgs.callPackage ./utils.nix pkgs.lib;
    in
    {
      solutions.day-1 = pkgs.callPackage ./1/1.nix utils;
      solutions.day-2 = pkgs.callPackage ./2/2.nix utils;
      solutions.day-3 = pkgs.callPackage ./3/3.nix utils;
      solutions.day-4 = pkgs.callPackage ./4/4.nix utils;
    };
}
