let
  pkgs = import <nixpkgs> {
    overlays = [ ];
    config.allowAliases = false;
  };

  exclude = [
    "libcosmicAppHook"
    "cosmic-design-demo"
  ];

  hasCosmicTeam = pkg: builtins.any (t: t.shortName or "" == "COSMIC") (pkg.meta.teams or [ ]);

  cosmicPkgs = builtins.filter (
    attrName:
    !(builtins.elem attrName exclude)
    && (
      let
        evalResult = builtins.tryEval (hasCosmicTeam pkgs.${attrName});
      in
      evalResult.success && evalResult.value
    )
  ) (builtins.attrNames pkgs);
in
builtins.concatStringsSep " " (map (attrName: pkgs.${attrName}.outPath) cosmicPkgs)
