#!/usr/bin/env bash
set -e

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[38;5;114m'
RED='\033[38;5;203m'
PURPLE='\033[38;5;141m'
BLUE='\033[38;5;117m'
PINK='\033[38;5;183m'
GRAY='\033[38;5;244m'
BOLD='\033[1m'
RESET='\033[0m'

ok()     { printf "${GREEN}  ✓${RESET} ${BOLD}%s${RESET}\n" "$1"; }
fail()   { printf "${RED}  ✗${RESET} ${BOLD}%s${RESET}\n" "$1"; exit 1; }
info()   { printf "${BLUE}  ❯${RESET} %s\n" "$1"; }
header() { printf "\n${PURPLE}  ╭──────────────────────────────────────╮${RESET}\n"
           printf "${PURPLE}  │${RESET}  ${PINK}${BOLD}cmds${RESET} — fish command dashboard       ${PURPLE}│${RESET}\n"
           printf "${PURPLE}  ╰──────────────────────────────────────╯${RESET}\n\n"; }

header

# ── Dependency checks ─────────────────────────────────────────────────────────
info "Checking dependencies..."

if ! command -v fish &>/dev/null; then
    fail "fish shell not found. Install from https://fishshell.com"
fi
ok "fish shell found ($(fish --version 2>&1 | head -1))"

if ! command -v fzf &>/dev/null; then
    fail "fzf not found. Install with: brew install fzf  |  apt install fzf  |  pacman -S fzf"
fi
ok "fzf found ($(fzf --version))"

# ── Install ───────────────────────────────────────────────────────────────────
FISH_FUNCTIONS="${XDG_CONFIG_HOME:-$HOME/.config}/fish/functions"
FISH_DATA="${XDG_CONFIG_HOME:-$HOME/.config}/fish/cmds_data.tsv"

info "Installing cmds.fish → $FISH_FUNCTIONS/"
mkdir -p "$FISH_FUNCTIONS"
cp "$(dirname "$0")/functions/cmds.fish" "$FISH_FUNCTIONS/cmds.fish"
ok "Function installed"

if [ ! -f "$FISH_DATA" ]; then
    info "Creating default data file → $FISH_DATA"
    printf "%s\t%s\n" \
        "Git: Configurar user y email"  'git config user.name "Nombre" && git config user.email "email@ejemplo.com"' \
        "Git: Ver estado"               "git status" \
        "Git: Ver ramas remotas"        "git branch -r" \
        "Git: Limpiar ramas mergeadas"  "git branch --merged | grep -v main | xargs git branch -d" \
        "Sistema: Listar puertos"       "lsof -i -P -n | grep LISTEN" \
        "Sistema: Ver uso de disco"     "df -h" > "$FISH_DATA"
    ok "Default commands created"
else
    info "Data file already exists, skipping"
fi

printf "\n${PURPLE}  ╭──────────────────────────────────────╮${RESET}\n"
printf "${PURPLE}  │${RESET}  ${GREEN}${BOLD}Installation complete!${RESET}               ${PURPLE}│${RESET}\n"
printf "${PURPLE}  │${RESET}  Run ${BLUE}cmds${RESET} in a new fish session       ${PURPLE}│${RESET}\n"
printf "${PURPLE}  ╰──────────────────────────────────────╯${RESET}\n\n"
