# fishpocket

Interactive command dashboard for [fish shell](https://fishshell.com), powered by [fzf](https://github.com/junegunn/fzf).

Store your frequent shell commands, search through them, and send them straight to your prompt — ready to run or tweak.

```
  ╭── ❯ cmds ─────────────────────────────────────────────────────────╮
  │  > git                                                 2/6        │
  │                                                                   │
  │  Git: Set user and email                                          │
  │  Git: Status                                                      │
  │  Git: List remote branches                                        │
  │  Git: Clean merged branches                                       │
  │                                                                   │
  │  enter run  a add  e edit  d delete  ? preview                    │
  ╰───────────────────────────────────────────────────────────────────╯
```

## Requirements

- [fish shell](https://fishshell.com) ≥ 3.0
- [fzf](https://github.com/junegunn/fzf) ≥ 0.30

## Installation

```bash
git clone https://github.com/AngelRamirez30/fishpocket.git
cd fishpocket
./install.sh
```

Then open a new fish session and run `cmds`.

## Usage

| Key      | Action                                                   |
|----------|----------------------------------------------------------|
| `enter`  | Send command to prompt (ready to run or edit before running) |
| `a`      | Add a new command                                        |
| `e`      | Edit selected command                                    |
| `d`      | Delete selected (Tab to select multiple)                 |
| `?`      | Toggle command preview                                   |
| `esc`    | Exit                                                     |

### Subcommands

```fish
cmds          # Open interactive menu
cmds add      # Add a command
cmds edit     # Edit a command
cmds del      # Delete a command
cmds help     # Show help
```

### Category colors

Commands are color-coded by prefix:

| Prefix              | Color  |
|---------------------|--------|
| `Git:`              | Purple |
| `System:`           | Orange |
| `Docker:`           | Blue   |
| `npm:` / `Node:` / `JS:` | Green |
| anything else       | Pink   |

Name your commands like `Git: clone repo` or `Docker: prune all` to get automatic coloring.

## Data file

Commands are stored in `~/.config/fish/cmds_data.tsv` — a plain TSV file (`title\tcommand`). You can edit it directly with any text editor.

## Theme

Uses the [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) color palette.

## License

MIT
