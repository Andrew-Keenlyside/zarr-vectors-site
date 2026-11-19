# zarr-vectors-site (test)

A test of one website for the Zarr Vectors project: a front door, with the
specification, the Python library docs and the tools docs under it, all in one
shared look taken from the Zarr Vectors logo. It builds the docs straight from
the Allen repos named in `sources.txt`; nothing in those repos is changed.

| Path | What | Source |
|---|---|---|
| `/` | Front door (hand-built, with live scenes) | `hub/home/` |
| `/ecosystem.html` | Ecosystem page | `hub/` |
| `/spec/` | Specification | AllenInstitute/zarr_vectors |
| `/python/` | zarr-vectors docs | AllenInstitute/zarr-vectors-py |
| `/tools/` | zarr-vectors-tools docs | AllenInstitute/zarr-vectors-tools |

## The shared look (`theme/`)

- `zv_site.py`: each site's `conf.py` calls `zv_site.apply(globals(), "<site>")`.
  It sets Furo's colours (magenta `#e01073` from the logo, `#ff72c0` in dark
  mode), DM Sans and JetBrains Mono (bundled, OFL), the logo's mark and
  favicon, and the top bar linking the sites. Site addresses come from
  `ZV_SITE_URLS`; without it, the Allen addresses are used.
- `static/zv.css`: the top bar, sidebar, landing and ecosystem styles. It loads
  after each site's own `custom.css`.

The ecosystem lists (on the front door and its own page) are generated from `hub/ecosystem.yml`.

## The front door (`hub/home/`)

A plain page with three small 3-D scenes on canvases, no libraries (`home.js`):

- **Opening**: the logo's mark opens into the store: its cube becomes the chunk lattice, its nodes become vertices.
- **Hero**: a store of points and streamlines; a query box follows the cursor (or tours on its own) and
  lights the chunks it reads, the points inside it and the whole streamlines through it, with a live count.
- **Geometries**: one set of vertices becomes points, streamlines, a skeleton, a graph and a mesh as the
  chapters beside it scroll past (on phones it rides along the foot of the screen).
- **Pyramids**: the same points merge into bin centroids level by level.

Reduced motion skips the opening and all drifting. Light and dark follow the system, or the docs' theme switch.

## Build

```bash
pip install "sphinx>=7.2,<9" furo myst-parser sphinx-copybutton sphinx-argparse pyyaml zarr-vectors
./build.sh                                   # into _site/, served from /
python -m http.server -d _site 8000
```

On GitHub, `.github/workflows/pages.yml` builds on every push and once a day,
and deploys to Pages (Settings → Pages → Source: GitHub Actions).

## Moving to the Allen repos

Each Allen repo copies `theme/` into its `docs/`, adds the two lines to its
`conf.py`, and deploys its own Pages; the front door moves into
AllenInstitute/zarr_vectors with the spec under `/spec/`.
