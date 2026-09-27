{pkgs, ...}: {
  home.packages = with pkgs; [
    bun # JS/TS runtime
  ];
}
