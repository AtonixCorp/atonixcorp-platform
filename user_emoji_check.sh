#!/bin/bash

echo "[INFO] Final emoji check across user markdown files only..."
echo "========================================================"

# Search for any remaining emojis in .md files (excluding dependencies)
echo "[SEARCH] Searching for emojis in user .md files..."
EMOJI_COUNT=$(find . -name "*.md" -not -path "*/node_modules/*" -not -path "*/venv/*" -exec grep -c "🎉\|📦\|🚢\|🔐\|📋\|🏗\|🐳\|🔧\|📊\|🛡\|📁\|🎯\|🌐\|🔒\|📚\|🚨\|📞\|🔗\|✅\|⚠\|ℹ\|⚙\|🔄\|📈\|📝\|🔍\|🏥\|📱" {} + 2>/dev/null | awk -F: '{sum+=$2} END {print sum+0}')

if [[ $EMOJI_COUNT -gt 0 ]]; then
    echo "[WARNING] Found $EMOJI_COUNT emojis in user markdown files:"
    echo "----------------------------------------"
    find . -name "*.md" -not -path "*/node_modules/*" -not -path "*/venv/*" -exec grep -H "🎉\|📦\|🚢\|🔐\|📋\|🏗\|🐳\|🔧\|📊\|🛡\|📁\|🎯\|🌐\|🔒\|📚\|🚨\|📞\|🔗\|✅\|⚠\|ℹ\|⚙\|🔄\|📈\|📝\|🔍\|🏥\|📱" {} + 2>/dev/null | head -10
    echo "----------------------------------------"
else
    echo "[SUCCESS] No emojis found in user markdown files!"
fi

echo ""
echo "[SUMMARY] User markdown file emoji check completed!"
echo "========================================================"

if [[ $EMOJI_COUNT -eq 0 ]]; then
    echo "[SUCCESS] All emojis have been successfully removed from user markdown files!"
else
    echo "[ACTION REQUIRED] $EMOJI_COUNT emojis still exist in user files and need removal."
fi