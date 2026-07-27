#!/usr/bin/env bash
set -euo pipefail

git diff --name-only HEAD~1..HEAD
