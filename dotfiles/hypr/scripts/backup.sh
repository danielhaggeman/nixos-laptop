#!/usr/bin/env bash
set -euo pipefail

echo "==> Backup + Push (everything UNDER dotfiles/)"

# -------------------------
# CONFIG
# -------------------------

SRC_HOME_DOTFILES="$HOME/dotfiles"
SRC_ZSHRC="$HOME/.zshrc"
SRC_NIXOS="/etc/nixos"

REPO_ROOT="$HOME/github/nixos-laptop"
DOTFILES_DIR="$REPO_ROOT/dotfiles"

REPO_URL="https://github.com/danielhaggeman/nixos-laptop.git"

# -------------------------
# PREPARE REPO
# -------------------------

echo "-> Preparing repo"
mkdir -p "$DOTFILES_DIR"
rm -rf "$REPO_ROOT"/*

# -------------------------
# COPY ~/dotfiles (flatten symlinks)
# -------------------------

echo "-> Copying ~/dotfiles (flatten symlinks)"
rsync -aL \
  --exclude ".git" \
  "$SRC_HOME_DOTFILES/" "$DOTFILES_DIR/"

# -------------------------
# COPY .zshrc
# -------------------------

echo "-> Copying .zshrc"
cp -f "$SRC_ZSHRC" "$DOTFILES_DIR/.zshrc"

# -------------------------
# COPY /etc/nixos (flatten symlinks, skip hardware-configuration)
# -------------------------

echo "-> Copying /etc/nixos (flatten symlinks, skip broken/hardware-configuration)"
mkdir -p "$DOTFILES_DIR/nixos"

rsync -aL \
  --exclude "hardware-configuration.nix" \
  --exclude "scripts" \
  "$SRC_NIXOS/" "$DOTFILES_DIR/nixos/"

# -------------------------
# .gitignore
# -------------------------

cat <<EOF > "$REPO_ROOT/.gitignore"
dotfiles/nixos/hardware-configuration.nix

result
*.drv
*.qcow2

.ssh/
.gnupg/
.env
EOF

# -------------------------
# GIT SETUP
# -------------------------

cd "$REPO_ROOT"

if [ ! -d ".git" ]; then
  git init
  git remote add origin "$REPO_URL"
else
  git remote set-url origin "$REPO_URL"
fi

# -------------------------
# COMMIT + PUSH
# -------------------------

git add -A

if git diff --cached --quiet; then
  echo "-> No changes to commit"
else
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  git commit --no-edit -m "backup $TIMESTAMP"
fi

git branch -M main
git push -u origin main --force

echo "==> DONE"