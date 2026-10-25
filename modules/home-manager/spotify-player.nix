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
    theme = "posterpole"
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
  # Theme: posterpole (ilof2/posterpole.nvim), matching kitty
  # (modules/home-manager/terminal.nix) and neovim (editor.nix).
  #
  # Hexes are lifted verbatim from the kitty palette so the TUI sits flush
  # against the terminal it runs in; component styles reuse posterpole.nvim's own
  # palette roles (comment borders, special muted text, green highlights).
  #
  # Referenced by `theme = "posterpole"` in app.toml above. A theme named
  # there but absent here falls back to `default` silently, with no error, which
  # is exactly how the previous `theme = "dracula"` line sat inert.
  # ---------------------------------------------------------------------------
  xdg.configFile."spotify-player/theme.toml".text = ''
    [[themes]]
    name = "posterpole"

    [themes.palette]
    background = "#24212a"
    foreground = "#aea79c"
    black = "#2c2c30"
    red = "#a97070"
    green = "#778c73"
    yellow = "#cc9166"
    blue = "#6c7f93"
    magenta = "#b894af"
    cyan = "#8ea4a2"
    white = "#afa79d"
    bright_black = "#a5a59c"
    bright_red = "#bc8f8f"
    bright_green = "#92a38f"
    bright_yellow = "#d9ac8c"
    bright_blue = "#8a99a8"
    bright_magenta = "#ccb3c6"
    bright_cyan = "#8fa4a2"
    bright_white = "#c6c0b9"

    [themes.component_style]
    block_title = { fg = "#cc9166", modifiers = ["Bold"] }
    border = { fg = "#4d4d4d" }
    playback_status = { fg = "#92a38f", modifiers = ["Bold"] }
    playback_track = { fg = "#aea79c", modifiers = ["Bold"] }
    playback_artists = { fg = "#6c7f93" }
    playback_album = { fg = "#b894af" }
    playback_genres = { fg = "#8ea4a2" }
    playback_metadata = { fg = "#a8968a" }
    playback_progress_bar = { fg = "#cc9166", bg = "#4d4d4d" }
    playback_progress_bar_unfilled = { fg = "#4d4d4d" }
    current_playing = { fg = "#92a38f", modifiers = ["Bold"] }
    page_desc = { fg = "#cc9166", modifiers = ["Bold"] }
    playlist_desc = { fg = "#a8968a" }
    table_header = { fg = "#6c7f93", modifiers = ["Bold"] }
    selection = { bg = "#4d4d4d", fg = "#aea79c", modifiers = ["Bold"] }
    secondary_row = { bg = "#2c2c30" }
    like = { fg = "#a97070", modifiers = ["Bold"] }
    lyrics_played = { fg = "#a8968a" }
    lyrics_playing = { fg = "#cc9166", modifiers = ["Bold"] }
    visualization = { low = "#6c7f93", mid = "#92a38f", high = "#a97070" }
  '';
}
