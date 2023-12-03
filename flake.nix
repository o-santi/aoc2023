{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let pkgs = import nixpkgs { system = "x86_64-linux"; }; in
    {
      solutions.day-1 = pkgs.callPackage ./1/1.nix pkgs.lib;
    };
}
