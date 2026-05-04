#!/bin/bash

#
# Copyright (c) 2023 Project CHIP Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

_chip_build_example() {

    local cur prev words cword split
    _init_completion -s || return

    # The command names supported by the script.
    local commands="build gen targets"

    local i
    local command command_comp_cword
    # Get the first non-option argument taking into account the options with their arguments.
    for ((i = 1; i <= COMP_CWORD; i++)); do
        case "${COMP_WORDS[i]}" in
            --log-level | --target | --build-profile | --repo | --out-prefix | --ninja-jobs | --pregen-dir | --dry-run-output | --pw-command-launcher)
                ((i == COMP_CWORD)) && break
                ((i == COMP_CWORD - 1)) && [[ "${COMP_WORDS[i + 1]}" = "=" ]] && break
                [[ "${COMP_WORDS[i + 1]}" = "=" ]] && ((i++))
                [[ "${COMP_WORDS[i + 1]}" ]] && ((i++))
                continue
                ;;
            -* | =)
                continue
                ;;
        esac
        command="${COMP_WORDS[i]}"
        command_comp_cword=$i
        break
    done

    # Compete the global options if the command is not specified yet.
    if [[ -z "$command" ]]; then
        case "$prev" in
            --target)
                readarray -t COMPREPLY < <(compgen -W "$("$1" targets --format=completion "$cur")" -- "$cur")
                compopt -o nospace
                return
                ;;
            --log-level | --build-profile)
                # Parse values from the "[foo|bar|baz]" part of the help text for the given option.
                readarray -t COMPREPLY < <(compgen -W "$("$1" --help | awk -F'[][]' -v o="$prev" 'index($1, o) { gsub(/[|]/, " "); print $2 }')" -- "$cur")
                return
                ;;
            --repo | --out-prefix | --pregen-dir)
                _filedir -d
                return
                ;;
            --dry-run-output)
                _filedir
                return
                ;;
        esac
        case "$cur" in
            -*)
                readarray -t COMPREPLY < <(compgen -W "$(_parse_help "$1")" -- "$cur")
                return
                ;;
        esac
    fi

    # Complete the command name.
    if [[ "$command_comp_cword" -eq "$COMP_CWORD" ]]; then
        readarray -t COMPREPLY < <(compgen -W "$commands" -- "$cur")
        return
    fi

    # Check if the command is valid.
    [[ "$commands" =~ $command ]] || return

    # Command-specific completion.
    case "$prev" in
        --format)
            readarray -t COMPREPLY < <(compgen -W "summary expanded json" -- "$cur")
            return
            ;;
        --copy-artifacts-to | --create-archives)
            _filedir -d
            return
            ;;
    esac
    case "$cur" in
        -*)
            readarray -t COMPREPLY < <(compgen -W "$("$1" "$command" --help | _parse_help -)" -- "$cur")
            ;;
    esac

}

# Get the list of commands from the output of the chip-tool,
# where each command is prefixed with the ' | * ' string.
_chip_tool_get_commands() {
    "$@" --help 2>&1 | awk '/ [|] [*] /{ print $3 }'
}

# Get the list of options from the output of the chip-tool,
# where each option starts with the '[--' string.
_chip_tool_get_options() {
    "$@" --help 2>&1 | awk -F'[[]|[]]' '/^[[]--/{ print $2 }'
}

_chip_app() {

    local cur prev words cword split
    _init_completion -s || return

    case "$prev" in
        --ble-controller)
            readarray -t words < <(ls -I '*:*' /sys/class/bluetooth)
            # Get the list of Bluetooth devices without the 'hci' prefix.
            readarray -t COMPREPLY < <(compgen -W "${words[*]#hci}" -- "$cur")
            return
            ;;
        --custom-flow)
            readarray -t COMPREPLY < <(compgen -W "0 1 2" -- "$cur")
            return
            ;;
        --capabilities)
            # The capabilities option is a bit-field with 3 bits currently defined.
            readarray -t COMPREPLY < <(compgen -W "001 010 011 100 101 111" -- "$cur")
            return
            ;;
        --KVS)
            _filedir
            return
            ;;
        --PICS)
            _filedir
            return
            ;;
        --trace_file)
            _filedir
            return
            ;;
        --trace_log | --trace_decode)
            readarray -t COMPREPLY < <(compgen -W "0 1" -- "$cur")
            return
            ;;
        --trace-to)
            readarray -t COMPREPLY < <(compgen -W "json perfetto" -- "$cur")
            compopt -o nospace
            return
            ;;
    esac

    case "$cur" in
        -*)
            readarray -t COMPREPLY < <(compgen -W "$(_parse_help "$1")" -- "$cur")
            ;;
    esac

}

