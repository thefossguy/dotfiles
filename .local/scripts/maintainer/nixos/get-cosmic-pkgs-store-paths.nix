let
  pkgs = import <nixpkgs> { overlays = []; config.allowAliases = false; };
  inherit (pkgs) lib;

  exclude = [
    "libcosmicAppHook"
    "cosmic-design-demo"
  ];

  hasCosmicTeam = pkg:
    let ms = pkg.meta.teams or [];
    in builtins.elem lib.teams.cosmic (if builtins.isList ms then ms else [ms]);

  cosmicPkgs = builtins.filter (attrName:
      !(builtins.elem attrName exclude) &&
      (let r = builtins.tryEval (hasCosmicTeam pkgs.${attrName});
       in r.success && r.value))
    (builtins.attrNames pkgs);
in
  lib.strings.concatStringsSep " " (map (attrName: pkgs.${attrName}.outPath) cosmicPkgs)
