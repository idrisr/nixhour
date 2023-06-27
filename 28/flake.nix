{
  description = "nothing";
  inputs.nixpkgs.url = "nixpkgs";
  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { system = system; };
      try01 = with pkgs;
        runCommand "test" { } ''
          cp ${./script.sh} script.sh
          patchShebangs script.sh
          ./script.sh
        '';
      try02 = with pkgs;
        runCommand "test" { nativeBuildInputs = [ makeWrapper ]; } ''
          cp ${./script.sh} script.sh
          patchShebangs script.sh
          makeWrapper script.sh wrapped.sh --prefix PATH : "${
            lib.getBin jq
          }/bin:${lib.getBin curl}"
          mkdir -p $out/bin
          mv wrapped.sh $out/bin/script.sh
        '';
      try03 = with pkgs;
        runCommand "test" { nativeBuildInputs = [ makeWrapper ]; } ''
          mkdir -p $out/bin
          cp ${./script.sh} script.sh
          patchShebangs script.sh
          mv ./script.sh $out/bin/script.sh
          wrapProgram $out/bin/script.sh --prefix PATH : ${
            lib.makeBinPath [ curl jq ]
          }
        ''; # would work if your env has jq or curl
      try04 = with pkgs;
        runCommand "test" { nativeBuildInputs = [ makeWrapper ]; } ''
          mkdir -p $out/bin
          cp ${./script.sh} script.sh
          patchShebangs script.sh
          mv ./script.sh $out/bin/script.sh
          wrapProgram $out/bin/script.sh --set PATH ${
            lib.makeBinPath [ curl jq ]
          }
        ''; # set path instead of prefix
      # 05 resholve mkDerivation
      # 06 resholve writeScriptBin
      # 07 pkgs.writers makeBinWriter
      # 08 subt-var-by --argstr
    in { packages.${system} = { inherit try01 try02 try03 try04; }; };
}
