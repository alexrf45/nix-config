# Package catalog: maps each toggle category to a list of nixpkgs derivations.
#
# Every package in the non-`extras` lists is a high-confidence nixpkgs
# attribute name, so a default-enabled configuration evaluates without
# surprises. Tools whose attribute names vary across nixpkgs revisions (or that
# may be missing) live in `extras`, gated behind `securityLab.extras = true`.
#
# To add a tool: find its attribute with `nix search nixpkgs <tool>` and drop it
# into the matching category.
{ pkgs, lib }:
let
  # CTF crypto/pwn libraries are Python libs, so expose them through a single
  # interpreter rather than as loose packages.
  ctfPython = pkgs.python3.withPackages (ps: with ps; [
    pwntools
    pycryptodome
    gmpy2
    requests
  ]);
in
{
  offensive = {
    network = with pkgs; [
      nmap
      masscan
      netdiscover
      onesixtyone
      net-snmp
      socat
      tcpdump
      proxychains-ng
      swaks
      traceroute
      whois
      dnsutils # dig, nslookup, host
      netcat-gnu
      mtr
      arp-scan
      fping
    ];

    web = with pkgs; [
      ffuf
      gobuster
      feroxbuster
      dirb
      sqlmap
      nikto
      wfuzz
      whatweb
      wpscan
      nuclei
      subfinder
      amass
      katana
      dnsx
      naabu
      httprobe
      waybackurls
      unfurl
      gron
      hurl
      miniserve
      mkcert
      exiftool
    ];

    activeDirectory = with pkgs; [
      netexec # the cme / crackmapexec successor (provides `nxc`)
      impacket # secretsdump, psexec, GetUserSPNs, smbserver, ...
      bloodhound-py # python ingestor
      enum4linux-ng
      evil-winrm
      responder
      kerbrute
      samba # smbclient
      openldap # ldapsearch
    ];

    osint = with pkgs; [
      theharvester
      recon-ng
      cewl
      exiftool
    ];

    passwords = with pkgs; [
      hashcat
      hashcat-utils
      john # John the Ripper (jumbo)
      thc-hydra
      medusa
      ncrack
      crunch
      hashid
    ];

    pivoting = with pkgs; [
      chisel
      ligolo-ng
      sshuttle
      proxychains-ng
      socat
    ];

    privesc = with pkgs; [
      pspy
      metasploit
    ];

    exploitation = with pkgs; [
      metasploit
      exploitdb # searchsploit
    ];

    ctf = with pkgs; [
      gdb
      pwndbg
      radare2
      binwalk
      foremost
      steghide
      ltrace
      strace
      hexedit
      volatility3
      ghidra
      apktool
      jadx
      ctfPython
    ];

    wireless = with pkgs; [
      aircrack-ng
      wifite
      reaver
      bettercap
      kismet
    ];
  };

  defensive = {
    ids = with pkgs; [
      suricata
      zeek
    ];

    forensics = with pkgs; [
      sleuthkit
      volatility3
      foremost
      testdisk # includes photorec
      ddrescue
      binwalk
    ];

    malwareAnalysis = with pkgs; [
      yara
      clamav
      radare2
      binwalk
    ];

    monitoring = with pkgs; [
      wireshark-cli # tshark, no GUI dependency chain
      termshark
      tcpdump
      ngrep
      lnav
      goaccess
      iftop
    ];

    hardening = with pkgs; [
      lynis
      chkrootkit
      rkhunter
      trivy
      grype
      osv-scanner
    ];
  };

  secrets = with pkgs; [
    age
    sops
    gnupg
    step-cli
    openssl
  ];

  # Opt-in only: verify each attribute name before enabling securityLab.extras.
  # Many of these DO exist but their attribute names drift between nixpkgs
  # revisions, so they are quarantined here to keep the default build green.
  extras = with pkgs; [
    # --- ProjectDiscovery / web extras ---
    # httpx          # attr collides with the python HTTP client; may be `httpx`
    # notify         # projectdiscovery notify
    # go-dork
    # chaos-client

    # --- Active Directory extras ---
    # certipy-ad
    # ldapdomaindump

    # --- OSINT extras ---
    # sn0int
    # holehe
    # sherlock
    # maigret
    # h8mail

    # --- Privesc / post-ex extras ---
    # linux-exploit-suggester
    # peass-ng        # linpeas / winpeas

    # --- CTF extras ---
    # one_gadget
    # sage            # SageMath (very large)
    # rizin
    # cutter

    # --- Defensive extras ---
    # snort
    # bulk_extractor
    # capa
    # pev
    # openscap
    # aide
  ];
}
