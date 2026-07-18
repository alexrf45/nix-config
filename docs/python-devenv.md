# Python Devenv Reference

Isolated, reproducible Python environments for security research, API development,
web scraping, and data analysis — with Docker image building built in.

---

## Quick Start

```bash
pydev <project-name>
```

That's it. The `pydev` shell function:

1. Creates `<project-name>/` in the current directory
2. Copies the Python devenv template files into it (`devenv.nix`, `requirements.txt`, `.envrc`)
3. Drops you into the devenv shell with all packages pre-installed

**Re-entering an existing project:**

```bash
pydev my-tool        # if my-tool/ already exists, skips creation and enters the shell
# — or —
cd my-tool && devenv shell
```

**First-run note:** The initial `devenv shell` builds the environment and pip-installs
all packages in `requirements.txt`. This takes ~1–3 minutes. Subsequent entries are instant.

---

## Template Files

These files are copied into every new project by `nix flake init`:

| File | Purpose |
|---|---|
| `devenv.nix` | Environment definition (packages, Python version, scripts) |
| `requirements.txt` | Python package list — edit freely, re-enter shell to sync |
| `.envrc` | `use devenv` — direnv auto-activates the shell on `cd` |

---

## Helper Scripts

All scripts below are available as shell commands once inside `devenv shell`.

### Testing & Quality

| Command | Description |
|---|---|
| `py-test` | Run all tests with pytest |
| `py-test -k foo` | Run tests matching `foo` (any pytest args accepted) |
| `py-test -x` | Stop on first failure |
| `py-lint` | Run `ruff check` (lint) + `ruff format --check` (format diff) |
| `py-fmt` | Auto-format all `.py` files with ruff |

### Dependency Management

| Command | Description |
|---|---|
| `py-add <pkg> [pkg...]` | `pip install` one or more packages and save to `requirements.txt` |
| `py-add requests==2.31.0` | Install a pinned version |
| `py-add 'httpx[http2]'` | Install a package with extras |
| `py-reqs` | Freeze the full current venv into `requirements.txt` |

**Workflow for adding packages mid-session:**

```bash
py-add shodan playwright-stealth   # installs + writes to requirements.txt immediately
```

Re-entering the shell later will re-sync from `requirements.txt` automatically.

### Docker Image Building

| Command | Description |
|---|---|
| `img-build <name>` | Build `./Dockerfile` → `<name>:latest` |
| `img-build <name> <tag>` | Build with a specific tag |
| `img-run <name>` | Run `<name>:latest` interactively (`--rm -it`) |
| `img-run <name> <tag>` | Run a specific tag |
| `img-push <registry/name>` | Push `<registry/name>:latest` to a registry |
| `img-push <registry/name> <tag>` | Push a specific tag |
| `hadolint` | Lint `./Dockerfile` for best-practice violations |
| `hadolint -` | Lint a Dockerfile piped from stdin |

**Typical Docker workflow:**

```bash
# Write your Dockerfile, then:
hadolint                        # check for issues
img-build my-scraper            # build my-scraper:latest
img-run  my-scraper             # smoke-test it locally
img-build my-scraper 1.0.0      # tag a release
img-push  ghcr.io/alexrf45/my-scraper 1.0.0
```

### Playwright

| Command | Description |
|---|---|
| `browser-install` | Download Chromium browser binary (run **once** after first shell entry) |

```bash
# After entering the shell for the first time:
browser-install

# Then use playwright in Python normally:
python -c "from playwright.sync_api import sync_playwright; ..."
```

---

## Pre-installed Python Packages

### HTTP / APIs
| Package | Use |
|---|---|
| `requests` | Sync HTTP client — the standard for one-off requests |
| `httpx[http2]` | Async-capable client with HTTP/2 support |
| `aiohttp` | Async HTTP client + lightweight server |
| `python-dotenv` | Load `.env` files into `os.environ` |

### Web Scraping / Parsing
| Package | Use |
|---|---|
| `beautifulsoup4` | HTML/XML parsing and traversal |
| `lxml` | Fast C-backed parser (use as bs4 backend) |
| `playwright` | Full browser automation (JS-heavy sites) |

