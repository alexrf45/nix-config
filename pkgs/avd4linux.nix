# avd4linux — native Azure Virtual Desktop client (GTK4 + WebKitGTK) with
# DoD CAC / PIV smart card redirection via FreeRDP 3. Not in nixpkgs.
#
# Upstream targets Ubuntu and Flatpak, so postPatch rewrites the FHS paths it
# probes (/usr/bin, /opt, /bin/true, ctypes find_library) to store paths. Every
# substitution uses --replace-fail: if upstream moves any of them, the build
# breaks loudly instead of shipping an app that can't find its card or client.
#
# Update procedure:
#   1. Pick a commit — upstream's tags lag their version-bump commits (v0.2.7
#      points one commit before "Bump version to 0.2.7"), so pin by rev.
#   2. Re-read src/avd4linux/{app,smartcard,session_manager}.py for new
#      hardcoded paths; this app handles the CAC PIN, so skim the diff.
#   3. nix-prefetch-url --unpack \
#        https://github.com/guitarmanusa/avd4linux/archive/<REV>.tar.gz
#      → nix hash convert --hash-algo sha256 --to sri <hash> → src.hash.
#
# Upstream: https://github.com/guitarmanusa/avd4linux

{
  lib,
  python3Packages,
  fetchFromGitHub,
  wrapGAppsHook4,
  gobject-introspection,
  gtk4,
  libadwaita,
  webkitgtk_6_0,
  glib-networking,
  freerdp,
  pcsclite,
  opensc,
  gnutls,
  bubblewrap,
  coreutils,
  glibc,
}:

python3Packages.buildPythonApplication {
  pname = "avd4linux";
  version = "0.2.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "guitarmanusa";
    repo = "avd4linux";
    rev = "6e499b47a6dd530dd20b04678e4bcfc161cf819f";
    hash = "sha256-tPtf8aNy3vd/wVM+o5Rtx4WW6tzDBYjdsFE5xkp9FaQ=";
  };

  postPatch = ''
    # WebKit sandbox probe runs `bwrap ... /bin/true`; NixOS has no /bin/true,
    # so the probe would fail and the app would refuse to start.
    substituteInPlace src/avd4linux/app.py \
      --replace-fail '"/bin/true"' '"${coreutils}/bin/true"'

    # ctypes.util.find_library can't see the store; pin the PC/SC client lib.
    # Same pcsclite as services.pcscd, so the client/daemon protocol matches.
    substituteInPlace src/avd4linux/smartcard.py \
      --replace-fail 'U.find_library("pcsclite")' \
                     '"${lib.getLib pcsclite}/lib/libpcsclite.so.1"' \
      --replace-fail 'shutil.which("p11tool")' '"${lib.getBin gnutls}/bin/p11tool"' \
      --replace-fail 'p11tool_path.startswith(("/usr/bin", "/bin", "/usr/local/bin"))' \
                     'p11tool_path.startswith("${builtins.storeDir}/")' \
      --replace-fail '"/app/lib/opensc-pkcs11.so",  # Flatpak' \
                     '"${opensc}/lib/opensc-pkcs11.so",'

    # Point the "custom build" slot at our FreeRDP. nixpkgs installs it as
    # `xfreerdp`, not `xfreerdp3`, so PATH lookup alone would miss it.
    substituteInPlace src/avd4linux/session_manager.py \
      --replace-fail '"/opt/freerdp3-cam/bin/xfreerdp3",' '"${freerdp}/bin/xfreerdp",'
  '';

  build-system = [ python3Packages.setuptools ];

  nativeBuildInputs = [
    wrapGAppsHook4
    gobject-introspection
  ];

  buildInputs = [
    gtk4
    libadwaita
    webkitgtk_6_0
    # GIO TLS backend — WebKit's client-certificate (CBA) handshake goes through
    # it, and from there to p11-kit → /etc/pkcs11/modules/opensc.module.
    glib-networking
  ];

  dependencies = [ python3Packages.pygobject3 ];

  # One wrapper, not two: fold the GApps env (typelibs, GIO modules, schemas)
  # into the Python wrapper. bwrap is needed by the sandbox probe; ldd by the
  # FreeRDP MS-RDPECAM capability check.
  #
  # OPENSC_CONF: a DoD CAC carries both CAC and PIV applets, and stock OpenSC
  # may bind either driver — the same card then shows up as two different
  # tokens (manufacturer=piv_II vs. "Common Access Card", different serials).
  # The app picks its cert URI in one process and WebKit resolves it via p11-kit
  # in another; if the drivers differ, GIO fails with "The requested data were
  # not available" and the PIN prompt never appears. Upstream's opensc.conf
  # pins PIV-II, but only the Flatpak applied it. Scoped to this app (and the
  # WebKit/FreeRDP children that inherit it); SSH/Firefox keep the system config.
  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --prefix PATH : ${lib.makeBinPath [ bubblewrap (lib.getBin glibc) ]}
      --set-default OPENSC_CONF $out/etc/opensc.conf
    )
  '';

  postInstall = ''
    install -Dm644 data/org.avd4linux.AVD4Linux.desktop -t $out/share/applications
    install -Dm644 data/org.avd4linux.AVD4Linux.svg -t $out/share/icons/hicolor/scalable/apps
    install -Dm644 data/org.avd4linux.AVD4Linux.metainfo.xml -t $out/share/metainfo
    install -Dm644 data/opensc.conf -t $out/etc
  '';

  nativeCheckInputs = [ python3Packages.unittestCheckHook ];
  unittestFlagsArray = [ "-s" "tests" "-t" "." ];
  # Importing app.py runs the bwrap userns probe, which the Nix build sandbox
  # can't satisfy. Tests only — the installed wrapper keeps WebKit's sandbox.
  # browser.py also creates its webdata dir under $HOME at import time.
  preCheck = ''
    export WEBKIT_DISABLE_SANDBOX_THIS_IS_DANGEROUS=1
    export HOME=$TMPDIR
  '';

  # app/window/browser initialise GTK at import time, so only check the modules
  # that don't need a display — notably the compiled PIN bridge.
  pythonImportsCheck = [
    "avd4linux._pin_bridge"
    "avd4linux.smartcard"
    "avd4linux.session_manager"
  ];

  meta = {
    description = "Native Azure Virtual Desktop client with DoD CAC / PIV smart card redirection";
    homepage = "https://github.com/guitarmanusa/avd4linux";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "avd4linux";
  };
}
