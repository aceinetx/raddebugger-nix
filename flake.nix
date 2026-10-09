{
  description = "raddebugger";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        desktopItem = pkgs.makeDesktopItem {
          name = "raddbg";
          desktopName = "RAD Debugger";
          genericName = "RAD Debugger";
          comment = "RAD Debugger";
          exec = "raddbg";
          terminal = false;
          type = "Application";
          categories = [ "Development" ];
        };

        mkRaddebugger =
          {
            buildRadbin ? true,
            buildRadlink ? true,
            buildRaddbgNonGraphical ? true,
            buildTorture ? true,
          }:
          pkgs.stdenv.mkDerivation {
            pname = "raddbg";
            version = "0.9.29-alpha";

            src = pkgs.fetchgit {
              url = "https://github.com/epicgames/raddebugger";
              rev = "b6d8c3fd9eaf7b55960d80738365742a8fba9e29";
              hash = "sha256-rBGvDwYTX+s7ArSxBBeEWbGLF031OaOfubK8+KUl+xU=";
            };

            nativeBuildInputs = [
              pkgs.makeWrapper
              pkgs.patsh
              pkgs.git
            ];

            buildInputs = [
              pkgs.stdenv.cc.cc
              pkgs.libX11
              pkgs.libXext
              pkgs.libXrandr
              pkgs.libXfixes
              pkgs.freetype
              pkgs.libGL
            ];

            postPatch = ''
              patchShebangs build.sh
            '';

            buildPhase = ''
              runHook preBuild

              git init
              git add .
              git config user.email "you@example.com"
              git config user.name "Your Name"
              git commit -m "1"

              sed -i "s/-fdiagnostics-absolute-paths //g" build.sh

              radbin=${if buildRadbin then "1" else "0"} \
              radlink=${if buildRadlink then "1" else "0"} \
              raddbg_non_graphical=${if buildRaddbgNonGraphical then "1" else "0"} \
              torture=${if buildTorture then "1" else "0"} \
              ./build.sh

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir -p "$out/bin"

              install -Dm755 build/raddbg "$out/bin/raddbg"

              ${lib.optionalString buildRadbin ''
                install -Dm755 build/radbin "$out/bin/radbin"
              ''}

              ${lib.optionalString buildRadlink ''
                install -Dm755 build/radlink "$out/bin/radlink"
              ''}

              ${lib.optionalString buildRaddbgNonGraphical ''
                install -Dm755 build/raddbg_non_graphical \
                  "$out/bin/raddbg_non_graphical"
              ''}

              ${lib.optionalString buildTorture ''
                install -Dm755 build/torture "$out/bin/torture"
              ''}

              mkdir -p "$out/share/applications"
              install -Dm644 \
                "${desktopItem}/share/applications/raddbg.desktop" \
                "$out/share/applications/raddbg.desktop"

              runHook postInstall
            '';
          };
      in
      {
        packages = {
          default = mkRaddebugger { };

          minimal = mkRaddebugger {
            buildRadbin = false;
            buildRadlink = false;
            buildRaddbgNonGraphical = false;
            buildTorture = false;
          };
        };

        lib.mkRaddebugger = mkRaddebugger;
      }
    );
}
