#!/usr/bin/env bash

set -e # stop on (e)rror

readonly VERSION="2.1.0"

###
# Run:
#   - from poject root
#   - without sudo privileges
#   - use Makefile (make restore)
#
# Steps:
#   0) pre-hooks
#       0.1) print info
#       0.2) create file (based on example `.env.example`) with system wide env vars if doesn't exist
#       0.3) update system
#
#   1) restore home configs
#       1.1) restore home dirs
#       1.2) restore home files
#   2) restore root configs
#       2.1) restore root dirs
#       2.2) restore root files
#   3) install AUR helper - yay
#   4) install official packages
#   5) install AUR packages
#   6) configure shell
#       6.1) set zsh as a default shell
#       6.2) clone p10k repo
#   7) restore greeter theme
#   8) enable services - once (then will be started automatically)
#
#   9) post-hooks
#       9.1) reload hyprland
###

DRY_RUN="false"
OPTIONAL_PACKAGES="false"  # if 'true' then optional packages will be installed
PROJECT_ROOT_PATH="$(pwd)" # should be a full path to the dotfiles
readonly PROJECT_ROOT_PATH

readonly CONFIGS_SOURCE_BASE_DIR_PATH="${PROJECT_ROOT_PATH}/configs"
readonly HOME_CONFIGS_SOURCE_BASE_DIR_PATH="${CONFIGS_SOURCE_BASE_DIR_PATH}/home"
readonly ROOT_CONFIGS_SOURCE_BASE_DIR_PATH="${CONFIGS_SOURCE_BASE_DIR_PATH}/root"

# starts with ${HOME}/ prefix - added later
readonly HOME_DIRS_TO_RESTORE=(
    ".config/hypr"
    ".config/kitty"
    ".config/vicinae"
    ".config/waybar"
    ".config/fontconfig"
    ".config/gtk-3.0"
    ".config/gtk-4.0"
    ".config/wlogout"
    ".icons"
    "wallpapers"
)

# starts with ${HOME}/ prefix - added later
readonly HOME_FILES_TO_RESTORE=(
    ".config/spotify-flags.conf"
    ".config/electron-flags.conf"
    ".config/mimeapps.list"
    ".zshrc"
    ".p10k.zsh"
    ".config/Code/User/settings.json"
)

# starts with / (root) prefix - added later
readonly ROOT_DIRS_TO_RESTORE=()

# starts with / (root) prefix - added later
readonly ROOT_FILES_TO_RESTORE=(
    "etc/sddm.conf"
    "etc/pacman.conf"
)

# --- packages paths ---
readonly PACKAGES_PATH="${PROJECT_ROOT_PATH}/packages"
readonly BASE_PACKAGES_PATH="${PACKAGES_PATH}/base"
readonly OPTIONAL_PACKAGES_PATH="${PACKAGES_PATH}/optional"

readonly BASE_OFFICIAL_PACKAGES_PATH="${BASE_PACKAGES_PATH}/official.txt"
readonly BASE_AUR_PACKAGES_PATH="${BASE_PACKAGES_PATH}/aur.txt"
readonly OPTIONAL_OFFICIAL_PACKAGES_PATH="${OPTIONAL_PACKAGES_PATH}/official.txt"
readonly OPTIONAL_AUR_PACKAGES_PATH="${OPTIONAL_PACKAGES_PATH}/aur.txt"

# parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN="true"
            shift
            ;;
        --optional-packages)
            OPTIONAL_PACKAGES="true"
            shift
            ;;
        *)
            echo "Unknown argument: $1" >&2
            exit 1
            ;;
    esac
done

ask_permission_to_run() {
    if [[ "${DRY_RUN}" == "true" ]]; then
        echo "Skipping asking for permission - dry run"
        return 0
    fi

    read -rp "Do you want to run restore? [y/n] " answer
    case "$answer" in
        y | Y)
            # add 5 seconds delay before start
            echo "Restore starts in 5 seconds..."
            sleep 5
            ;;
        *)
            echo "Restore aborted!"
            exit 0
            ;;
    esac
}

print_info() {
    if [[ "${DRY_RUN}" == "true" ]]; then
        echo "----- THIS IS A DRY RUN! -----"
    fi

    echo -e "[STEP 0.1] pre-hooks - print info\n"
    echo "Version: ${VERSION}"

    echo "Current vars:"
    echo "DRY_RUN: ${DRY_RUN}"
    echo "OPTIONAL_PACKAGES: ${OPTIONAL_PACKAGES}"
    echo "PROJECT_ROOT_PATH: ${PROJECT_ROOT_PATH}"
    echo "CONFIGS_SOURCE_BASE_DIR_PATH: ${CONFIGS_SOURCE_BASE_DIR_PATH}"
    echo "HOME_CONFIGS_SOURCE_BASE_DIR_PATH: ${HOME_CONFIGS_SOURCE_BASE_DIR_PATH}"
    echo "ROOT_CONFIGS_SOURCE_BASE_DIR_PATH: ${ROOT_CONFIGS_SOURCE_BASE_DIR_PATH}"
    echo -e "\n"
}

