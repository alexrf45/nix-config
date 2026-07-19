{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nmap
    netcat-gnu
    tcpdump
    gobuster
    ffuf
    sqlmap
    hydra
    john             # John the Ripper
    hashcat
    burpsuite        # unfree; from unstable for latest
    metasploit       # unfree
    binutils         # objdump, strings, nm
    gef              # GDB enhancement for CTF
    pwntools         # CTF toolkit
    gdb
  ];
}
