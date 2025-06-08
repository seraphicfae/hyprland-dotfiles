#!/bin/bash

PLUGIN_DIR="$HOME/.config/zsh/plugins"

echo "🔄 Updating Zsh plugins in $PLUGIN_DIR"
echo

for plugin in "$PLUGIN_DIR"/*; do
  if [ -d "$plugin/.git" ]; then
    echo "➡️  Updating $(basename "$plugin")..."
    git -C "$plugin" pull --ff-only || echo "⚠️  Failed to update $(basename "$plugin")"
  else
    echo "⚠️  Skipping $(basename "$plugin") — not a git repo"
  fi
done

echo
echo "✅ All done!"