# love2d-demos Grounding Instructions

This repo contains multiple small LÖVE projects. When planning or implementing features that depend on LÖVE API semantics, prioritize the offline LÖVE docs store in the sibling `love2d-skills` repo.

## Grounding rules (use for planning + implementation)
1. Prefer API facts from `../love2d-skills/docs/love-api/` (the locally stored LÖVE reference).
2. If you need authoritative function signatures, parameter meaning, or return values, use the local retrieval CLI:
   - `python ../love2d-skills/tools/love2d_docs_query.py --project . --symbol love.graphics.printf`
3. When you paste or summarize retrieved docs, include the tool’s citation line (`Citation: [...]`).
4. If you’re unsure which LÖVE version applies, pass `--project .` so the CLI can do best-effort detection (via `love.conf(t)` / `t.version` in the project); otherwise it falls back to `11.5`.

## Workflow shortcut
When implementing a LÖVE API call (e.g. `love.graphics.*`, `love.keypressed`, `love.filesystem.*`), run the query CLI for that exact symbol first, then code from the retrieved snippet.

