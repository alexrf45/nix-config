{
  pkgs,
  config,
  lib,
  ...
}: let
  # The h0me repo owns the kubeop wrapper — see .claude/rules/kube-wrapper.md
  # there. Keeping one copy avoids the two drifting; the feature test below
  # means a shell still starts cleanly if the repo isn't checked out.
  kubeopScript = "${config.home.homeDirectory}/h0me/_hack/scripts/kubeop.sh";
in {
  # ---------------------------------------------------------------------
  # Kubernetes tooling for the h0me lab (cluster `anubis`, env `home`).
  #
  # Restored 2026-09-19. Dropped in 39c1978 ("drop kubernetes tooling") when
  # the 6-node Talos cluster `memphis` was decommissioned; the lab came back
  # in 2026-09 as a single k3s node, so the clients came back with it.
  #
  # NOTE: no `kustomize`. The h0me repo deliberately uses kubectl's built-in
  # (`kube home kustomize <dir>`, with no `build` subcommand) — see
  # .claude/rules/kustomize.md. Installing the standalone binary would make
  # the two silently diverge.
  #
  # NOTE: no `kubectx`/`kubens`. The kubeconfig is fetched from 1Password per
  # invocation and holds exactly one context, so there is nothing to switch
  # between. `kubeop-env <env>` changes the target cluster instead.
  # ---------------------------------------------------------------------
  home.packages = with pkgs; [
    kubectl # 1.36.x — matches k3s v1.36.4+k3s1 on anubis
    k9s
    fluxcd # `flux` CLI; the cluster runs Flux Operator
    kubernetes-helm
    stern # multi-pod log tailing
    kubectl-cnpg # CloudNativePG plugin
    cilium-cli # Phase 1 bootstrap + `cilium status` debugging
    yamllint # h0me /lint and its PostToolUse hook
  ];

  # KUBECONFIG is deliberately NOT set. The kubeconfig never lands on disk —
  # it is pulled from 1Password per invocation and passed via /dev/fd. A bare
  # `kubectl` is therefore expected to fail with "no configuration has been
  # provided"; that is the design, not a bug. Go through `kube`/`k8sop`.
  programs.bash.initExtra = lib.mkAfter ''
    # h0me kubeop wrapper — kubectl/flux/helm/k9s with a 1Password-sourced
    # kubeconfig. Sourced rather than inlined so the h0me repo stays the single
    # source of truth for the env→cluster map.
    if [ -r "${kubeopScript}" ]; then
      # shellcheck source=/dev/null
      . "${kubeopScript}"
    fi
  '';
}
