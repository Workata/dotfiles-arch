#!/usr/bin/env bash

PROJECT_ROOT_PATH="$(pwd)" # should be a full path to the dotfiles
readonly PROJECT_ROOT_PATH
readonly LOGS_FOLDER_PATH="${PROJECT_ROOT_PATH}/logs"

# find "$LOGS_FOLDER_PATH" -type f -name "*.log" -print  # preview
find "$LOGS_FOLDER_PATH" -type f -name "*.log" -delete
echo "Logs cleared!"
