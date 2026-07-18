{ pkgs, lib, config, ... }:

{
  # -------------------------------------------------------------------------
  # Non-Python system tools available inside the devenv shell.
  # Docker daemon + docker-compose are provided system-wide; add only extra
  # tooling here that is specific to this project.
  # -------------------------------------------------------------------------
  packages = with pkgs; [
    git
    curl
    jq
    hadolint      # Dockerfile linter  (hadolint Dockerfile)
    sqlite        # lightweight local DB / quick data exploration
  ];

  # -------------------------------------------------------------------------
  # Python — creates an isolated venv and pip-installs requirements.txt
  # automatically every time the shell is entered or requirements change.
  # -------------------------------------------------------------------------
  languages.python = {
    enable  = true;
    version = "3.13";
    venv = {
      enable       = true;
      requirements = ./requirements.txt;
    };
  };

  # -------------------------------------------------------------------------
  # Named scripts — available as first-class commands in the devenv shell.
  # -------------------------------------------------------------------------
  scripts = {

    # ── Testing / quality ─────────────────────────────────────────────────
    py-test = {
      exec        = "python -m pytest -v ''${@}";
      description = "Run pytest (extra args forwarded)";
    };
    py-lint = {
      exec        = "ruff check . && ruff format --check .";
      description = "Lint + format-check with ruff";
    };
    py-fmt = {
      exec        = "ruff format .";
      description = "Auto-format code with ruff";
    };

    # ── Dependency management ─────────────────────────────────────────────
    py-reqs = {
      exec        = "pip freeze > requirements.txt && echo 'requirements.txt updated'";
      description = "Freeze current venv state → requirements.txt";
    };
    py-add = {
      exec        = ''
        pip install "''${@}" && pip freeze > requirements.txt
        echo "Installed and saved to requirements.txt"
      '';
      description = "pip install + auto-save to requirements.txt: py-add <pkg>...";
    };

    # ── Docker image building ─────────────────────────────────────────────
    img-build = {
      exec        = ''
        name=''${1:?Usage: img-build <image-name> [tag]}
        tag=''${2:-latest}
        docker build -t "$name:$tag" .
        echo ""
        echo "Built  $name:$tag"
        echo "Run    img-run $name $tag"
      '';
      description = "Build a Docker image from ./Dockerfile: img-build <name> [tag]";
    };
    img-run = {
      exec        = ''
        name=''${1:?Usage: img-run <image-name> [tag]}
        tag=''${2:-latest}
        docker run --rm -it "$name:$tag"
      '';
      description = "Run a container interactively: img-run <name> [tag]";
    };
    img-push = {
      exec        = ''
        name=''${1:?Usage: img-push <registry/image-name> [tag]}
        tag=''${2:-latest}
        docker push "$name:$tag"
      '';
      description = "Push image to registry: img-push <registry/name> [tag]";
    };

    # ── Playwright browser install (run once) ─────────────────────────────
    browser-install = {
      exec        = "playwright install chromium";
      description = "Download Playwright Chromium binary (run once after first shell entry)";
    };

  };

  # -------------------------------------------------------------------------
  # Runs every time the devenv shell is activated.
  # -------------------------------------------------------------------------
  enterShell = ''
    echo ""
    echo "Python research environment  (python $(python --version | cut -d' ' -f2))"
    echo ""
    echo "  Testing"
    echo "    py-test           run pytest (args forwarded)"
    echo "    py-lint           ruff check + format-check"
    echo "    py-fmt            ruff format"
    echo ""
    echo "  Dependencies"
    echo "    py-add <pkg>...   pip install + save to requirements.txt"
    echo "    py-reqs           freeze venv → requirements.txt"
    echo ""
    echo "  Docker"
    echo "    img-build <n> [t] build image from ./Dockerfile"
    echo "    img-run   <n> [t] run container interactively"
    echo "    img-push  <n> [t] push to registry"
    echo "    hadolint          lint Dockerfile"
    echo ""
    echo "  Playwright"
    echo "    browser-install   download Chromium (first-run)"
    echo ""
  '';
}
