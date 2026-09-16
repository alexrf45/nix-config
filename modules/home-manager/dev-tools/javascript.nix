{pkgs, ...}: {
  home.packages = with pkgs; [
    bun # JS/TS runtime — used by vault-task-sync (~/code/vault-task-sync)
  ];
}
