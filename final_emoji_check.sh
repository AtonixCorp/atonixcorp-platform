#!/bin/bash

echo "[INFO] Final emoji check across all markdown files..."
echo "=================================================="

# Search for any remaining emojis in all .md files
echo "[SEARCH] Searching for emojis in all .md files..."
EMOJI_COUNT=$(find . -name "*.md" -exec grep -P "[\x{1F600}-\x{1F64F}]|[\x{1F300}-\x{1F5FF}]|[\x{1F680}-\x{1F6FF}]|[\x{1F1E0}-\x{1F1FF}]|[\x{2600}-\x{26FF}]|[\x{2700}-\x{27BF}]|[\x{1F900}-\x{1F9FF}]|[\x{1F018}-\x{1F270}]|[\x{238C}-\x{2454}]|[\x{20D0}-\x{20FF}]|[\U0001F600-\U0001F64F]|[\U0001F300-\U0001F5FF]|[\U0001F680-\U0001F6FF]|[\U0001F1E0-\U0001F1FF]|[\U0001F900-\U0001F9FF]" {} + 2>/dev/null | wc -l)

if [[ $EMOJI_COUNT -gt 0 ]]; then
    echo "[WARNING] Found $EMOJI_COUNT potential emojis in markdown files:"
    echo "----------------------------------------"
    find . -name "*.md" -exec grep -H -P "[\x{1F600}-\x{1F64F}]|[\x{1F300}-\x{1F5FF}]|[\x{1F680}-\x{1F6FF}]|[\x{1F1E0}-\x{1F1FF}]|[\x{2600}-\x{26FF}]|[\x{2700}-\x{27BF}]|[\x{1F900}-\x{1F9FF}]|[\x{1F018}-\x{1F270}]|[\x{238C}-\x{2454}]|[\x{20D0}-\x{20FF}]|[\U0001F600-\U0001F64F]|[\U0001F300-\U0001F5FF]|[\U0001F680-\U0001F6FF]|[\U0001F1E0-\U0001F1FF]|[\U0001F900-\U0001F9FF]" {} + 2>/dev/null
    echo "----------------------------------------"
else
    echo "[OK] No emojis found in markdown files!"
fi

# Alternative search using a broader pattern for common emojis
echo ""
echo "[SEARCH] Alternative search using common emoji patterns..."
ALT_COUNT=$(find . -name "*.md" -exec grep -E "[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F900}-\u{1F9FF}]|[😀-🙏]|[🌀-🗿]|[🚀-🛿]|[⚀-⚙]|[✀-➿]|[♠-♿]|[⭐⭕⬆⬇⬅➡⤴⤵]" {} + 2>/dev/null | wc -l)

if [[ $ALT_COUNT -gt 0 ]]; then
    echo "[WARNING] Found $ALT_COUNT potential emojis with alternative search:"
    echo "----------------------------------------"
    find . -name "*.md" -exec grep -H -E "[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F900}-\u{1F9FF}]|[😀-🙏]|[🌀-🗿]|[🚀-🛿]|[⚀-⚙]|[✀-➿]|[♠-♿]|[⭐⭕⬆⬇⬅➡⤴⤵]" {} + 2>/dev/null
    echo "----------------------------------------"
else
    echo "[OK] No emojis found with alternative search!"
fi

# Simple search for common emoji characters
echo ""
echo "[SEARCH] Simple search for remaining common emoji characters..."
SIMPLE_COUNT=0

# Check for some specific emojis that might have been missed
for emoji in "🎉" "📦" "🚢" "🔐" "📋" "🏗" "🐳" "🔧" "📊" "🛡" "📁" "🎯" "🌐" "🔒" "📚" "🚨" "📞" "🔗" "✅" "⚠" "ℹ" "⚙" "🔄" "📈" "📝" "🔍" "🏥" "📱"; do
    emoji_count=$(find . -name "*.md" -exec grep -F "$emoji" {} + 2>/dev/null | wc -l)
    if [[ $emoji_count -gt 0 ]]; then
        echo "[FOUND] $emoji appears $emoji_count times"
        SIMPLE_COUNT=$((SIMPLE_COUNT + emoji_count))
    fi
done

if [[ $SIMPLE_COUNT -gt 0 ]]; then
    echo "[WARNING] Found $SIMPLE_COUNT specific emoji instances!"
else
    echo "[OK] No specific emojis found!"
fi

echo ""
echo "[SUMMARY] Emoji removal check completed!"
echo "=================================================="

if [[ $EMOJI_COUNT -eq 0 && $ALT_COUNT -eq 0 && $SIMPLE_COUNT -eq 0 ]]; then
    echo "[SUCCESS] All emojis have been removed from markdown files!"
else
    echo "[ACTION REQUIRED] Some emojis may still exist and need manual removal."
fi