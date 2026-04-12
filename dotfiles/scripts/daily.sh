#!/bin/bash

# Define your Obsidian vault path and daily notes folder
VAULT_PATH="$HOME/notes/fr3d/scratch"
DAILY_FOLDER="daily" # Or whatever you named your daily notes folder

# Get today's date in YYYY-MM-DD format
TODAY=$(date +%Y-%m-%d)

# Construct the full path to the daily note
DAILY_NOTE_DIR="$VAULT_PATH"
DAILY_NOTE_PATH="$DAILY_NOTE_DIR/$TODAY-scratch.md"

# Create directories if they don't exist
mkdir -p "$DAILY_NOTE_DIR"

# Create the daily note file if it doesn't exist
if [ ! -f "$DAILY_NOTE_PATH" ]; then
  touch "$DAILY_NOTE_PATH"
fi

# Open the daily note in Neovim
nvim "$DAILY_NOTE_PATH"