# Enhanced chip-tool completion with full command hierarchy support
_chip_tool() {

    local cur prev words cword split
    _init_completion -s || return

    # Get chip-tool path (handle both direct calls and PATH calls)
    local chip_tool_cmd
    if [[ -x "out/linux-x64-chip-tool/chip-tool" ]]; then
        chip_tool_cmd="out/linux-x64-chip-tool/chip-tool"
    elif command -v chip-tool >/dev/null 2>&1; then
        chip_tool_cmd="chip-tool"
    else
        # Fallback to basic completion if chip-tool not found
        case "$cur" in
            -*)
                readarray -t COMPREPLY < <(compgen -W "--help --version" -- "$cur")
                ;;
        esac
        return
    fi

    # Get command line arguments up to the cursor position
    local args=("${COMP_WORDS[@]:1:$cword}")  # Skip the command name
    local arg_count=${#args[@]}
    
    # Determine completion context based on argument position
    case "$arg_count" in
        0)
            # No arguments - complete clusters/command sets
            local clusters=$("$chip_tool_cmd" --help 2>&1 | awk '/ [|] [*] /{ print $3 }')
            case "$cur" in
                -*)
                    readarray -t COMPREPLY < <(compgen -W "--help --version" -- "$cur")
                    ;;
                *)
                    readarray -t COMPREPLY < <(compgen -W "$clusters" -- "$cur")
                    ;;
            esac
            return
            ;;
        1)
            # One argument - complete commands for the given cluster/command set
            local cluster="${args[0]}"
            if [[ "$cluster" == -* ]]; then
                # Handle options at first position
                case "$cur" in
                    -*)
                        readarray -t COMPREPLY < <(compgen -W "--help --version" -- "$cur")
                        ;;
                esac
                return
            fi
            
            local commands=$("$chip_tool_cmd" "$cluster" 2>&1 | awk '/ [|] [*] /{ print $3 }')
            case "$prev" in
                --commissioner-name)
                    readarray -t COMPREPLY < <(compgen -W "alpha beta gamma 4 5 6 7 8 9" -- "$cur")
                    return
                    ;;
                --only-allow-trusted-cd-keys)
                    readarray -t COMPREPLY < <(compgen -W "0 1" -- "$cur")
                    return
                    ;;
                --paa-trust-store-path | --cd-trust-store-path | --dac-revocation-set-path)
                    _filedir -d
                    return
                    ;;
                --storage-directory)
                    _filedir -d
                    return
                    ;;
                --trace-to)
                    readarray -t COMPREPLY < <(compgen -W "json perfetto" -- "$cur")
                    compopt -o nospace
                    return
                    ;;
            esac
            
            case "$cur" in
                -*)
                    local options=$("$chip_tool_cmd" "$cluster" --help 2>&1 | awk -F'[[]|[]]' '/^[[]--/{ print $2 }')
                    readarray -t COMPREPLY < <(compgen -W "$options" -- "$cur")
                    ;;
                *)
                    readarray -t COMPREPLY < <(compgen -W "$commands" -- "$cur")
                    ;;
            esac
            return
            ;;
        2)
            # Two arguments - complete sub-commands or attributes/events for read/write/subscribe commands
            local cluster="${args[0]}"
            local command="${args[1]}"
            
            # Handle common options
            case "$prev" in
                --commissioner-name)
                    readarray -t COMPREPLY < <(compgen -W "alpha beta gamma 4 5 6 7 8 9" -- "$cur")
                    return
                    ;;
                --only-allow-trusted-cd-keys)
                    readarray -t COMPREPLY < <(compgen -W "0 1" -- "$cur")
                    return
                    ;;
                --paa-trust-store-path | --cd-trust-store-path | --dac-revocation-set-path)
                    _filedir -d
                    return
                    ;;
                --storage-directory)
                    _filedir -d
                    return
                    ;;
                --trace-to)
                    readarray -t COMPREPLY < <(compgen -W "json perfetto" -- "$cur")
                    compopt -o nospace
                    return
                    ;;
            esac
            
            # Handle read/write/subscribe commands that need attribute/event names
            case "$command" in
                read|write|subscribe)
                    local attributes=$("$chip_tool_cmd" "$cluster" "$command" 2>&1 | awk '/ [|] [*] /{ print $3 }')
                    case "$cur" in
                        -*)
                            local options=$("$chip_tool_cmd" "$cluster" "$command" --help 2>&1 | awk -F'[[]|[]]' '/^[[]--/{ print $2 }')
                            readarray -t COMPREPLY < <(compgen -W "$options" -- "$cur")
                            ;;
                        *)
                            readarray -t COMPREPLY < <(compgen -W "$attributes" -- "$cur")
                            ;;
                    esac
                    return
                    ;;
                read-event|subscribe-event)
                    local events=$("$chip_tool_cmd" "$cluster" "$command" 2>&1 | awk '/ [|] [*] /{ print $3 }')
                    case "$cur" in
                        -*)
                            local options=$("$chip_tool_cmd" "$cluster" "$command" --help 2>&1 | awk -F'[[]|[]]' '/^[[]--/{ print $2 }')
                            readarray -t COMPREPLY < <(compgen -W "$options" -- "$cur")
                            ;;
                        *)
                            readarray -t COMPREPLY < <(compgen -W "$events" -- "$cur")
                            ;;
                    esac
                    return
                    ;;
            esac
            
            # For other commands, complete options
            case "$cur" in
                -*)
                    local options=$("$chip_tool_cmd" "$cluster" "$command" --help 2>&1 | awk -F'[[]|[]]' '/^[[]--/{ print $2 }')
                    readarray -t COMPREPLY < <(compgen -W "$options" -- "$cur")
                    ;;
            esac
            return
            ;;
        *)
            # Three or more arguments - complete based on the specific command context
            local cluster="${args[0]}"
            local command="${args[1]}"
            local subcommand="${args[2]}"
            
            # Handle common options
            case "$prev" in
                --commissioner-name)
                    readarray -t COMPREPLY < <(compgen -W "alpha beta gamma 4 5 6 7 8 9" -- "$cur")
                    return
                    ;;
                --only-allow-trusted-cd-keys)
                    readarray -t COMPREPLY < <(compgen -W "0 1" -- "$cur")
                    return
                    ;;
                --paa-trust-store-path | --cd-trust-store-path | --dac-revocation-set-path)
                    _filedir -d
                    return
                    ;;
                --storage-directory)
                    _filedir -d
                    return
                    ;;
                --trace-to)
                    readarray -t COMPREPLY < <(compgen -W "json perfetto" -- "$cur")
                    compopt -o nospace
                    return
                    ;;
            esac
            
            # For read/write/subscribe with attribute/event, complete options
            case "$command" in
                read|write|subscribe|read-event|subscribe-event)
                    case "$cur" in
                        -*)
                            # Complete command-specific options
                            local cmd_args=("$chip_tool_cmd" "$cluster" "$command")
                            if [[ -n "$subcommand" && "$subcommand" != -* ]]; then
                                cmd_args+=("$subcommand")
                            fi
                            cmd_args+=("--help")
                            local options=$("${cmd_args[@]}" 2>&1 | awk -F'[[]|[]]' '/^[[]--/{ print $2 }')
                            readarray -t COMPREPLY < <(compgen -W "$options" -- "$cur")
                            ;;
                    esac
                    return
                    ;;
            esac
            
            # For other commands, complete options
            case "$cur" in
                -*)
                    local cmd_args=("$chip_tool_cmd" "$cluster" "$command")
                    if [[ -n "$subcommand" && "$subcommand" != -* ]]; then
                        cmd_args+=("$subcommand")
                    fi
                    cmd_args+=("--help")
                    local options=$("${cmd_args[@]}" 2>&1 | awk -F'[[]|[]]' '/^[[]--/{ print $2 }')
                    readarray -t COMPREPLY < <(compgen -W "$options" -- "$cur")
                    ;;
            esac
            return
            ;;
    esac
}

complete -F _chip_build_example scripts/build/build_examples.py
complete -F _chip_build_example build_examples.py

complete -F _chip_app chip-air-purifier-app
complete -F _chip_app chip-all-clusters-app
complete -F _chip_app chip-bridge-app
complete -F _chip_app chip-dishwasher-app
complete -F _chip_app chip-energy-gateway-app
complete -F _chip_app chip-evse-app
complete -F _chip_app chip-lighting-app
complete -F _chip_app chip-lock-app
complete -F _chip_app chip-log-source-app
complete -F _chip_app chip-microwave-oven-app
complete -F _chip_app chip-ota-provider-app
complete -F _chip_app chip-ota-requestor-app
complete -F _chip_app chip-refrigerator-app
complete -F _chip_app chip-rvc-app
complete -F _chip_app chip-tv-app
complete -F _chip_app chip-tv-casting-app
complete -F _chip_app matter-water-heater-app

complete -F _chip_tool chip-tool
