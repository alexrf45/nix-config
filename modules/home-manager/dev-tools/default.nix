{...}: {
  imports = [
    ./go.nix
    ./javascript.nix
    ./python.nix
    ./terraform.nix
    ./aws.nix
    ./secrets.nix
    ./unstable.nix
  ];

  home.sessionPath = [
    "$HOME/go/bin"
    "$HOME/.local/bin"
  ];
}