create_default_env_vars_file() {
    echo "[STEP 0.2] pre-hooks - create default env vars file"

    cp -n "${CONFIGS_SOURCE_BASE_DIR_PATH}/.env.example" "${CONFIGS_SOURCE_BASE_DIR_PATH}/.env"
    envFileSourcePath="${CONFIGS_SOURCE_BASE_DIR_PATH}/.env"
    envFileTargetPath="${HOME}/.config/environment.d/user.conf"

    if [ ! -e "$envFileTargetPath" ]; then
        if [[ "${DRY_RUN}" == "true" ]]; then
            echo "Would try to create new env file in ${envFileTargetPath} based on ${envFileSourcePath}..."
            return 0
        fi

        echo "Creating new env file in ${envFileTargetPath} based on ${envFileSourcePath}..."
        mkdir -p "$(dirname "$envFileTargetPath")"
        cp "$envFileSourcePath" "$envFileTargetPath"
    else
        echo "Env file ${envFileTargetPath} already exists! Will NOT overwrite with defaults."
    fi
}

update_system() {
    # synchronize package databases and upgrade all installed packages to their latest versions.

    if [[ "${DRY_RUN}" == "true" ]]; then
        echo "Would update system with 'sudo pacman -Syu'..."
        return 0
    fi

    echo "[STEP 0.3] pre-hooks - update system"
    sudo pacman -Syyu
}

pre_hooks() {
    echo "[START] Restore process started!"
    print_info
    ask_permission_to_run
    create_default_env_vars_file
    update_system
}

restore_home_dirs() {
    echo "[STEP 1.1] restore home - dirs"

    for dir in "${HOME_DIRS_TO_RESTORE[@]}"; do
        sourceDir="${HOME_CONFIGS_SOURCE_BASE_DIR_PATH}/${dir}"
        targetDir="${HOME}/${dir}"

        if [[ "${DRY_RUN}" == "true" ]]; then
            echo "Would restore ${sourceDir} into ${targetDir}..."
            continue
        fi

        echo "Restoring ${sourceDir} into ${targetDir} ..."
        sudo rm -rf "${targetDir}" # clear target folder before restoring
        mkdir -p "${targetDir}"
        cp -Rf "${sourceDir}/"* "${targetDir}/"
    done

    echo -e "Finished restoring home dirs!\n"
}

restore_home_files() {
    echo "[STEP 1.2] restore home - files"

    for file in "${HOME_FILES_TO_RESTORE[@]}"; do
        sourceFile="${HOME_CONFIGS_SOURCE_BASE_DIR_PATH}/${file}"
        targetFile="${HOME}/${file}"

        if [[ "${DRY_RUN}" == "true" ]]; then
            echo "Would restore ${sourceFile} into ${targetFile}..."
            continue
        fi

        echo "Restoring ${sourceFile} into ${targetFile} ..."
        mkdir -p "$(dirname "$targetFile")" # make sure that parent folder of target file exists
        cp -f "${sourceFile}" "${targetFile}"
    done

    echo -e "Finished restoring home files!\n"
}

restore_root_dirs() {
    echo "[STEP 2.1] restore root - dirs"

    for dir in "${ROOT_DIRS_TO_RESTORE[@]}"; do
        sourceDir="${ROOT_CONFIGS_SOURCE_BASE_DIR_PATH}/${dir}"
        targetDir="/${dir}"

        if [[ "${DRY_RUN}" == "true" ]]; then
            echo "Would restore ${sourceDir} into ${targetDir}..."
            continue
        fi

        echo "Restoring ${sourceDir} into ${targetDir} ..."
        sudo rm -rf "${targetDir}" # clear target folder before restoring
        sudo mkdir -p "${targetDir}"
        sudo cp -Rf "${sourceDir}/"* "${targetDir}/"
    done

    echo -e "Finished restoring root dirs!\n"
}

restore_root_files() {
    echo "[STEP 2.2] restore root - files"

    for file in "${ROOT_FILES_TO_RESTORE[@]}"; do
        sourceFile="${ROOT_CONFIGS_SOURCE_BASE_DIR_PATH}/${file}"
        targetFile="/${file}"

        if [[ "${DRY_RUN}" == "true" ]]; then
            echo "Would restore ${sourceFile} into ${targetFile}..."
            continue
        fi

        echo "Restoring ${sourceFile} into ${targetFile} ..."
        sudo mkdir -p "$(dirname "$targetFile")" # make sure that parent folder of target file exists
        sudo cp -f "${sourceFile}" "${targetFile}"
    done

    echo -e "Finished restoring root files!\n"
}

install_aur_helper() {
    # install `yay` if not installed already!
    echo "[STEP 3] install AUR helper - 'yay'"

    if command -v yay >/dev/null 2>&1; then
        echo "yay is already installed - all good!"
    else
        if [[ "${DRY_RUN}" == "true" ]]; then
            echo "Would install 'yay'..."
            return 0
        fi

        git clone https://aur.archlinux.org/yay.git
        makepkg --dir yay -si --noconfirm
        rm -rf yay/
    fi
}

