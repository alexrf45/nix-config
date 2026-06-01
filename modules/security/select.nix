# Resolves securityLab options into a flat package list. Shared by the NixOS
# and Home Manager modules so the selection logic lives in exactly one place.
{ pkgs, lib, cfg }:
let
  catalog = import ./catalog.nix { inherit pkgs lib; };

  # A category is on if its own toggle is set OR the group's `all` is set.
  pick = group: catalogGroup:
    lib.concatLists (lib.mapAttrsToList
      (name: pkgList:
        lib.optionals ((group.all or false) || (group.${name} or false)) pkgList)
      catalogGroup);
in
lib.unique (lib.flatten [
  (pick cfg.offensive catalog.offensive)
  (pick cfg.defensive catalog.defensive)
  (lib.optionals cfg.secrets catalog.secrets)
  (lib.optionals cfg.extras catalog.extras)
])
