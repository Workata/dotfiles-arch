# dotfiles - arch

Welcome to my dotfiles for Arch! Feel free to checkout the setup and copy configs, scripts or general way of working.

## Rules
- KISS - keep it simple stupid :)
- official packages over AUR packages
- required/important packages should be in `base` requirements, any additional stuff should be in `optional` requirements

## scripts

To `backup`
```sh
make backup
```

To `restore`
```sh
make restore
```

---

For dry run add `--dry-run` flag:
```sh
make backup ARGS=--dry-run
```

```sh
make restore ARGS=--dry-run
```

For `restore` script you can also include `optional` packages:
```sh
make restore ARGS=--optional-packages
```

For multiple args you need to use quotes:
```sh
make restore ARGS="--dry-run --optional-packages"
```


## Archinstall configuration

- **Locales**
    - **keyboard layout**: pl1
    - **locale language**: en_US.UTF-8, pl_PL.UTF-8 
    - **locale encoding**: UTF-8
- **Filesystem**: ext4
- **Separate partition for home**: No
- **Bootloader**: Systemd-boot (system and service management: systemd)
- **Swap on zram**: Enabled
- **Compression algorithm**: zstd
- **Seat access**: polkit
- **Network configuration**: Network manager (default backend)
- **Timezone**: Europe/Warsaw
- **Automatic time sync (NTP)**: Enabled
- **Applications**
    - **Bluetooth**: enabled
    - **Audio**: pipewire
    - **Power management**: power-profiles-daemon
    - **Print service**: Enabled

---

## Selected components <!-- / apps / tools / themes -->

For more components checkout [docs/components.md](docs/components.md).

- 🖥️ **Windows Manager**: [hyprland](https://hypr.land/)
- 🚀 **Application Launcher**: [vicinae](https://github.com/vicinaehq/vicinae)
- 👤 **Greeter** (login manager): [sddm](https://github.com/sddm/sddm)
    - **theme**: [Tokyo Night](https://github.com/siddrs/tokyo-night-sddm)
- 🔐 **Screen locker**: [hyprlock](https://github.com/hyprwm/hyprlock/)
- 🔑 **Password manager**: [bitwarden](https://bitwarden.com/)

---
- 📟 **Terminal**: [kitty](https://sw.kovidgoyal.net/kitty/)
- **Shell**: zsh
    - **zsh config**: [powerlevel10k](https://github.com/romkatv/powerlevel10k) -- [pure](https://github.com/sindresorhus/pure) like theme

---
- 🌐 **Browser**
    - **main** (default): [firefox](https://www.firefox.com)
        - **theme**: Dark (built-in)
        - **extensions**
            - [Bitwarden Password Manager](https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/)
            - [Privacy Badger](https://addons.mozilla.org/en-US/firefox/addon/privacy-badger17/)
            - [uBlock Origin](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/)
    - **fallback** (chromium based): [vivaldi](https://vivaldi.com/)
- 🔎 **Search Engine**: [DuckDuckGo](https://duckduckgo.com/)
---
- 👆🏻 **Cursor theme**: [BreezeX-Light](https://github.com/ful1e5/BreezeX_Cursor)
- ℬ **Main font**: JetBrainsMono-Regular, Nerd fonts

---
- **AUR helper**: [yay](https://github.com/jguer/yay)


## Others

### env vars management

location: `~/.config/environment.d/user.conf`


### Locales

To change locales - [wiki](https://wiki.archlinux.org/title/Locale#Generating_locales)

- Go to `/etc/locale.gen`
- Uncomment needed languages
- Save file and generate locale using `locale-gen`

### Docs

- [components](docs/components.md)
- [keybindings](docs/keybindings.md)

