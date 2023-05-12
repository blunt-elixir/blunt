#!/bin/bash

if [[ -z "${HEX_API_KEY}" ]]; then
    echo "HEX_API_KEY is not set"
    exit 1
fi

publish () {
    pushd apps/$1
    cp ../../VERSION ./__VERSION
    mix deps.get
    mix hex.publish package --yes --replace
    popd
}

publish "blunt_data"
publish "blunt"
publish "blunt_ddd"
publish "blunt_absinthe"
publish "blunt_absinthe_relay"
