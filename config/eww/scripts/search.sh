#!/usr/bin/env bash

FILTER="$1"
ARG="$2"

all_programs() {
    oldIFS="$IFS"
    IFS=":"
    for dir in $PATH; do
        ls $dir 2> /dev/null
    done
    IFS="$oldIFS"
}

filtered_programs() {
    all_programs | fzf --filter="$FILTER"
}

progs_as_json=$(filtered_programs | jq -Rsc 'split("\n")[:-1]')

eww update "$ARG=$progs_as_json"
