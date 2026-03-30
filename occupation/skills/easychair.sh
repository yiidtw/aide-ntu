#!/usr/bin/env bash
# easychair — bridge to aide-skill easychair
# usage: easychair [reviews|summary|view <id>]
set -euo pipefail

CMD="${1:-summary}"
shift 2>/dev/null || true

exec aide-skill easychair "$CMD" "$@"
