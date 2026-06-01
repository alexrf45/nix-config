# Option declarations for the security toolkit. Imported by BOTH the NixOS
# module (modules/security/nixos.nix) and the Home Manager module
# (modules/security/home.nix) so the toggle surface stays identical no matter
# where the packages are installed.
{ lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
  flag = description: mkOption {
    inherit description;
    type = types.bool;
    default = false;
    example = true;
  };
in
{
  options.securityLab = {
    enable = mkEnableOption "the security research toolkit";

    # ---- Offensive / red-team -------------------------------------------
    # Categories mirror the SCRT sources/ layout.
    offensive = {
      all = flag "Enable every offensive category at once.";
      network = flag "Network discovery & recon (nmap, masscan, snmp, proxychains, ...).";
      web = flag "Web app testing & bug bounty (ffuf, sqlmap, nuclei, subfinder, ...).";
      activeDirectory = flag "Active Directory & SMB (netexec, impacket, bloodhound, kerbrute, ...).";
      osint = flag "OSINT & recon (theHarvester, recon-ng, cewl, exiftool, ...).";
      passwords = flag "Password cracking & brute force (hashcat, john, hydra, crunch, ...).";
      pivoting = flag "Tunneling & pivoting (chisel, ligolo-ng, sshuttle, ...).";
      privesc = flag "Privilege escalation & post-exploitation (pspy, metasploit, ...).";
      exploitation = flag "Exploitation frameworks & databases (metasploit, exploitdb).";
      ctf = flag "CTF: pwn / rev / forensics / crypto (gdb+pwndbg, radare2, pwntools, volatility3, ...).";
      wireless = flag "Wireless attacks (aircrack-ng, bettercap, kismet, ...).";
    };

    # ---- Defensive / blue-team ------------------------------------------
    defensive = {
      all = flag "Enable every defensive category at once.";
      ids = flag "Network IDS / traffic analysis (suricata, zeek).";
      forensics = flag "Disk & memory forensics / DFIR (sleuthkit, volatility3, testdisk, ...).";
      malwareAnalysis = flag "Static & dynamic malware analysis (yara, clamav, radare2, ...).";
      monitoring = flag "Packet capture & network monitoring (wireshark, termshark, ngrep, lnav, ...).";
      hardening = flag "Host auditing & vuln scanning (lynis, rkhunter, trivy, grype, ...).";
    };

    # ---- Cross-cutting ---------------------------------------------------
    secrets = flag "Crypto & secret handling (age, sops, gnupg, step-cli, openssl).";

    extras = mkEnableOption ''
      additional tools whose nixpkgs attribute names should be verified with
      `nix search nixpkgs <name>` before enabling. These are kept opt-in so the
      default configuration always evaluates cleanly
    '';
  };
}
