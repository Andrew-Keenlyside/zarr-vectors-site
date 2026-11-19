#!/usr/bin/env bash
# Build the whole Zarr Vectors site into _site/: the front door at the root, and
# the spec, Python and tools docs (from the Allen repos named in sources.txt)
# under their own paths, all in the shared look from theme/.
#
#   ./build.sh                    # site served from /  (local preview)
#   ZV_BASE=/zarr-vectors-site/ ./build.sh   # site served from that path (GitHub Pages)
#
# Needs: git, and a Python with sphinx<9, furo, myst-parser, sphinx-copybutton,
# sphinx-argparse, pyyaml and the zarr-vectors package (for the API pages).
set -euo pipefail
ROOT=$(cd "$(dirname "$0")" && pwd)
BASE=${ZV_BASE:-/}
OUT=${OUT:-$ROOT/_site}
SRC=$ROOT/.src

export ZV_SITE_URLS=$(cat <<JSON
{"home": "${BASE}", "spec": "${BASE}spec/", "python": "${BASE}python/", "tools": "${BASE}tools/",
 "ecosystem": "${BASE}ecosystem.html"}
JSON
)

rm -rf "$OUT"; mkdir -p "$OUT" "$SRC"

grep -v '^\s*#' "$ROOT/sources.txt" | while read -r path repo ref docs key; do
  [ -n "$path" ] || continue
  dir=$SRC/${repo#*/}
  if [ -d "$dir/.git" ]; then
    git -C "$dir" fetch -q --depth 1 origin "$ref" && git -C "$dir" checkout -q -f FETCH_HEAD
  else
    git clone -q --depth 1 --branch "$ref" "https://github.com/$repo.git" "$dir"
  fi
  # give the site the shared look: two lines at the end of its own conf.py (in this build copy only)
  cat >> "$dir/$docs/conf.py" <<PY

# -- added by zarr-vectors-site/build.sh ----------------------------------
import sys as _zv_sys; _zv_sys.path.insert(0, "$ROOT/theme")
import zv_site; zv_site.apply(globals(), "$key")
PY
  echo "building $path from $repo@$(git -C "$dir" rev-parse --short HEAD)"
  sphinx-build -q -b html "$dir/$docs" "$OUT/$path"
  git -C "$dir" checkout -q -- "$docs/conf.py"
done

echo "building the front door"
sphinx-build -q -b html "$ROOT/hub" "$OUT"
# the front door's own page replaces the Sphinx index
cp "$ROOT/hub/_generated/home.html" "$OUT/index.html"
cp "$ROOT/hub/home/home.css" "$ROOT/hub/home/home.js" "$OUT/"
touch "$OUT/.nojekyll"
echo "done: $OUT"
