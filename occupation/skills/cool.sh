#!/usr/bin/env bash
# cool — NTU COOL (Canvas LMS) scanner
# Delegates to aide-skill cool which has the working ADFS login
# usage: cool [courses|assignments|grades|todos|summary|announcements|scan|submissions]
set -euo pipefail

CMD="${1:-scan}"

exec aide-skill cool "$CMD"
