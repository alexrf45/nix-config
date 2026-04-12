cheat-code() {

  curl cheat.sh/"$1" | bat
}

color-log() {
  tail -f "$1" | grep --color=always -E "$2|$"
}

http() {
  busybox httpd -h "$HOME/webserver" -p "$1"
}

pdf() {

  zathura "$1" &
}

extract() {
  if [ -f "$1" ]; then
    case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) rar x "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) uncompress "$1" ;;
    *.apk) uncompress "$1" ;;
    *.bz2) uncompress "$1" ;;
    *.tar.gz) uncompress "$1" ;;
    *.tar.lz) uncompress "$1" ;;
    *.war) uncompress "$1" ;;
    *.xz) xz -d -v "$1" ;;
    *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

up() {
  for i in $(seq 1 $1); do
    cd ../
  done
}

virtual_env() {
  mkdir "$1" &&
    cd "$1" &&
    virtualenv .venv &&
    source .venv/bin/activate
}

aws_cli() {
  docker run --rm \
    -it \
    -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
    -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
    cgr.dev/chainguard/aws-cli:latest "$*"
}

s3-file-size() {
  aws s3 ls --summarize \
    --human-readable \
    --recursive "$1" | tail -2
}

timestamp() {
  date +%Y%m%d-%T
}

git-new() {
  [ -d "$1" ] || mkdir "$1" &&
    cd "$1" &&
    git init &&
    touch .gitignore &&
    git add .gitignore &&
    git commit -m "Add .gitignore."
}

web-server() {
  miniserve \
    -t "fr3d" \
    -v \
    -F \
    -H \
    -c monokai \
    -p 8001 \
    --header "Cache-Control:no-cache" \
    --auth-file "$HOME/.local/auth.txt" \
    --tls-cert "$HOME/.local/certs/cert.pem" \
    --tls-key "$HOME/.local/certs/key.pem" \
    -u
}

cert-gen() {
  mkcert -key-file "$HOME/.local/$1-key.pem" -cert-file "$HOME/.local/$1-cert.pem" localhost
}

encrypt_age() {
  age \
    --passphrase \
    --output "$1.enc" \
    "$2"
}

decrypt_age() {
  age -d \
    "$1" >"$2"
}

nb() {
  aws s3 sync \
    --delete ~/notes/notes-vault/. \
    s3://notes-backup-primary
}

nb1() {
  aws s3 sync \
    --delete ~/notes/fr3d/. \
    s3://fr3d-backup-2025
}

# k9s() {
#   docker run \
#     --rm --net=host -it \
#     -v "$KUBECONFIG:/root/.kube/config" \
#     -v "/home/fr3d/.config/k9s:/root/.config/k9s" \
#     derailed/k9s:latest "$@"
# }

tf-docs() {
  docker run --rm \
    --volume "$(pwd):/terraform-docs" \
    -u "$(id -u)" quay.io/terraform-docs/terraform-docs:0.20.0 markdown /terraform-docs
}

doc2md() {
  myfilename="$1"
  pandoc \
    -t markdown_strict \
    --extract-media="./attachments/$myfilename" \
    "$myfilename.docx" \
    -o "$myfilename.md"
}

kube() {
  local env="${1:-dev}"
  shift
  op run --env-file="$HOME/home-0ps.com/terraform/${env}/${env}.env" -- \
    bash -c 'kubectl --kubeconfig <(printenv KUBECONFIG_DATA) "$@"' _ "$@"
}

k9s-op() {
  local env="${1:-dev}"
  shift
  op run --env-file="$HOME/home-0ps.com/terraform/${env}/${env}.env" -- \
    bash -c 'k9s --kubeconfig <(printenv KUBECONFIG_DATA) "$@"' _ "$@"
}

kube-op() {
  local env="${1:-dev}"
  local cmd="${2}"
  shift 2
  local kubedata
  kubedata=$(op read "$(grep KUBECONFIG_DATA "$HOME/home-0ps.com/terraform/${env}/${env}.env" | cut -d= -f2)" --no-newline)

  tmpfile=$(mktemp /dev/shm/kubeconfig.XXXXXX)
  chmod 600 "$tmpfile"
  trap 'rm -f $tmpfile' EXIT INT TERM
  echo "$kubedata" >"$tmpfile"
  export KUBECONFIG="$tmpfile"

  "$cmd" "$@"
}

# Usage:
# kube-op dev kubectl get nodes
# kube-op prod k9s
# kube-op test helm list -A
