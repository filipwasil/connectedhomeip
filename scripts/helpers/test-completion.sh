#!/bin/bash

# Test script for chip-tool completion
# Source this script to test completion functionality

echo "Testing chip-tool completion setup..."

# Check if chip-tool exists
if [[ -x "out/linux-x64-chip-tool/chip-tool" ]]; then
    echo "✓ Found chip-tool at out/linux-x64-chip-tool/chip-tool"
    CHIP_TOOL_CMD="out/linux-x64-chip-tool/chip-tool"
elif command -v chip-tool >/dev/null 2>&1; then
    echo "✓ Found chip-tool in PATH"
    CHIP_TOOL_CMD="chip-tool"
else
    echo "✗ chip-tool not found - completion will be limited"
    CHIP_TOOL_CMD=""
fi

# Source the completion script
if [[ -f "scripts/helpers/bash-completion.sh" ]]; then
    source scripts/helpers/bash-completion.sh
    echo "✓ Sourced bash completion script"
else
    echo "✗ bash completion script not found"
fi

# Test completion function
if type _chip_tool >/dev/null 2>&1; then
    echo "✓ _chip_tool completion function is available"
else
    echo "✗ _chip_tool completion function not found"
fi

echo ""
echo "To test completion manually:"
echo "1. Run: source scripts/helpers/bash-completion.sh"
if [[ -n "$CHIP_TOOL_CMD" ]]; then
    echo "2. Try: chip-tool <TAB><TAB>  # Should show clusters"
    echo "3. Try: chip-tool onoff <TAB><TAB>  # Should show onoff commands"
    echo "4. Try: chip-tool onoff read <TAB><TAB>  # Should show attributes"
else
    echo "2. Build chip-tool first: scripts/build/build_examples.py --target linux-x64-chip-tool"
fi

echo ""
echo "Completion features:"
echo "• Hierarchical command completion (clusters → commands → attributes)"
echo "• Context-aware option completion"
echo "• Dynamic help parsing"
echo "• Multi-shell support (bash, zsh, fish)"