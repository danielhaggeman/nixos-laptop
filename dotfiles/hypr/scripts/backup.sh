#!/usr/bin/env zsh
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

# SSH remote for automatic push
REPO_URL="git@github.com:danielhaggeman/nixos-laptop.git"

# -------------------------
# PREPARE REPO
# -------------------------

echo "-> Preparing repo"
mkdir -p "$DOTFILES_DIR"
rm -rf "$REPO_ROOT"/* || true

# -------------------------
# COPY ~/dotfiles (flatten symlinks, skip known recursive symlinks)
# -------------------------

echo "-> Copying ~/dotfiles (flatten symlinks)"
rsync -aL \
  --exclude ".git" \
  --exclude "nnn/nnn" \
  "$SRC_HOME_DOTFILES/" "$DOTFILES_DIR/"

# -------------------------
# COPY .zshrc
# -------------------------

echo "-> Copying .zshrc"
cp -f "$SRC_ZSHRC" "$DOTFILES_DIR/.zshrc"

# -------------------------
# COPY /etc/nixos (flatten symlinks, skip hardware-configuration & scripts)
# -------------------------

echo "-> Copying /etc/nixos (flatten symlinks)"
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
  echo "-> Initializing new git repository"
  git init
  git remote add origin "$REPO_URL"
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

# Set branch to main
git branch -M main

# Push via SSH (first-time push handled automatically)
git push -u origin main --force

echo "==> DONE"