install_official_packages() {
    echo "[STEP 4] install official packages"

    packagesPath=$1
    cat "$packagesPath" | grep -o '^[^#]*' | while read -r package; do

        if [[ "${DRY_RUN}" == "true" ]]; then
            echo "Would install ${package} from official Arch repo..."
            continue
        fi

        echo -e "Installing ${package}...\n"
        sudo pacman --noconfirm -S --needed "$package"
    done
}

install_aur_packages() {
    echo "[STEP 5] install AUR packages (using 'yay')"

    packagesPath=$1
    cat "$packagesPath" | grep -o '^[^#]*' | while read -r package; do
        if [[ "${DRY_RUN}" == "true" ]]; then
            echo "Would install ${package} from AUR..."
            continue
        fi

        echo -e "Installing ${package}...\n"
        yay --noconfirm -S --needed "$package"
    done
}

install_packages() {
    # base
    install_official_packages "$BASE_OFFICIAL_PACKAGES_PATH"
    install_aur_packages "$BASE_AUR_PACKAGES_PATH"

    # optional
    if [[ "${OPTIONAL_PACKAGES}" == "true" ]]; then
        echo "Installing optional packages..."
        install_official_packages "$OPTIONAL_OFFICIAL_PACKAGES_PATH"
        install_aur_packages "$OPTIONAL_AUR_PACKAGES_PATH"
    else
        echo "Optional packages excluded!"
    fi
}

set_zsh_shell() {
    # zsh should be installed in step (1)
    # set zsh as a default shell
    # ? docs: https://wiki.archlinux.org/title/Zsh#Making_Zsh_your_default_shell
    # check whether the current/default login shell is Zsh, and change it only when it isn't

    echo "[STEP 6.1] Configure shell - set zsh shell"

    if [ "$SHELL" != "$(command -v zsh)" ]; then
        echo "Changing shell to Zsh..."
        chsh -s "$(command -v zsh)"

        if [[ "${DRY_RUN}" == "true" ]]; then
            echo "Would change shell to Zsh..."
            return 0
        fi
    else
        echo "Shell is already set for Zsh!"
    fi
}

clone_powerlevel10k() {
    echo "[STEP 6.2] Configure shell - clone powerlevel10k repo"

    if [ -d "${HOME}/powerlevel10k/" ]; then
        echo "powerlevel10k folder exists - skipping download"
    else
        if [[ "${DRY_RUN}" == "true" ]]; then
            echo "Would clone powerlevel10k repo..."
            return 0
        fi

        echo -e "Cloning powerlevel10k repo...\n"
        git clone https://github.com/romkatv/powerlevel10k.git "${HOME}/powerlevel10k/"
    fi
}

restore_greeter_theme() {
    # * restore theme for sddm (selected greeter)
    # https://github.com/siddrs/tokyo-night-sddm

    echo "[STEP 7] restore greeter theme - clone tokyo night sddm repo"

    if [ -d "/usr/share/sddm/themes/tokyo-night-sddm/" ]; then
        echo "Theme folder exists - skipping download phase!"
    else
        if [[ "${DRY_RUN}" == "true" ]]; then
            echo "Would clone tokyo-night-sddm repo..."
            return 0
        fi

        echo "Theme folder doesn't exist - downloading..."
        git clone https://github.com/rototrash/tokyo-night-sddm.git ~/tokyo-night-sddm
        sudo mv ~/tokyo-night-sddm /usr/share/sddm/themes/
    fi
}

enable_services() {
    echo "[STEP 8] Enable services..."

    if [[ "${DRY_RUN}" == "true" ]]; then
        echo "Would enable services..."
        echo "BT with: 'systemctl enable --now bluetooth.service'"
        echo "vicinae with: 'systemctl --user enable --now vicinae.service'"
        return 0
    fi

    echo "Enabling bluetooth service..."
    systemctl enable --now bluetooth.service
    echo "Enabling vicinae service (app launcher server)..."
    systemctl --user enable --now vicinae.service
}

reload_hyprland() {
    echo "[STEP 9] post-hooks - reload hyprland"

    if [[ "${DRY_RUN}" == "true" ]]; then
        echo "Would reload hyprland..."
        return 0
    fi

    hyprctl reload
}

reload_waybar() {
    if [[ "${DRY_RUN}" == "true" ]]; then
        echo "Would reload waybar..."
        return 0
    fi

    pkill waybar 2>/dev/null || true
    nohup waybar >/dev/null 2>&1 &
}

reload_hyprpaper() {
    if [[ "${DRY_RUN}" == "true" ]]; then
        echo "Would reload hyprpaper..."
        return 0
    fi

    systemctl --user restart hyprpaper.service
}

post_hooks() {
    reload_hyprland
    reload_waybar
    reload_hyprpaper
    echo "[END] Restore process finished! Please reboot."
}

pre_hooks

restore_home_dirs
restore_home_files
restore_root_dirs
restore_root_files
install_aur_helper
install_packages
set_zsh_shell
clone_powerlevel10k
restore_greeter_theme
enable_services

post_hooks
