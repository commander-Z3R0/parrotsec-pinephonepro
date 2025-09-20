#!/bin/bash

source scripts/handle_error.sh

run() {
    echo "Executing: $2"
    eval "$1"
    if [ $? -ne 0 ]; then
        handle_error "Command failed: $2"
    fi
}
