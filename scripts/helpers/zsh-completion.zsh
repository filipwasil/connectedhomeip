#!/usr/bin/env zsh

#
# build_examples.py completion functions
#

function _matter_build_targets() {
  compadd -S '' -- $(${words[1]} targets --format completion ${words[CURRENT]})
}


function _matter_build_examples() {

  _arguments : \
    "--help[Print help]" \
    "--log-level[Determines the verbosity of script output]:log_level:(debug info warn fatal)" \
    "--verbose[Pass verbose flag to ninja]" \
    "*--target[Define a build target]:target:_matter_build_targets" \
    "--build-profile[Specify the build profile]:build_profile:(default debug debug-optimized release release-size)" \
    "--enable-link-map-file[Enable generation of link map files]" \
    "--enable-flashbundle[Also generate the flashbundles for the app]" \
    "--repo[Path to the root of the CHIP SDK repository checkout]:directory:_files -/" \
    "--out-prefix[Prefix for the generated file output]:directory:_files -/" \
    "--ninja-jobs[Number of ninja jobs]" \
    "--pregen-dir[Directory where generated files have been pre-generated]:directory:_files -/" \
    "--clean[Clean output directory before running the command]" \
    "--dry-run[Only print out shell commands that would be executed]" \
    "--dry-run-output[Where to write the dry run output]:directory:_files -/" \
    "--no-log-timestamps[Skip timestaps in log output]" \
    "--pw-command-launcher[Set pigweed command launcher]:pw_command_launcher:(ccache)" \
    "1:command:->cmds" \
    "*::arg:->args" \
    && return

    case "$state" in
      cmds)
        _values "command" \
          "build[Generate and run ninja/make as needed to compile]" \
          "gen[Generate ninja/makefiles (but does not run the compilation)]" \
          "targets[List the targets that can be used with the build and gen commands]"
        ;;
      args)
        case "$line[1]" in
          build)
            _arguments : \
              "--help[Print help]" \
              "--copy-artifacts-to[Prefix for the generated file output]:directory:_files -/" \
              "--create-archives[Prefix of compressed archives of the generated files]:directory:_files -/" \
              && return
            ;;
          gen)
            _arguments : \
              "--help[Print help]" \
              && return
            ;;
          targets)
            _arguments : \
              "--help[Print help]" \
              "--format:targets_format:(summary expanded json completion)" \
              && return
            ;;
        esac
        ;;
    esac
}


compdef _matter_build_examples scripts/build/build_examples.py

#
# chip-tool completion functions
#


#
# Copied from scripts/helpers/bash-completion.sh
#

# Enhanced chip-tool completion with full command hierarchy support
function _matter_chip_tool_clusters() {
  local chip_tool_cmd
  if [[ -x "out/linux-x64-chip-tool/chip-tool" ]]; then
    chip_tool_cmd="out/linux-x64-chip-tool/chip-tool"
  elif command -v chip-tool >/dev/null 2>&1; then
    chip_tool_cmd="chip-tool"
  else
    return
  fi
  
  local -a clusters=(${(f)"$("$chip_tool_cmd" --help 2>&1 | awk '/ [|] [*] /{ print $3 }')"})
  compadd -- "${clusters[@]}"
}

