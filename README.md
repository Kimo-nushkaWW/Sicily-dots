# Sicily-dots

NixOS + Hyprland + k4 Dynamic Island dotfiles.

## Stack

| Layer | Tool |
|---|---|
| OS | NixOS (unstable channel) |
| WM | Hyprland |
| Bar | k4 (Quickshell Dynamic Island) |
| Terminal | foot |
| Shell | fish + starship |
| Editor | VSCodium |
| Files | Nautilus |
| Theming | matugen + pywal (wallpaper-driven) |
| Wallpaper | awww |
| Fonts | JetBrainsMono Nerd Font, Noto CJK |
| Lock screen | hyprlock (manual) |
| Screenshots | K4 capture with frozen-frame selector |
| Audio | PipeWire + WirePlumber |

## Structure

```
Sicily-dots/
├── flake.nix                   # flake inputs: nixpkgs-unstable, home-manager, quickshell
├── hosts/sicily/
│   ├── configuration.nix       # system-level config (AMD, PipeWire, Hyprland, user)
│   └── hardware-configuration.nix  # replace with your machine's output
├── home/
│   ├── default.nix             # home-manager entrypoint
│   ├── hyprland.nix            # Hyprland config, keybinds, animations
│   ├── k4.nix                  # k4 island: symlink + deps + autostart
│   ├── theme.nix               # matugen + pywal + awww + auto light/dark
│   ├── foot.nix                # foot terminal
│   ├── fish.nix                # fish + starship
│   ├── vscodium.nix            # VSCodium
│   ├── nautilus.nix            # file manager + GTK/QT theme
│   ├── hyprlock.nix            # manual lock screen
│   ├── fonts.nix               # Nerd Fonts, CJK
│   └── dev.nix                 # git, ssh, gpg, dev tools
├── k4/                         # k4 source (your fork — edit freely)
└── wallpapers/                 # optional user wallpapers
```

## Installation

> **Before you start:** Run `nixos-generate-config` on your machine and replace
> `hosts/sicily/hardware-configuration.nix` with the output.

### 1. Adjust placeholders

- `hosts/sicily/configuration.nix` → `time.timeZone`, keyboard layout
- `home/hyprland.nix` → monitor names (`DP-1`, `DP-2`) — run `hyprctl monitors`
- `home/theme.nix` → `wlsunset` lat/lon coordinates
- `home/dev.nix` → git `userName`, `userEmail`, GPG key

### 2. Install NixOS

```bash
sudo nixos-install --flake /path/to/Sicily-dots#sicily
```

### 3. Switch (after first boot)

```bash
sudo nixos-rebuild switch --flake ~/Sicily-dots#sicily
```

Home-manager runs automatically as a NixOS module.

For a standalone Home Manager switch, use the exported configuration and keep
the backup flag when taking ownership of existing files:

```bash
nix run --no-update-lock-file ~/Sicily-dots#home-manager -- switch \
  --flake ~/Sicily-dots#kimo@sicily -b hm-backup
```

В Fish доступны сокращения `nrs` (NixOS) и `hrs` (Home Manager). После
успешного переключения они автоматически выполняют `hyprctl reload`, поэтому
изменения в `home/hyprland.nix` применяются без перезагрузки компьютера.

### 4. Clone k4 source (if not already present)

The `k4/` directory should already be in this repo. If it is empty or missing:

```bash
git clone https://github.com/k4ditano/k4 /tmp/k4-src
cp -r /tmp/k4-src/. ~/Sicily-dots/k4/
```

Then rebuild.

## Theming

Change wallpaper and regenerate colors:

```bash
wallpaper ~/Pictures/my-photo.jpg
```

Colors switch automatically:
- **07:00** → light palette
- **19:00** → dark palette

## Keybinds

| Key | Action |
|---|---|
| `SUPER+T` | foot terminal |
| `SUPER+E` | Nautilus |
| `SUPER+L` | K4 lock screen |
| `SUPER+C` | region screenshot via K4 (frozen frame) |
| `Print` | region screenshot via K4 |
| `Shift+Print` | full screenshot via K4 |
| `Ctrl+Print` | active window screenshot via K4 |
| `SUPER+Q` | close window |
| `SUPER+F` | полноэкранный режим |
| `SUPER+D` | специальный рабочий стол Telegram/Discord |
| `SUPER+SPACE` | K4 application launcher |
| `SUPER+1-9` | switch workspace |
| `SUPER+SHIFT+1-9` | move window to workspace |
| `SUPER+H/J` | focus left/down |
| `SUPER+SHIFT+H/J/K/L` | move window |

## k4 customization

k4 source lives in `Sicily-dots/k4/`. Edit the QML files directly.
After editing, reload the bar without restarting Hyprland:

```bash
# k4's built-in hot-reload (from k4 docs)
qs ipc call k4 reload
```

Or kill and restart:

```bash
quickshell kill --id "$(quickshell list --json | jq -r '.[0].id')" --any-display 2>/dev/null || true
~/.config/quickshell/k4/arrancar --no-duplicate -d
```
