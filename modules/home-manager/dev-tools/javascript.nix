{pkgs, ...}: {
  home.packages = with pkgs; [
    bun # JS/TS runtime — runtime for vault-task-sync (see modules/home-manager/vault-task-sync.nix)
  ];
}
