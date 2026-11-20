#!/usr/bin/env bash
# Download external datasets that help join music ↔ happiness at country level.
# Requires a free Kaggle account + API token.
#
# Setup (once):
#   1. https://www.kaggle.com/settings → API → Create New Token
#   2. Save the file as ~/.kaggle/kaggle.json  (chmod 600)
#   3. source .venv/bin/activate
#   4. ./scripts/download_kaggle_datasets.sh

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RAW="$ROOT/data/raw"
mkdir -p "$RAW"

# Prefer new KGAT_ token (~/.kaggle/access_token); fall back to legacy kaggle.json
if [[ -f "$HOME/.kaggle/access_token" ]]; then
  chmod 600 "$HOME/.kaggle/access_token"
  export KAGGLE_API_TOKEN="$(tr -d '\n\r ' < "$HOME/.kaggle/access_token")"
elif [[ -f "$HOME/.kaggle/kaggle.json" ]]; then
  chmod 600 "$HOME/.kaggle/kaggle.json"
else
  echo "Missing Kaggle credentials."
  echo "Create a token at https://www.kaggle.com/settings and save it as:"
  echo "  ~/.kaggle/access_token   (KGAT_… token), or"
  echo "  ~/.kaggle/kaggle.json    (legacy username/key)"
  exit 1
fi

KAGGLE="$ROOT/.venv/bin/kaggle"
if [[ ! -x "$KAGGLE" ]]; then
  KAGGLE="kaggle"
fi

echo "==> Top Spotify Songs in 73 Countries (best join key: country + audio features)"
"$KAGGLE" datasets download -d asaniczka/top-spotify-songs-in-73-countries-daily-updated \
  -p "$RAW/spotify_73_countries" --unzip

echo "==> World Happiness Report 2020–2024 (optional richer happiness panel)"
"$KAGGLE" datasets download -d mayankkacha/world-happiness-report-2020-to-2024 \
  -p "$RAW/happiness_2020_2024" --unzip

echo "==> Spotify Top-50 musicality by country (week snapshot, 73 countries)"
"$KAGGLE" datasets download -d miquelneck/worlds-spotify-top-50-playlist-musicality-data \
  -p "$RAW/spotify_top50_musicality" --unzip

echo "Done. Files under: $RAW"
ls -lah "$RAW"/*/
