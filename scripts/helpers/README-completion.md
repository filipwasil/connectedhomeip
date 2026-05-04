# Chip-Tool Shell Completion

This directory contains enhanced shell completion scripts for the chip-tool command-line interface. The completion scripts provide intelligent tab completion for chip-tool commands, making it easier to use the tool interactively.

## Features

The enhanced completion provides:

1. **Hierarchical Command Completion**: Complete clusters → commands → attributes/events
2. **Context-Aware Options**: Complete only relevant options for the current command context
3. **Dynamic Content**: Extract completion data directly from chip-tool help output
4. **Multi-Shell Support**: Bash, Zsh, and Fish shell completion

## Installation

### Bash Completion

To enable bash completion:

```bash
# Source the completion script
source scripts/helpers/bash-completion.sh

# Or add to your ~/.bashrc for permanent installation
echo "source $(pwd)/scripts/helpers/bash-completion.sh" >> ~/.bashrc
```

### Zsh Completion

To enable zsh completion:

```bash
# Source the completion script
source scripts/helpers/zsh-completion.zsh

# Or add to your ~/.zshrc for permanent installation
echo "source $(pwd)/scripts/helpers/zsh-completion.zsh" >> ~/.zshrc
```

### Fish Completion

To enable fish completion:

```bash
# Copy or link the completion file to fish completion directory
mkdir -p ~/.config/fish/completions
ln -sf $(pwd)/scripts/helpers/fish-completion.fish ~/.config/fish/completions/chip-tool.fish
```

## Usage

Once installed, you can use tab completion with chip-tool:

```bash
# Complete cluster names
chip-tool <TAB><TAB>
chip-tool on<TAB>          # Completes to 'onoff'

# Complete commands for a cluster
chip-tool onoff <TAB><TAB>
chip-tool onoff re<TAB>    # Completes to 'read'

# Complete attributes for read/write commands
chip-tool onoff read <TAB><TAB>
chip-tool onoff read on<TAB>   # Completes to 'on-off'

# Complete options based on context
chip-tool onoff read on-off <TAB><TAB>  # Shows relevant options
chip-tool onoff read on-off --<TAB><TAB>
```

## Completion Hierarchy

The completion follows the chip-tool command structure:

1. **First Level**: Cluster names and command sets
   - `accesscontrol`, `onoff`, `doorlock`, etc.
   - `pairing`, `discover`, `dcl`, etc.

2. **Second Level**: Commands within a cluster
   - `read`, `write`, `subscribe` for attributes
   - `read-event`, `subscribe-event` for events
   - Specific commands like `on`, `off`, `toggle`

3. **Third Level**: Attributes or events (for read/write/subscribe)
   - `on-off`, `global-scene-control` for onoff cluster
   - Event names for event commands

4. **Additional Levels**: Command-specific options and parameters

## Supported Shells

- **Bash**: Full hierarchical completion with option value completion
- **Zsh**: Full hierarchical completion with integrated help text
- **Fish**: Full hierarchical completion with descriptions

## How It Works

The completion scripts work by:

1. **Dynamic Help Parsing**: Calling `chip-tool --help` and parsing the output
2. **Context Detection**: Determining the current command context from the command line
3. **Smart Completion**: Providing relevant completions based on the context
4. **Option Extraction**: Extracting available options from command help text

## Troubleshooting

If completion doesn't work:

1. **Ensure chip-tool is built**: The completion requires the chip-tool binary
2. **Check path**: The scripts look for chip-tool in `out/linux-x64-chip-tool/chip-tool`
3. **Verify sourcing**: Make sure the completion script is properly sourced
4. **Restart shell**: Some shells require a restart to load new completions

## Customization

You can customize the completion behavior by modifying the scripts:

- Add new option value completions
- Extend context-aware completion logic
- Add support for additional chip-tool features

The completion scripts are designed to be maintainable and extensible.