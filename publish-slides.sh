#!/usr/bin/env bash
# Publish the built, self-contained lecture decks from the private course repo
# into this public site's slides/ folder.
#
# Source of truth: ../aca-monsoon26/lectures/<folder>/<folder>.html — each is a
# single self-contained HTML built by that folder's ./build-html.sh (presenter
# notes stripped, images inlined as data URIs). This copies them under the
# *site* lecture numbers, which differ from the folder names: the course opens
# with two Foundations lectures (L1, L2) taught by Priyesh Shukla, so the
# Bluespec/RISC-V block starts at L3.
#
#   lectures/L1-digital-circuits-bsv  ->  slides/L3.html
#   lectures/L2-tiny-processor        ->  slides/L4.html
#   lectures/L3-drum-processor        ->  slides/L5.html
#
# The Foundations decks (L1, L2) are PDFs authored outside the course repo.
# They live at slides/L1.pdf and slides/L2.pdf and are NOT managed here — copy
# a new version straight over them and commit.
#
# Also publishes the hand-written interactive worksheets (worksheets/<name>.html),
# which have no build step -- they are checked into the lecture folder as one
# self-contained file.
#
# Usage:
#   ./publish-slides.sh              # copy decks that are newer than published
#   ./publish-slides.sh --build      # run each deck's build-html.sh first
#   COURSE_REPO=/path ./publish-slides.sh
set -euo pipefail

WEB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${COURSE_REPO:-$WEB_DIR/../aca-monsoon26}"
DST="$WEB_DIR/slides"

# folder-in-course-repo : published-name
# Older folders are named by authoring order, so the map is not the identity;
# L6 onward are named by course number and map straight across.
DECKS=(
  "L1-digital-circuits-bsv:L3"
  "L2-tiny-processor:L4"
  "L3-drum-processor:L5"
  "L6-pipeline-hazards:L6"
)

# Hand-written interactive worksheets: a single self-contained HTML checked into
# the lecture folder, with no build step. Published under worksheets/.
WORKSHEETS=(
  "L6-pipeline-hazards:L6"
  "L7-scoreboarding:L7"
)

BUILD=0
[[ "${1:-}" == "--build" ]] && BUILD=1

if [[ ! -d "$SRC/lectures" ]]; then
  echo "error: no lectures/ at $SRC" >&2
  echo "       set COURSE_REPO=/path/to/aca-monsoon26 and retry." >&2
  exit 1
fi

mkdir -p "$DST"
for entry in "${DECKS[@]}"; do
  folder="${entry%%:*}"
  name="${entry##*:}"
  dir="$SRC/lectures/$folder"
  deck="$dir/$folder.html"

  if [[ ! -d "$dir" ]]; then
    echo "skip: $folder (no such lecture folder)"
    continue
  fi

  if (( BUILD )); then
    if [[ -x "$dir/build-html.sh" ]]; then
      echo "build: $folder"
      ( cd "$dir" && ./build-html.sh >/dev/null )
    else
      echo "warn: $folder has no build-html.sh; using the existing deck" >&2
    fi
  fi

  if [[ ! -f "$deck" ]]; then
    echo "skip: $folder (not built — run with --build)" >&2
    continue
  fi

  # A deck older than its own source is stale; say so rather than publishing silently.
  if [[ -f "$dir/slides.md" && "$dir/slides.md" -nt "$deck" ]]; then
    echo "warn: $folder.html is older than slides.md — rebuild with --build" >&2
  fi

  cp "$deck" "$DST/$name.html"
  echo "publish: $folder.html -> slides/$name.html ($(( $(wc -c < "$deck") / 1024 )) KB)"
done

# ---- worksheets: no build step, just a self-contained file to copy across
WDST="$WEB_DIR/worksheets"
for entry in "${WORKSHEETS[@]}"; do
  folder="${entry%%:*}"
  name="${entry##*:}"
  ws="$SRC/lectures/$folder/worksheet.html"

  if [[ ! -f "$ws" ]]; then
    echo "skip: $folder has no worksheet.html"
    continue
  fi
  mkdir -p "$WDST"
  cp "$ws" "$WDST/$name.html"
  echo "publish: $folder/worksheet.html -> worksheets/$name.html ($(( $(wc -c < "$ws") / 1024 )) KB)"
done

echo
echo "Done. Review, then:  git add -A && git commit -m 'Publish slides' && git push"
