#!/usr/bin/env bash
# bootstrap.sh — set up kaito387/dots on a fresh machine
# Usage: bash bootstrap.sh

set -euo pipefail

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── helpers ──────────────────────────────────────────────────────────────────

info()    { printf '\e[1;34m==> %s\e[0m\n' "$*"; }
success() { printf '\e[1;32m  ✓ %s\e[0m\n' "$*"; }
warn()    { printf '\e[1;33m  ! %s\e[0m\n' "$*"; }
die()     { printf '\e[1;31mERROR: %s\e[0m\n' "$*" >&2; exit 1; }

# Back up a file/dir and replace it with a symlink.
# link_file <source> <target>
link_file() {
    local src="$1" dst="$2"
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
        success "already linked: $dst"
        return
    fi
    if [[ -e "$dst" || -L "$dst" ]]; then
        local backup="${dst}.bak.$(date +%Y%m%d%H%M%S)"
        warn "backing up $dst → $backup"
        mv "$dst" "$backup"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    success "linked: $dst → $src"
}

# ── OS detection ──────────────────────────────────────────────────────────────

OS="$(uname -s)"
case "$OS" in
    Linux)  PLATFORM=linux ;;
    Darwin) PLATFORM=macos ;;
    *)      die "Unsupported OS: $OS" ;;
esac

# ── dependency checks ─────────────────────────────────────────────────────────

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "'$1' is required but not installed. Install it and re-run."
}

need_cmd git
need_cmd zsh
need_cmd tmux

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────

info "Oh My Zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    success "already installed"
else
    RUNZSH=no CHSH=no sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    success "installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ── Powerlevel10k ─────────────────────────────────────────────────────────────

info "Powerlevel10k theme"
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
if [[ -d "$P10K_DIR" ]]; then
    success "already installed"
else
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    success "installed"
fi

# ── zsh plugins ───────────────────────────────────────────────────────────────

install_plugin() {
    local name="$1" url="$2"
    local dir="$ZSH_CUSTOM/plugins/$name"
    info "plugin: $name"
    if [[ -d "$dir" ]]; then
        success "already installed"
    else
        git clone --depth=1 "$url" "$dir"
        success "installed"
    fi
}

install_plugin zsh-syntax-highlighting \
    https://github.com/zsh-users/zsh-syntax-highlighting.git
install_plugin zsh-autosuggestions \
    https://github.com/zsh-users/zsh-autosuggestions.git

# ── optional tools ────────────────────────────────────────────────────────────

info "Optional tools"

if command -v eza >/dev/null 2>&1; then
    success "eza: already installed"
else
    warn "eza not found — install it for 'ls' aliases (https://github.com/eza-community/eza)"
fi

if command -v zoxide >/dev/null 2>&1; then
    success "zoxide: already installed"
else
    warn "zoxide not found — install it for the 'cd' alias (https://github.com/ajeetdsouza/zoxide)"
fi

# ── symlink dotfiles ──────────────────────────────────────────────────────────

info "Symlinking dotfiles"
link_file "$DOTS/zsh/zshrc"              "$HOME/.zshrc"
link_file "$DOTS/tmux/tmux.conf"         "$HOME/.tmux.conf"
link_file "$DOTS/tmux/clipboard-copy.sh" "$HOME/.tmux/clipboard-copy.sh"
chmod +x "$DOTS/tmux/clipboard-copy.sh"

# ── export DOTS in ~/.zshenv ──────────────────────────────────────────────────

info "Exporting DOTS in ~/.zshenv"
ZSHENV="$HOME/.zshenv"
if grep -qF "export DOTS=" "$ZSHENV" 2>/dev/null; then
    # Update existing line
    sed -i.bak "s|export DOTS=.*|export DOTS=\"$DOTS\"|" "$ZSHENV"
    success "updated DOTS in $ZSHENV"
else
    printf '\nexport DOTS="%s"\n' "$DOTS" >> "$ZSHENV"
    success "added DOTS to $ZSHENV"
fi

# ── make scripts executable ───────────────────────────────────────────────────

info "Making scripts executable"
chmod +x "$DOTS/tmux/acm.sh"
chmod +x "$DOTS/tmux/clipboard-copy.sh"
success "tmux/acm.sh, tmux/clipboard-copy.sh"

# ── done ──────────────────────────────────────────────────────────────────────

printf '\n\e[1;32mBootstrap complete!\e[0m\n'
echo "  • Start a new zsh session (or run: exec zsh) to apply changes."
echo "  • Run 'p10k configure' to set up your prompt."
echo "  • Use '$DOTS/tmux/acm.sh' to launch the ACM tmux session."
