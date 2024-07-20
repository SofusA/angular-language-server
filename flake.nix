{
  description = "A flake for the angular-language-server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      nodejs = pkgs.nodejs;
      makeWrapper = pkgs.makeWrapper;
    in
    {
      packages = let
        version = let packageJson = with builtins; fromJSON (readFile ./package.json);
        in builtins.replaceStrings [ "^" "~" ] [ "" "" ]
        (packageJson.dependencies."@angular/language-server");

      in {
        angular-language-server = pkgs.mkYarnPackage rec {
          pname = "angular-language-server";
          version = "18.0";
          system = "${system}";

          src = ./.;
          inherit nodejs;

          nativeBuildInputs = with pkgs; [ makeWrapper ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin
            cp -r $node_modules $out
            cp $src/index.js $out/bin/${pname}-unwrapped
            chmod a+x $out/bin/${pname}-unwrapped

            makeWrapper $out/bin/${pname}-unwrapped $out/bin/${pname} \
              --add-flags "--stdio --ngProbeLocations $out/node_modules --tsProbeLocations $out/node-modules"

            runHook postInstall
          '';

          dontFixup = true;
          doDist = false;
        };
      };
    });
}
