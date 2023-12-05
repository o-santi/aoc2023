{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

   outputs = { self, nixpkgs }:
    let pkgs = import nixpkgs { system = "x86_64-linux"; };
        parser = pkgs.callPackage ./parser.nix pkgs.lib;
    in
    {
      solutions.day-1 = pkgs.callPackage ./1/1.nix pkgs.lib;
      solutions.day-2 = pkgs.callPackage ./2/2.nix parser;
      solutions.day-3 = pkgs.callPackage ./3/3.nix parser;
    };
}
