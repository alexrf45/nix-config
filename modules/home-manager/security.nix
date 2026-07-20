{ pkgs, outputs, ... }:
{
  # -----------------------------------------------------------------------
  # Pentest/CTF ergonomics — always present regardless of which devShell
  # (nix develop .#web|.#ad|.#forensics|.#ctf) is active. The bulk of the
  # tooling lives in those shells; this module is just the muscle memory.
  # -----------------------------------------------------------------------

  home.packages = [
    # proxychains is small and used often enough to keep on the host.
    pkgs.proxychains-ng

    # `scrt` — scaffold/manage engagement directories (scrt new|ls|fix). Built
    # from pkgs-sec, so it pins to the flake's resolved toolset at rebuild time.
    outputs.packages.${pkgs.stdenv.hostPlatform.system}.scrt
  ];

  # proxychains-ng config — mirrors SCRT's resources/proxychains.conf.
  # ~/.proxychains/proxychains.conf is checked by proxychains-ng before the
  # system path, so this works without PROXYCHAINS_CONF_FILE. Default assumes a
  # SOCKS5 proxy on 127.0.0.1:1080 (e.g. `ssh -D 1080 <pivot>` or a chisel
  # client). Edit [ProxyList] for your engagement.
  home.file.".proxychains/proxychains.conf".text = ''
    dynamic_chain
    proxy_dns
    remote_dns_subnet 224
    tcp_read_time_out 15000
    tcp_connect_time_out 8000

    [ProxyList]
    socks5 127.0.0.1 1080
  '';

  # Shell shortcuts. NOTE: a few reference tools that live only inside the
  # security devShells (e.g. impacket-smbserver) — run those from `nix develop`.
  programs.zsh.shellAliases = {
    serve     = "python3 -m http.server 8000";       # serve cwd over HTTP :8000
    servep    = "python3 -m http.server";            # servep <port>
    ports     = "ss -tulpn";                          # listening sockets
    myip      = "ip -4 -brief addr";
    tunip     = "ip -4 -brief addr show tun0";        # VPN tunnel IP (HTB/THM)
    nmapq     = "nmap -T4 --open";                     # quick scan
    nmapfull  = "sudo nmap -p- -T4 -sV -sC";           # full TCP + scripts
    b64d      = "base64 -d";
    b64e      = "base64";
    urldecode = "python3 -c 'import sys,urllib.parse as u; print(u.unquote(sys.argv[1]))'";
    urlencode = "python3 -c 'import sys,urllib.parse as u; print(u.quote(sys.argv[1]))'";
    smbserve  = "impacket-smbserver -smb2support share . ";  # run inside .#ad
  };
}
