{pkgs, ...}: {
  home.packages = with pkgs; [
    bun # JS/TS runtime — required by LifeOS (~/.claude/LIFEOS)
  ];
}
