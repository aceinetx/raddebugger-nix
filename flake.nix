{
  description = "raddebugger";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      desktopItem = pkgs.makeDesktopItem {
        name = "raddbg";
        desktopName = "RAD Debugger";
        genericName = "RAD Debugger";
        comment = "RAD Debugger";
        exec = "raddbg";
        terminal = false;
        type = "Application";
        categories = [
          "Development"
        ];
      };
    in
    {
      packages.x86_64-linux.default = pkgs.stdenv.mkDerivation {
        name = "raddbg";
        version = "0.9.29-alpha";
        src = pkgs.fetchgit {
          url = "https://github.com/epicgames/raddebugger";
          rev = "cd41ba199bbe091d348a9b2be5a3528cb8acbff0";
          hash = "sha256-IQNicRWKdIamDeQU1RRceRR2QgoUlomQYoeCgepO10w=";
        };

        buildInputs = [
          pkgs.makeWrapper
          pkgs.stdenv.cc.cc
          pkgs.patsh
          pkgs.git
          pkgs.libX11
          pkgs.libXext
          pkgs.libXfixes
          pkgs.freetype
          pkgs.libGL
        ];

        postPatch = ''
          patchShebangs build.sh
        '';

        buildPhase = ''
          git init
          git add .
          git config user.email "you@example.com"
          git config user.name "Your Name"
          git commit -m "1"

          sed -i "s/-fdiagnostics-absolute-paths //g" build.sh
          ./build.sh

          mkdir -p "$out/bin"
          cp build/raddbg "$out/bin"

          mkdir -p "$out/share/applications"
          cp "${desktopItem}/share/applications/raddbg.desktop" "$out/share/applications"
        '';
      };
    };
}
