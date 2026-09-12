{ ... }:
{
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
    theme = "gruvbox-material"
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
  # Theme: gruvbox-material dark soft (sainnhe/gruvbox-material), matching
  # kitty (modules/home-manager/terminal.nix) and neovim (editor.nix).
  #
  # Hexes are lifted verbatim from the kitty palette so the TUI sits flush
  # against the terminal it runs in. Upstream ships a `gruvbox_dark`, but that is
  # classic gruvbox (#282828 / #ebdbb2), not the material soft variant used here.
  #
  # Referenced by `theme = "gruvbox-material"` in app.toml above. A theme named
  # there but absent here falls back to `default` silently, with no error, which
  # is exactly how the previous `theme = "dracula"` line sat inert.
  # ---------------------------------------------------------------------------
  xdg.configFile."spotify-player/theme.toml".text = ''
    [[themes]]
    name = "gruvbox-material"

    [themes.palette]
    background = "#32302f"
    foreground = "#d4be98"
    black = "#665c54"
    red = "#ea6962"
    green = "#a9b665"
    yellow = "#d8a657"
    blue = "#7daea3"
    magenta = "#d3869b"
    cyan = "#89b482"
    white = "#d4be98"
    bright_black = "#928374"
    bright_red = "#ea6962"
    bright_green = "#a9b665"
    bright_yellow = "#d8a657"
    bright_blue = "#7daea3"
    bright_magenta = "#d3869b"
    bright_cyan = "#89b482"
    bright_white = "#d4be98"

    [themes.component_style]
    block_title = { fg = "#d8a657", modifiers = ["Bold"] }
    border = { fg = "#504945" }
    playback_status = { fg = "#a9b665", modifiers = ["Bold"] }
    playback_track = { fg = "#d4be98", modifiers = ["Bold"] }
    playback_artists = { fg = "#7daea3" }
    playback_album = { fg = "#d3869b" }
    playback_genres = { fg = "#89b482" }
    playback_metadata = { fg = "#928374" }
    playback_progress_bar = { fg = "#d8a657", bg = "#45403d" }
    playback_progress_bar_unfilled = { fg = "#504945" }
    current_playing = { fg = "#a9b665", modifiers = ["Bold"] }
    page_desc = { fg = "#d8a657", modifiers = ["Bold"] }
    playlist_desc = { fg = "#928374" }
    table_header = { fg = "#7daea3", modifiers = ["Bold"] }
    selection = { bg = "#45403d", fg = "#d4be98", modifiers = ["Bold"] }
    secondary_row = { bg = "#3c3836" }
    like = { fg = "#ea6962", modifiers = ["Bold"] }
    lyrics_played = { fg = "#928374" }
    lyrics_playing = { fg = "#d8a657", modifiers = ["Bold"] }
    visualization = { low = "#7daea3", mid = "#a9b665", high = "#ea6962" }
  '';
}
