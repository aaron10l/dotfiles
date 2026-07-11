#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(nvim wezterm)

backup_if_needed() {
	local target="$1"
	if [[ -e "$target" && ! -L "$target" ]]; then
		local backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
		echo "Backing up existing config: $target -> $backup"
		mv "$target" "$backup"
	fi
}

link_package() {
	local package="$1"
	local source="${DOTFILES_DIR}/${package}/.config"
	local target="${HOME}/.config"

	mkdir -p "$target"

	for entry in "${source}"/*; do
		local name
		name="$(basename "$entry")"
		backup_if_needed "${target}/${name}"
		ln -sfn "$entry" "${target}/${name}"
		echo "Linked ${target}/${name} -> $entry"
	done
}

install_with_stow() {
	local package="$1"
	stow --dir="$DOTFILES_DIR" --target="$HOME" "$package"
	echo "Stowed $package"
}

main() {
	echo "Installing dotfiles from $DOTFILES_DIR"

	if command -v stow >/dev/null 2>&1; then
		for package in "${PACKAGES[@]}"; do
			install_with_stow "$package"
		done
	else
		echo "GNU stow not found; using symlinks instead."
		echo "Install stow with: brew install stow"
		for package in "${PACKAGES[@]}"; do
			link_package "$package"
		done
	fi

	echo
	echo "Done. Open a new WezTerm window and run nvim to verify."
}

main "$@"