function _matter_chip_tool_commands() {
  local chip_tool_cmd
  if [[ -x "out/linux-x64-chip-tool/chip-tool" ]]; then
    chip_tool_cmd="out/linux-x64-chip-tool/chip-tool"
  elif command -v chip-tool >/dev/null 2>&1; then
    chip_tool_cmd="chip-tool"
  else
    return
  fi
  
  # Get the cluster name from the arguments
  local cluster=""
  local i
  for ((i = 2; i <= $#words; i++)); do
    if [[ "${words[i]}" != -* ]]; then
      cluster="${words[i]}"
      break
    fi
  done
  
  if [[ -n "$cluster" ]]; then
    local -a commands=(${(f)"$("$chip_tool_cmd" "$cluster" 2>&1 | awk '/ [|] [*] /{ print $3 }')"})
    compadd -- "${commands[@]}"
  fi
}

function _matter_chip_tool_attributes() {
  local chip_tool_cmd
  if [[ -x "out/linux-x64-chip-tool/chip-tool" ]]; then
    chip_tool_cmd="out/linux-x64-chip-tool/chip-tool"
  elif command -v chip-tool >/dev/null 2>&1; then
    chip_tool_cmd="chip-tool"
  else
    return
  fi
  
  # Get cluster and command from arguments
  local cluster=""
  local command=""
  local i
  local non_option_count=0
  
  for ((i = 2; i <= $#words; i++)); do
    if [[ "${words[i]}" != -* ]]; then
      ((non_option_count++))
      if [[ $non_option_count -eq 1 ]]; then
        cluster="${words[i]}"
      elif [[ $non_option_count -eq 2 ]]; then
        command="${words[i]}"
        break
      fi
    fi
  done
  
  if [[ -n "$cluster" && -n "$command" ]]; then
    case "$command" in
      read|write|subscribe|read-event|subscribe-event)
        local -a attributes=(${(f)"$("$chip_tool_cmd" "$cluster" "$command" 2>&1 | awk '/ [|] [*] /{ print $3 }')"})
        compadd -- "${attributes[@]}"
        ;;
    esac
  fi
}

function _matter_chip_tool_options() {
  local chip_tool_cmd
  if [[ -x "out/linux-x64-chip-tool/chip-tool" ]]; then
    chip_tool_cmd="out/linux-x64-chip-tool/chip-tool"
  elif command -v chip-tool >/dev/null 2>&1; then
    chip_tool_cmd="chip-tool"
  else
    compadd -- "--help" "--version"
    return
  fi
  
  # Build command arguments to get context-specific options
  local cmd_args=("$chip_tool_cmd")
  local i
  local non_option_count=0
  
  for ((i = 2; i <= $#words; i++)); do
    if [[ "${words[i]}" != -* ]]; then
      ((non_option_count++))
      cmd_args+=("${words[i]}")
      if [[ $non_option_count -ge 3 ]]; then
        break
      fi
    fi
  done
  
  cmd_args+=("--help")
  local -a options=( ${(f)"$("${cmd_args[@]}" 2>&1 | awk -F'[[]|[]]' '/^[[]--/{ print $2 }')"} )
  compadd -- "${options[@]}"
}

function _matter_chip_tool() {
  local -a orig_words=("${words[@]}")
  local curcontext="$curcontext" state line
  local chip_tool_cmd
  
  if [[ -x "out/linux-x64-chip-tool/chip-tool" ]]; then
    chip_tool_cmd="out/linux-x64-chip-tool/chip-tool"
  elif ! command -v chip-tool >/dev/null 2>&1; then
    _arguments : \
      "--help[Print help]" \
      "--version[Print version]" \
      && return
  fi

  _arguments -C \
    "--help[Print help]" \
    "--version[Print version]" \
    "--commissioner-name[Name of fabric to use]:commissioner:(alpha beta gamma 4 5 6 7 8 9)" \
    "--only-allow-trusted-cd-keys[Only allow trusted CD verifying keys]:(0 1)" \
    "--paa-trust-store-path[Path to PAA certificate directory]:path:_files -/" \
    "--cd-trust-store-path[Path to CD certificate directory]:path:_files -/" \
    "--dac-revocation-set-path[Path to DAC revocation set]:path:_files -/" \
    "--storage-directory[Directory for chip-tool storage]:path:_files -/" \
    "--trace-to[Trace destinations]:(json perfetto)" \
    "*::arg:->args" \
    && return

  case "$state" in
    args)
      local non_option_count=0
      local current_arg_index=0
      
      # Count non-option arguments to determine completion context
      for ((i = 2; i <= CURRENT; i++)); do
        if [[ "${words[i]}" != -* ]]; then
          ((non_option_count++))
          current_arg_index=$((i - 1))
        fi
      done
      
      case "$non_option_count" in
        0)
          # Complete clusters/command sets
          _matter_chip_tool_clusters
          ;;
        1)
          # Complete commands for the cluster
          _matter_chip_tool_commands
          ;;
        2)
          # Complete attributes/events or options
          local cluster=""
          local command=""
          local found_cluster=0
          local found_command=0
          
          for ((i = 2; i <= current_arg_index + 1; i++)); do
            if [[ "${words[i]}" != -* ]]; then
              if [[ $found_cluster -eq 0 ]]; then
                cluster="${words[i]}"
                found_cluster=1
              elif [[ $found_command -eq 0 ]]; then
                command="${words[i]}"
                found_command=1
                break
              fi
            fi
          done
          
          case "$command" in
            read|write|subscribe|read-event|subscribe-event)
              _matter_chip_tool_attributes
              ;;
            *)
              # For other commands, complete options
              _matter_chip_tool_options
              ;;
          esac
          ;;
        *)
          # Complete options for deeper command structure
          _matter_chip_tool_options
          ;;
      esac
      ;;
  esac
}


compdef _matter_chip_tool chip-tool
