{pkgs, ...}: {
  # =======================================================================
  # Ollama — local LLM inference server (horus only)
  # =======================================================================
  # Pilot: private, self-hosted models on the one machine with a discrete
  # GPU (NVIDIA GTX 1650 Mobile, ~4 GB VRAM). CUDA compute runs on the dGPU
  # even though the AMD iGPU drives the display — the NVIDIA driver, PRIME
  # offload, and modesetting are already set in ./hardware.nix, and
  # powerManagement.finegrained = false keeps the card powered for compute.
  #
  # Exposes an OpenAI-compatible endpoint on 127.0.0.1:11434 (the upstream
  # default — localhost only, no LAN exposure for the pilot, so no firewall
  # change is needed).
  #
  # Model blobs live under /var/lib/ollama (on the 948 GB ext4 root NVMe),
  # NOT under /home — pulling several models won't crowd user storage.
  #
  # 4 GB VRAM guide:
  #   • fully on GPU (fast):       3–4B  (llama3.2:3b, qwen2.5:3b)
  #   • partial offload (usable):  7–8B  (qwen2.5-coder:7b, llama3.1:8b)
  #   • CPU + 32 GB RAM (async):   14B+  (slow)
  #
  # Starter set — pull interactively after the first rebuild so you control
  # timing and see progress (kept out of `loadModels` so a multi-GB download
  # never blocks a rebuild):
  #   ollama pull qwen2.5-coder:7b   # coding supplement
  #   ollama pull qwen2.5:7b         # privacy research / general reasoning
  #   ollama pull llama3.2:3b        # fast quick-tasks baseline
  # =======================================================================
  services.ollama = {
    enable = true;
    # nixpkgs 26.05 removed `acceleration`; the CUDA build is selected by
    # package instead. pkgs.ollama-cuda pulls the NVIDIA/CUDA-linked variant.
    package = pkgs.ollama-cuda;
  };
}
