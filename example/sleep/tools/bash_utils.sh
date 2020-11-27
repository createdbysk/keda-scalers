# This file is expected to be sourced into other bash scripts
# and not used directly.

function utils::realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

# Given a message and an optional exit code
# displays the message
# AND either exits with the exit code or exit 1
function fail() {
    local MESSAGE="$1"
    local EXIT_CODE=$2
    if [[ -z ${EXIT_CODE} ]]; then
        EXIT_CODE=1
    fi
    echo "${MESSAGE}"
    exit ${EXIT_CODE}
}

function util::command_exists() {
    local APP_NAME=$1
    command -v ${APP_NAME} &> /dev/null
}

# Given a path relative to the directory of an executing bash script
# returns the absolute path
function util::abspath_given_path_relative_to_script() {
    local SCRIPT_ABS_PATH=$([[ $0 = /* ]] && echo "$0" || echo "$PWD/${0#./}")
    local PATH_RELATIVE_TO_SCRIPT="$1"
    local SCRIPT_ABS_DIR="$(dirname ${SCRIPT_ABS_PATH})"
    local ABSPATH=$([[ ${PATH_RELATIVE_TO_SCRIPT} = /* ]] \
        && echo "${PATH_RELATIVE_TO_SCRIPT}" \
        || echo "${SCRIPT_ABS_DIR}/${PATH_RELATIVE_TO_SCRIPT#./}")
    echo "${ABSPATH}"
}

# Given a file location relative to the directory of an executing bash script
# sources the file.
function util::include() {
    local PATH_RELATIVE_TO_SCRIPT="$1"
    local ABSPATH="$(util::abspath_given_path_relative_to_script ${PATH_RELATIVE_TO_SCRIPT})"
    source "${ABSPATH}"
}
