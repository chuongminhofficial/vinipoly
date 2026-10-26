#!/usr/bin/env bash
# ============================================================================
# ONE-CLICK GITHUB PUSH SCRIPT FOR VINIPOLY DRM (Linux / macOS / Git Bash)
# ============================================================================
set -e

echo "=================================================================="
echo "  VINIPOLY DRM — OFFICIAL GITHUB REPOSITORY PUBLISHER"
echo "=================================================================="

if [ -z "$1" ]; then
  read -p "Enter your GitHub Repository URL (e.g. https://github.com/username/vinipoly-drm.git): " REPO_URL
else
  REPO_URL="$1"
fi

if [ -z "$REPO_URL" ]; then
  echo "[Error] GitHub Repository URL is required."
  exit 1
fi

if [ ! -d ".git" ]; then
  git init
  git branch -M main
fi

git add .
git status --short

if ! git diff --cached --quiet; then
  git commit -m "feat: release ViniPoly DRM Enterprise PHP Protection Suite & Bilingual Docs (v1.1.3)"
fi

if git remote | grep -q "^origin$"; then
  git remote set-url origin "$REPO_URL"
else
  git remote add origin "$REPO_URL"
fi

echo "Pushing to $REPO_URL (branch: main)..."
git push -u origin main
echo "Done! Your ViniPoly DRM repository is now live on GitHub."
