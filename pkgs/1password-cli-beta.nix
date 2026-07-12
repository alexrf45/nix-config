# 1Password CLI — beta channel, pinned to latest release.
#
# The beta CLI includes shell plugins not yet in stable (e.g. Terraform).
#
# Update procedure when 1Password releases a new beta CLI:
#   1. nix-prefetch-url https://cache.agilebits.com/dist/1P/op2/pkg/v<VERSION>/op_linux_amd64_v<VERSION>.zip
#   2. nix hash to-sri --type sha256 <hash-from-step-1>
#   3. Update version + hash below.
#
# Changelog: https://app-updates.agilebits.com/product_history/CLI2#beta

{ stdenv, fetchurl, unzip, installShellFiles }:

stdenv.mkDerivation rec {
  pname = "1password-cli-beta";
  version = "2.37.0-beta.01";

  src = fetchurl {
    url = "https://cache.agilebits.com/dist/1P/op2/pkg/v${version}/op_linux_amd64_v${version}.zip";
    hash = "sha256-Spho/lPR9NSY0elioQtw2I06k3iKQ509xA+QB0CPbw8=";
  };

  nativeBuildInputs = [ unzip installShellFiles ];

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    install -Dm755 op $out/bin/op
  '';

  # Generate shell completions
  postInstall = ''
    installShellCompletion --cmd op \
      --bash <($out/bin/op completion bash) \
      --zsh <($out/bin/op completion zsh) \
      --fish <($out/bin/op completion fish)
  '';

  meta = {
    description = "1Password CLI (beta) — includes Terraform and additional shell plugins";
    homepage = "https://developer.1password.com/docs/cli/";
  };
}
