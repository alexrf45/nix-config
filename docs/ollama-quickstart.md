# Ollama Quickstart — horus

Private, self-hosted LLM inference on **horus** (the only box with a discrete GPU).
Everything here matches `modules/nixos/ollama.nix`.

- **Package:** `pkgs.ollama-cuda` (NVIDIA/CUDA build)
- **GPU:** GTX 1650 Mobile, ~4 GB VRAM — CUDA runs on the dGPU via PRIME offload while the AMD iGPU drives the display
- **Endpoint:** `http://127.0.0.1:11434` — OpenAI-compatible, **localhost only** (no LAN exposure, no firewall change)
- **Model storage:** `/var/lib/ollama` (on the 948 GB root NVMe, not `/home`)

---

## 1. Confirm the service is up

```bash
systemctl status ollama        # should be active (running)
ollama --version               # CLI reachable
curl -s http://127.0.0.1:11434/api/tags | jq   # endpoint answers; [] until you pull
```

If `ollama` isn't found or the service is inactive, rebuild first:
`sudo nixos-rebuild switch --flake .#horus`

## 2. Pull the starter set

Pull interactively so you see progress. These are the three from the module header:

```bash
ollama pull llama3.2:3b        # fast quick-tasks baseline — fully on GPU
ollama pull qwen2.5-coder:7b   # coding supplement — partial offload
ollama pull qwen2.5:7b         # privacy research / general reasoning — partial offload
ollama list                    # confirm they landed
```

## 3. Chat from the terminal

```bash
ollama run llama3.2:3b
# type a prompt, then /bye to exit
```

One-shot, no REPL:

```bash
ollama run qwen2.5:7b "Summarize the CIA triad in three sentences."
```

## 4. Hit the API (OpenAI-compatible)

Native endpoint:

```bash
curl -s http://127.0.0.1:11434/api/generate -d '{
  "model": "qwen2.5-coder:7b",
  "prompt": "Write a bash one-liner to find world-writable files.",
  "stream": false
}' | jq -r .response
```

OpenAI-compatible endpoint (drop-in for any tool that speaks OpenAI — point it at this base URL, any dummy API key):

```bash
curl -s http://127.0.0.1:11434/v1/chat/completions -d '{
  "model": "qwen2.5:7b",
  "messages": [{"role": "user", "content": "Explain a SYN flood in two sentences."}]
}' | jq -r '.choices[0].message.content'
```

## 5. Confirm GPU offload

While a model is answering, in a second pane:

```bash
nvidia-smi          # ollama process should show VRAM in use on the GTX 1650
ollama ps           # shows loaded model + whether it's GPU/CPU/split
```

`ollama ps` prints a `PROCESSOR` column — `100% GPU` for the 3B, a GPU/CPU split for the 7Bs on 4 GB VRAM. That split is expected, not a misconfig.

---

## Picking a model by task

| VRAM fit | Size | Models | Feel |
|----------|------|--------|------|
| Fully on GPU | 3–4B | `llama3.2:3b`, `qwen2.5:3b` | Fast — quick tasks, drafts |
| Partial offload | 7–8B | `qwen2.5-coder:7b`, `llama3.1:8b` | Usable — coding, reasoning |
| CPU + 32 GB RAM | 14B+ | (async only) | Slow — background jobs |

## Handy commands

```bash
ollama list            # what's pulled
ollama ps              # what's loaded right now
ollama rm <model>      # free disk under /var/lib/ollama
du -sh /var/lib/ollama # total model footprint
journalctl -u ollama -f  # live service logs
```

Start with `llama3.2:3b` to confirm the whole path end-to-end (fast, fully on GPU), then move to the 7Bs once you trust the setup.
