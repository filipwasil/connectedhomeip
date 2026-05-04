# fish completion for chip-tool
# Copyright (c) 2023 Project CHIP Authors

function __fish_chip_tool_no_subcommand --description 'Test if chip-tool has no subcommand'
    set cmd (commandline -opc)
    set subcommands 0
    for i in $cmd
        if not string match -q -- "-*" $i
            set subcommands (math $subcommands + 1)
        end
    end
    test $subcommands -eq 1
end

function __fish_chip_tool_needs_command --description 'Test if chip-tool needs a command'
    set cmd (commandline -opc)
    set subcommands 0
    for i in $cmd
        if not string match -q -- "-*" $i
            set subcommands (math $subcommands + 1)
        end
    end
    test $subcommands -le 2
end

function __fish_chip_tool_needs_attribute --description 'Test if chip-tool needs an attribute'
    set cmd (commandline -opc)
    set subcommands 0
    for i in $cmd
        if not string match -q -- "-*" $i
            set subcommands (math $subcommands + 1)
        end
    end
    test $subcommands -eq 3
end

function __fish_chip_tool_get_clusters --description 'Get chip-tool clusters'
    set chip_tool_cmd chip-tool
    if test -x "out/linux-x64-chip-tool/chip-tool"
        set chip_tool_cmd out/linux-x64-chip-tool/chip-tool
    end
    $chip_tool_cmd --help 2>/dev/null | awk '/ [|] [*] /{ print $3 }' 2>/dev/null
end

function __fish_chip_tool_get_commands --description 'Get chip-tool commands for a cluster'
    set chip_tool_cmd chip-tool
    if test -x "out/linux-x64-chip-tool/chip-tool"
        set chip_tool_cmd out/linux-x64-chip-tool/chip-tool
    end
    set cluster (commandline -opc)[2]
    if test -n "$cluster"
        $chip_tool_cmd $cluster 2>/dev/null | awk '/ [|] [*] /{ print $3 }' 2>/dev/null
    end
end

function __fish_chip_tool_get_attributes --description 'Get chip-tool attributes for a command'
    set chip_tool_cmd chip-tool
    if test -x "out/linux-x64-chip-tool/chip-tool"
        set chip_tool_cmd out/linux-x64-chip-tool/chip-tool
    end
    set cmd (commandline -opc)
    set cluster ""
    set command ""
    set subcommand ""
    
    for i in $cmd[2..-1]
        if not string match -q -- "-*" $i
            if test -z "$cluster"
                set cluster $i
            else if test -z "$command"
                set command $i
            else if test -z "$subcommand"
                set subcommand $i
                break
            end
        end
    end
    
    if test -n "$cluster"; and test -n "$command"
        switch $command
            case read write subscribe read-event subscribe-event
                $chip_tool_cmd $cluster $command 2>/dev/null | awk '/ [|] [*] /{ print $3 }' 2>/dev/null
        end
    end
end

function __fish_chip_tool_get_options --description 'Get chip-tool options'
    set chip_tool_cmd chip-tool
    if test -x "out/linux-x64-chip-tool/chip-tool"
        set chip_tool_cmd out/linux-x64-chip-tool/chip-tool
    end
    set cmd (commandline -opc)
    set args $chip_tool_cmd
    
    for i in $cmd[2..-1]
        if not string match -q -- "-*" $i
            set args $args $i
        end
    end
    
    set args $args --help
    $args 2>/dev/null | awk -F'[[]|[]]' '/^[[]--/{ print $2 }' 2>/dev/null
end

# Main chip-tool completion
complete -c chip-tool -n '__fish_chip_tool_needs_command' -xa '(__fish_chip_tool_get_clusters)' -d 'Cluster or command set'
complete -c chip-tool -n '__fish_chip_tool_needs_command' -l help -d 'Print help'
complete -c chip-tool -n '__fish_chip_tool_needs_command' -l version -d 'Print version'

# Command completion for clusters
complete -c chip-tool -n '__fish_chip_tool_no_subcommand' -xa '(__fish_chip_tool_get_commands)' -d 'Command'

# Attribute/Event completion for read/write/subscribe commands
complete -c chip-tool -n '__fish_chip_tool_needs_attribute' -xa '(__fish_chip_tool_get_attributes)' -d 'Attribute or event'

# Option completion
complete -c chip-tool -n 'not __fish_chip_tool_needs_command' -xa '(__fish_chip_tool_get_options)' -d 'Option'

# Common options with specific completions
complete -c chip-tool -l commissioner-name -xa 'alpha beta gamma 4 5 6 7 8 9' -d 'Name of fabric to use'
complete -c chip-tool -l only-allow-trusted-cd-keys -xa '0 1' -d 'Only allow trusted CD verifying keys'
complete -c chip-tool -l paa-trust-store-path -xa '(__fish_complete_directories)' -d 'Path to PAA certificate directory'
complete -c chip-tool -l cd-trust-store-path -xa '(__fish_complete_directories)' -d 'Path to CD certificate directory'
complete -c chip-tool -l dac-revocation-set-path -xa '(__fish_complete_directories)' -d 'Path to DAC revocation set'
complete -c chip-tool -l storage-directory -xa '(__fish_complete_directories)' -d 'Directory for chip-tool storage'
complete -c chip-tool -l trace-to -xa 'json perfetto' -d 'Trace destinations'