### Data Analysis
| Package | Use |
|---|---|
| `pandas` | DataFrames, CSV/JSON/SQL ingestion and manipulation |
| `numpy` | Numerical arrays and math |
| `matplotlib` | Plotting and charting |
| `seaborn` | Statistical visualisation on top of matplotlib |
| `rich` | Pretty terminal output: tables, progress bars, syntax highlighting |

### Security Research
| Package | Use |
|---|---|
| `scapy` | Packet crafting, sniffing, network analysis |
| `cryptography` | AES, RSA, ECDSA, X.509, HMAC — full crypto primitive set |
| `paramiko` | SSH client/server in pure Python |
| `dnspython` | DNS queries, zone manipulation, DNSSEC |
| `python-nmap` | Programmatic wrapper around nmap scans |

### Docker SDK
| Package | Use |
|---|---|
| `docker` | Python API for the Docker daemon — build, run, manage containers from code |

### Dev / Testing
| Package | Use |
|---|---|
| `pytest` | Test runner |
| `pytest-asyncio` | Async test support for `asyncio` code |
| `ruff` | Linter + formatter (replaces flake8, black, isort) |
| `ipython` | Enhanced REPL with tab completion and magic commands |

---

## System Packages (always available in the shell)

These are Nix packages, not Python packages — available as CLI tools regardless
of the venv state:

| Tool | Use |
|---|---|
| `git` | Version control |
| `curl` | HTTP requests from the command line |
| `jq` | JSON processor / formatter |
| `hadolint` | Dockerfile linter |
| `sqlite3` | Local database — `sqlite3 data.db` |

Docker daemon and `docker-compose` are provided system-wide (not devenv-specific).

---

## Customising the Environment

### Adding Python packages

Edit `requirements.txt` directly, then re-enter the shell:

```bash
echo "shodan" >> requirements.txt
exit          # leave devenv shell
devenv shell  # re-enter — pip-installs new package automatically
```

Or use `py-add` without leaving the shell:

```bash
py-add shodan
```

### Adding system (non-Python) tools

Edit `devenv.nix` and add packages to the `packages` list:

```nix
packages = with pkgs; [
  git curl jq hadolint sqlite
  nmap          # ← add here
  httpie        # ← and here
];
```

Then re-enter the shell.

### Adding named scripts

Add to the `scripts` block in `devenv.nix`:

```nix
scripts = {
  scan = {
    exec        = "python scan.py ''${@}";
    description = "Run the scanner (args forwarded)";
  };
};
```

The script becomes a first-class shell command inside the devenv.

### Changing the Python version

Edit the `version` field in `devenv.nix`:

```nix
languages.python = {
  enable  = true;
  version = "3.12";   # ← change here
  ...
};
```

---

## Common Workflows

### Security research script

```bash
pydev recon-tool
# inside devenv shell:
py-add shodan censys python-nmap
cat > recon.py << 'EOF'
import nmap
nm = nmap.PortScanner()
nm.scan('127.0.0.1', '22-443')
print(nm.all_hosts())
EOF
py-test
```

### API client + Docker packaging

```bash
pydev api-client
# develop and test:
py-add httpx python-dotenv
py-test
# package it:
cat > Dockerfile << 'EOF'
FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "main.py"]
EOF
hadolint
img-build api-client
img-run  api-client
img-push ghcr.io/alexrf45/api-client
```

### Data analysis notebook

```bash
pydev data-analysis
py-add jupyter notebook
jupyter notebook   # opens browser
```

---

## Devenv Reference

The `devenv` tool itself has useful commands available outside the scripts above:

| Command | Description |
|---|---|
| `devenv shell` | Enter the devenv shell for the current directory |
| `devenv up` | Start background processes defined in `devenv.nix` |
| `devenv info` | Show packages, scripts, and environment info |
| `devenv search <pkg>` | Search available devenv packages |
| `devenv update` | Update the devenv lock file |
| `devenv gc` | Garbage-collect unused devenv generations |

---

## Directory Layout of a New Project

```
my-project/
├── devenv.nix        ← environment definition (packages, scripts, Python version)
├── devenv.lock       ← auto-generated lock file (commit this)
├── .devenv/          ← devenv state dir (add to .gitignore)
├── .envrc            ← `use devenv` (direnv auto-activation)
├── requirements.txt  ← Python packages (edit freely)
└── ...               ← your code
```

Recommended `.gitignore` additions:

```
.devenv/
.direnv/
__pycache__/
*.pyc
.env
```
