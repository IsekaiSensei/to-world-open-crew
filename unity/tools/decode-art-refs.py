#!/usr/bin/env python3
"""Restore valid 512px GERTECH reference PNGs from packed_512px_pngs.json.

The GitHub MCP file API only accepts text, so committed .png blobs were
UTF-8-transcoded and are not valid PNG files. This script writes the
correct bytes over those paths (or creates them). After a clone:

    python3 tools/decode-art-refs.py

Original full-resolution plates stay on the shared box at
/workspace/gertech_shared_refs/visual_2026-11-14/
"""
from __future__ import annotations

import base64
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACK = ROOT / "Assets" / "Art" / "Refs" / "packed_512px_pngs.json"
DEST = ROOT / "Assets" / "Art" / "Refs"


def main() -> int:
    pack = json.loads(PACK.read_text(encoding="ascii"))
    ok = 0
    for entry in pack["files"]:
        raw = base64.b64decode(entry["b64"])
        digest = hashlib.sha256(raw).hexdigest()
        if digest != entry["sha256"] or len(raw) != entry["bytes"]:
            print(f"HASH MISMATCH {entry['path']}", file=sys.stderr)
            return 1
        if not raw.startswith(b"\x89PNG\r\n\x1a\n"):
            print(f"NOT A PNG {entry['path']}", file=sys.stderr)
            return 1
        dest = DEST / entry["path"]
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(raw)
        print(f"wrote {dest.relative_to(ROOT)} ({len(raw)} bytes)")
        ok += 1
    print(f"restored {ok} PNG files")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
