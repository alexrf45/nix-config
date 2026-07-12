#nixos-rebuild
alias thoth='sudo nixos-rebuild switch --flake ".#thoth"'
alias horus='sudo nixos-rebuild switch --flake ".#horus"'

#day to day
alias r='. ~/.zshrc'
alias h='cd ~'
alias v='nvim'
alias config='v ~/.vimrc'
alias q='exit'
alias edit='nvim'
alias c="clear"
alias get="curl -O -L"
alias dir='exa'
alias download='aria2c'
alias l="ls -lh --color=auto --group-directories-first"
alias ls="ls -h --color=auto --group-directories-first"
alias la="ls -lah --color=auto --group-directories-first"
alias lsblk="lsblk | bat -l conf -p"
alias sensors="sensors | bat -l cpuinfo -p"
#notes
alias daily='bash $HOME/.config/scripts/daily.sh'

#claude code auth
alias code-auth='export CLAUDE_CODE_OAUTH_TOKEN=$(op read "op://Private/claude_api_token/credential")'

#apps
alias spotify='spotify_player'

#web
alias tor='docker run --rm --detach --name tor --publish 127.0.0.1:9050:9050 tor:local'
#tmux & tmuxp
alias t='tmux'
alias kali='tmuxp load ~/.config/tmuxp/security.yaml'
alias dev='tmuxp load ~/.config/tmuxp/dev.yaml'

#api
alias weather='curl https://wttr.in'
alias public='curl wtfismyip.com/text'

#vpn
alias htb='sudo openvpn ~/.config/openvpn/lab_fr3d1eeT.ovpn'
alias vpn='sudo openvpn ~/.config/openvpn/us-ny-599.protonvpn.udp.ovpn'


#python3

alias py='python3'
alias py-virt='python3 -m venv ./venv && source ./venv/bin/activate'
alias freeze='pip freeze > requirements.txt'
alias py-install='pip install -r requirements.txt'
alias py-list='pipx list | grep package'
