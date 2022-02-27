#!/bin/bash

function run {
    local version_new="$1"
    local version_current="$2"

}

case "${1}" in
    --about )
        echo -n "Updates the @version tag in mix.exs files."
        ;;
    * )
        run "$@"
        ;;
esac
