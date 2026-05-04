#!/bin/bash

# Demo script showing chip-tool completion capabilities
# This script demonstrates the enhanced completion functionality

echo "Chip-Tool Enhanced Completion Demo"
echo "=================================="
echo ""

# Check prerequisites
if [[ ! -x "out/linux-x64-chip-tool/chip-tool" ]]; then
    echo "Error: chip-tool not found at out/linux-x64-chip-tool/chip-tool"
    echo "Please build chip-tool first:"
    echo "  scripts/build/build_examples.py --target linux-x64-chip-tool"
    echo ""
    exit 1
fi

echo "✓ Using chip-tool: out/linux-x64-chip-tool/chip-tool"
echo ""

# Show available clusters
echo "Available Clusters/Command Sets:"
echo "-------------------------------"
out/linux-x64-chip-tool/chip-tool --help 2>&1 | awk '/ [|] [*] /{ print "  • " $3 }' | head -10
echo "  ... (and many more)"
echo ""

# Show onoff commands
echo "OnOff Cluster Commands:"
echo "----------------------"
out/linux-x64-chip-tool/chip-tool onoff 2>&1 | awk '/ [|] [*] /{ print "  • " $3 }' | head -10
echo ""

# Show onoff read attributes
echo "OnOff Cluster Read Attributes:"
echo "-----------------------------"
out/linux-x64-chip-tool/chip-tool onoff read 2>&1 | awk '/ [|] [*] /{ print "  • " $3 }'
echo ""

# Show completion installation
echo "Installation Instructions:"
echo "-------------------------"
echo "To enable enhanced completion, add this line to your ~/.bashrc:"
echo "  source $(pwd)/scripts/helpers/bash-completion.sh"
echo ""
echo "For zsh, add this line to your ~/.zshrc:"
echo "  source $(pwd)/scripts/helpers/zsh-completion.zsh"
echo ""
echo "For fish, link the completion file:"
echo "  mkdir -p ~/.config/fish/completions"
echo "  ln -sf $(pwd)/scripts/helpers/fish-completion.fish ~/.config/fish/completions/chip-tool.fish"
echo ""

echo "Enhanced Features:"
echo "-----------------"
echo "• Complete cluster names: chip-tool <TAB><TAB>"
echo "• Complete commands: chip-tool onoff <TAB><TAB>"
echo "• Complete attributes: chip-tool onoff read <TAB><TAB>"
echo "• Context-aware options: chip-tool onoff read on-off --<TAB><TAB>"
echo "• Value completion for common options"
echo "• Multi-shell support (bash, zsh, fish)"
echo ""

echo "The completion dynamically parses chip-tool help output to provide"
echo "accurate and up-to-date completions for all available commands."