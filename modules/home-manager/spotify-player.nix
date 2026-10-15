{...}: {
  # ---------------------------------------------------------------------------
  # spotify_player application config.
  #
  # Ported from the previously hand-managed ~/.config/spotify-player/app.toml
  # (unchanged since 2026-07-03). The app only ever reads this file — all mutable
  # state lives in ~/.cache/spotify-player — so rendering it read-only from the
  # Nix store is safe. Runtime overrides are still available per-invocation via
  # `spotify_player -o key=value`.
  #
  # IMPORT SCOPE: thoth only. The client ID is read from a sops secret declared
  # in modules/nixos/spotify-player.nix, whose sopsFile is secrets/thoth.yaml.
  # Before importing this on horus, give horus an equivalent secret or the
  # client_id_command below resolves to nothing.
  #
  # NOTE ON client_id_command: the ID is deliberately NOT inlined here. This repo
  # is public and the Nix store is world-readable on a multi-user system, so a
  # literal ID would leak to both the moment this file is rendered.
  # ---------------------------------------------------------------------------
  xdg.configFile."spotify-player/app.toml".text = ''
    theme = "guts"
    client_id_command = { command = "cat", args = ["/run/secrets/spotify-client-id"] }
    client_port = 8080
    login_redirect_uri = "http://127.0.0.1:8989/login"
    playback_format = """
    {status} {track} • {artists} {liked}
    {album} • {genres}
    {metadata}"""
    playback_metadata_fields = [
        "repeat",
        "shuffle",
        "volume",
        "device",
    ]
    notify_timeout_in_secs = 0
    notify_transient = false
    tracks_playback_limit = 50
    app_refresh_duration_in_ms = 32
    playback_refresh_duration_in_ms = 0
    page_size_in_rows = 20
    play_icon = "▶"
    pause_icon = "▌▌"
    liked_icon = "♥"
    explicit_icon = "(E)"
    border_type = "Plain"
    progress_bar_type = "Rectangle"
    progress_bar_position = "Bottom"
    genre_num = 2
    cover_img_length = 9
    cover_img_width = 5
    cover_img_scale = 1.0
    enable_media_control = true
    enable_streaming = "Always"
    enable_audio_visualization = false
    enable_notify = true
    enable_cover_image_cache = true
    default_device = "spotify-player"
    notify_streaming_only = false
    seek_duration_secs = 5
    sort_artist_albums_by_type = false
    volume_scroll_step = 5
    enable_mouse_scroll_volume = true

    [notify_format]
    summary = "{track} • {artists}"
    body = "{album}"

    [layout]
    playback_window_position = "Top"
    playback_window_height = 6

    [layout.library]
    playlist_percent = 40
    album_percent = 40

    [device]
    name = "spotify-player"
    device_type = "speaker"
    volume = 70
    bitrate = 320
    audio_cache = false
    normalization = false
    autoplay = false
  '';

  # ---------------------------------------------------------------------------
  # Theme: guts (vossenwout/guts.nvim), matching kitty
  # (modules/home-manager/terminal.nix) and neovim (editor.nix).
  #
  # Hexes are lifted verbatim from the kitty palette so the TUI sits flush
  # against the terminal it runs in; component styles reuse guts.nvim's own
  # palette roles (gray_1 borders, gray_2 muted text, brand-green highlights).
  #
  # Referenced by `theme = "guts"` in app.toml above. A theme named
  # there but absent here falls back to `default` silently, with no error, which
  # is exactly how the previous `theme = "dracula"` line sat inert.
  # ---------------------------------------------------------------------------
  xdg.configFile."spotify-player/theme.toml".text = ''
    [[themes]]
    name = "guts"

    [themes.palette]
    background = "#101113"
    foreground = "#9f9e99"
    black = "#101113"
    red = "#93554b"
    green = "#51606a"
    yellow = "#ac7f7b"
    blue = "#697a9a"
    magenta = "#83799c"
    cyan = "#7a837c"
    white = "#9f9e99"
    bright_black = "#4a4253"
    bright_red = "#93554b"
    bright_green = "#a7d8b0"
    bright_yellow = "#e1ffe5"
    bright_blue = "#8288a0"
    bright_magenta = "#997e95"
    bright_cyan = "#879493"
    bright_white = "#a8a7a2"

    [themes.component_style]
    block_title = { fg = "#ac7f7b", modifiers = ["Bold"] }
    border = { fg = "#554a62" }
    playback_status = { fg = "#a7d8b0", modifiers = ["Bold"] }
    playback_track = { fg = "#9f9e99", modifiers = ["Bold"] }
    playback_artists = { fg = "#697a9a" }
    playback_album = { fg = "#997e95" }
    playback_genres = { fg = "#7a837c" }
    playback_metadata = { fg = "#787487" }
    playback_progress_bar = { fg = "#ac7f7b", bg = "#4a4253" }
    playback_progress_bar_unfilled = { fg = "#554a62" }
    current_playing = { fg = "#a7d8b0", modifiers = ["Bold"] }
    page_desc = { fg = "#ac7f7b", modifiers = ["Bold"] }
    playlist_desc = { fg = "#787487" }
    table_header = { fg = "#697a9a", modifiers = ["Bold"] }
    selection = { bg = "#4a4253", fg = "#9f9e99", modifiers = ["Bold"] }
    secondary_row = { bg = "#161719" }
    like = { fg = "#93554b", modifiers = ["Bold"] }
    lyrics_played = { fg = "#787487" }
    lyrics_playing = { fg = "#ac7f7b", modifiers = ["Bold"] }
    visualization = { low = "#697a9a", mid = "#a7d8b0", high = "#93554b" }
  '';
}
