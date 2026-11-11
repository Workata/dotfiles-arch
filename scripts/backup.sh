#!/usr/bin/env bash

set -e # stop on (e)rror

readonly VERSION="2.1.0"

###
# Run:
#   - from poject root
#   - without sudo privileges
#   - use Makefile (make backup)
#
# Steps:
#   0) pre-hooks
#       0.1) print info
#
#   1) backup home configs (mapped: '$HOME/' -> './dotfiles-arch/configs/home/')
#       1.1) backup home dirs
#       1.2) backup home files
#   2) backup root configs(mapped: '/' -> './dotfiles-arch/configs/root/')
#       2.1) backup root dirs
#       2.2) backup root files
#
#   3) post-hooks
###

DRY_RUN="false"
PROJECT_ROOT_PATH="$(pwd)" # should be a full path to the dotfiles
readonly PROJECT_ROOT_PATH

readonly CONFIGS_TARGET_BASE_DIR_PATH="${PROJECT_ROOT_PATH}/configs"
readonly HOME_CONFIGS_TARGET_BASE_DIR_PATH="${CONFIGS_TARGET_BASE_DIR_PATH}/home"
readonly ROOT_CONFIGS_TARGET_BASE_DIR_PATH="${CONFIGS_TARGET_BASE_DIR_PATH}/root"

# starts with ${HOME}/ prefix - added later
readonly HOME_DIRS_TO_BACKUP=(
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
readonly HOME_FILES_TO_BACKUP=(
    ".config/spotify-flags.conf"
    ".config/electron-flags.conf"
    ".config/mimeapps.list"
    ".zshrc"
    ".p10k.zsh"
    ".config/Code/User/settings.json"
)

# starts with / (root) prefix - added later
readonly ROOT_DIRS_TO_BACKUP=()

# starts with / (root) prefix - added later
readonly ROOT_FILES_TO_BACKUP=(
    "etc/sddm.conf"
    "etc/pacman.conf"
)

# parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN="true"
            shift
            ;;
        *)
            echo "Unknown argument: $1" >&2
            exit 1
            ;;
    esac
done

print_info() {
    if [[ "${DRY_RUN}" == "true" ]]; then
        echo "----- THIS IS A DRY RUN! -----"
    fi

    echo -e "[STEP 0] pre-hooks - print info\n"
    echo "Version: ${VERSION}"

    echo "Vars:"
    echo "PROJECT_ROOT_PATH: ${PROJECT_ROOT_PATH}"
    echo "CONFIGS_TARGET_BASE_DIR_PATH: ${CONFIGS_TARGET_BASE_DIR_PATH}"
    echo "HOME_CONFIGS_TARGET_BASE_DIR_PATH: ${HOME_CONFIGS_TARGET_BASE_DIR_PATH}"
    echo "ROOT_CONFIGS_TARGET_BASE_DIR_PATH: ${ROOT_CONFIGS_TARGET_BASE_DIR_PATH}"
    echo -e "\n"
}

pre_hooks() {
    echo "[START] Backup process started!"
    print_info
}

backup_home_dirs() {
    echo "[STEP 1.1] backup home - dirs"

    for dir in "${HOME_DIRS_TO_BACKUP[@]}"; do
        sourceFolder="${HOME}/${dir}"
        targetFolder="${HOME_CONFIGS_TARGET_BASE_DIR_PATH}/${dir}"

        if [[ "${DRY_RUN}" == "true" ]]; then
            echo "Would backup ${sourceFolder} into ${targetFolder}..."
            continue
        fi
        echo "Backuping ${sourceFolder} into ${targetFolder} ..."
        mkdir -p "${targetFolder}" # make sure that target folder exists
        cp -Rf "${sourceFolder}/"* "${targetFolder}/"
    done

    echo -e "Finished backuping home dirs!\n"
}

backup_home_files() {
    echo "[STEP 1.2] backup home - files"

    for file in "${HOME_FILES_TO_BACKUP[@]}"; do
        sourceFile="${HOME}/${file}"
        targetFile="${HOME_CONFIGS_TARGET_BASE_DIR_PATH}/${file}"

        if [[ "${DRY_RUN}" == "true" ]]; then
            echo "Would backup ${sourceFile} into ${targetFile}..."
            continue
        fi
        echo "Backuping ${sourceFile} into ${targetFile} ..."
        mkdir -p "$(dirname "$targetFile")" # make sure that parent folder of target file exists
        cp -f "${sourceFile}" "${targetFile}"
    done

    echo -e "Finished backuping home files!\n"
}

backup_root_dirs() {
    echo "[STEP 2.1] backup root - dirs"

    for dir in "${ROOT_DIRS_TO_BACKUP[@]}"; do
        sourceFolder="/${dir}"
        targetFolder="${ROOT_CONFIGS_TARGET_BASE_DIR_PATH}/${dir}"

        if [[ "${DRY_RUN}" == "true" ]]; then
            echo "Would backup ${sourceFolder} into ${targetFolder}..."
            continue
        fi
        echo "Backuping ${sourceFolder} into ${targetFolder} ..."
        mkdir -p "${targetFolder}" # make sure that target folder exists
        cp -Rf "${sourceFolder}/"* "${targetFolder}/"
    done

    echo -e "Finished backuping root dirs!\n"
}

backup_root_files() {
    echo "[STEP 2.2] backup root - files"

    for file in "${ROOT_FILES_TO_BACKUP[@]}"; do
        sourceFile="/${file}"
        targetFile="${ROOT_CONFIGS_TARGET_BASE_DIR_PATH}/${file}"

        if [[ "${DRY_RUN}" == "true" ]]; then
            echo "Would backup ${sourceFile} into ${targetFile}..."
            continue
        fi
        echo "Backuping ${sourceFile} into ${targetFile} ..."
        mkdir -p "$(dirname "$targetFile")" # make sure that parent folder of target file exists
        cp -f "${sourceFile}" "${targetFile}"
    done

    echo -e "Finished backuping root files!\n"
}

post_hooks() {
    echo "[END] Backup process finished!"
}

pre_hooks

backup_home_dirs
backup_home_files
backup_root_dirs
backup_root_files

post_hooks
