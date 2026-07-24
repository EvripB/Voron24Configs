#!/usr/bin/env bash

set -Eeuo pipefail

readonly config_folder="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly klipper_folder="${HOME}/klipper"
readonly moonraker_folder="${HOME}/moonraker"
readonly mainsail_folder="${HOME}/mainsail"
readonly fluidd_folder=""
readonly branch="main"

m1=""
m2=""
m3=""
m4=""

die() {
    printf 'Configuration backup failed: %s\n' "$*" >&2
    exit 1
}

record_git_version() {
    local repository="$1"
    local label="$2"
    local output_variable="$3"
    local version=""

    if [[ -d "${repository}/.git" ]] &&
       version="$(git -C "$repository" describe --always --tags --long 2>/dev/null)"; then
        printf -v "$output_variable" '%s version: %s' "$label" "$version"
    fi
}

grab_versions() {
    local mainsail_version=""
    local fluidd_version=""

    record_git_version "$klipper_folder" "Klipper" m1
    record_git_version "$moonraker_folder" "Moonraker" m2

    if [[ -r "${mainsail_folder}/.version" ]]; then
        mainsail_version="$(head -n 1 "${mainsail_folder}/.version" 2>/dev/null || true)"
        if [[ -n "$mainsail_version" ]]; then
            m3="Mainsail version: ${mainsail_version}"
        fi
    fi

    if [[ -n "$fluidd_folder" && -r "${fluidd_folder}/.version" ]]; then
        fluidd_version="$(head -n 1 "${fluidd_folder}/.version" 2>/dev/null || true)"
        if [[ -n "$fluidd_version" ]]; then
            m4="Fluidd version: ${fluidd_version}"
        fi
    fi
}

validate_repository() {
    local current_branch=""

    [[ -d "${config_folder}/.git" ]] ||
        die "config folder is not a Git repository"

    current_branch="$(git -C "$config_folder" branch --show-current)"
    [[ "$current_branch" == "$branch" ]] ||
        die "expected branch '${branch}', found '${current_branch:-detached HEAD}'"

    [[ ! -e "${config_folder}/.git/MERGE_HEAD" ]] ||
        die "a merge is already in progress"
    [[ ! -d "${config_folder}/.git/rebase-merge" &&
       ! -d "${config_folder}/.git/rebase-apply" ]] ||
        die "a rebase is already in progress"

    if ! git -C "$config_folder" fsck --full --no-dangling >/dev/null; then
        die "Git integrity check failed; no files were staged"
    fi
}

acquire_lock() {
    exec 9>"${config_folder}/.git/autocommit.lock"
    flock -n 9 || die "another configuration backup is already running"
}

fetch_and_verify_remote() {
    local remote_commit=""

    # Authentication is provided by the configured origin. Never print or
    # rewrite the remote URL from this script.
    if ! git -C "$config_folder" fetch --quiet origin "$branch" >/dev/null 2>&1; then
        die "unable to fetch origin/${branch}; no files were staged"
    fi

    remote_commit="$(
        git -C "$config_folder" rev-parse --verify "FETCH_HEAD^{commit}"
    )"

    if ! git -C "$config_folder" merge-base --is-ancestor "$remote_commit" HEAD; then
        die "origin/${branch} is ahead or diverged; reconcile it manually before backup"
    fi
}

commit_changes() {
    local current_date=""
    local -a commit_arguments=()

    git -C "$config_folder" add --all

    if git -C "$config_folder" diff --cached --quiet; then
        printf 'No new configuration changes to commit.\n'
        return
    fi

    current_date="$(date '+%Y-%m-%d %T')"
    commit_arguments=(-m "Autocommit from ${current_date}")

    [[ -n "$m1" ]] && commit_arguments+=(-m "$m1")
    [[ -n "$m2" ]] && commit_arguments+=(-m "$m2")
    [[ -n "$m3" ]] && commit_arguments+=(-m "$m3")
    [[ -n "$m4" ]] && commit_arguments+=(-m "$m4")

    git -C "$config_folder" commit "${commit_arguments[@]}"
}

push_config() {
    if ! git -C "$config_folder" push --quiet origin "$branch" >/dev/null 2>&1; then
        die "push failed; any new commit remains safe in the local repository"
    fi

    printf 'Configuration backup completed successfully.\n'
}

main() {
    acquire_lock
    validate_repository
    grab_versions
    fetch_and_verify_remote
    commit_changes
    push_config
}

main "$@"
