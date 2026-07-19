{ pkgs, ... }:
{
  home.packages = with pkgs; [
    go
    golangci-lint
    gotools          # goimports, godoc, etc.
    delve            # Go debugger
  ];

  home.sessionVariables = {
    GOPATH  = "$HOME/go";
    GOBIN   = "$HOME/go/bin";
    GOPROXY = "https://proxy.golang.org,direct";
    GOSUMDB = "sum.golang.org";
  };
}
