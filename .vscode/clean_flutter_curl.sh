#!/usr/bin/env bash

set -e

# ---------- Detect OS ----------
OS="$(uname -s)"
echo "📱 OS Detected: $OS"

has() {
  command -v "$1" >/dev/null 2>&1
}

# ---------- Choose clipboard commands ----------
if [[ "$OS" == "Darwin" ]] && has pbpaste && has pbcopy; then
  READ_CLIP="pbpaste"
  WRITE_CLIP="pbcopy"
  echo "✓ Using macOS clipboard (pbpaste/pbcopy)"
elif [[ "$OS" == "Linux" ]] && has wl-paste && has wl-copy; then
  READ_CLIP="wl-paste"
  WRITE_CLIP="wl-copy"
  echo "✓ Using Wayland clipboard (wl-paste/wl-copy)"
elif [[ "$OS" == "Linux" ]] && has xclip; then
  READ_CLIP="xclip -o"
  WRITE_CLIP="xclip -selection clipboard"
  echo "✓ Using X11 clipboard (xclip)"
elif [[ "$OS" =~ MINGW|MSYS|CYGWIN ]] && has powershell.exe; then
  READ_CLIP='powershell.exe -NoProfile -Command Get-Clipboard'
  WRITE_CLIP='powershell.exe -NoProfile -Command Set-Clipboard'
  echo "✓ Using Windows clipboard (PowerShell)"
else
  echo "⚠️  No clipboard support detected. Output will be printed."
  READ_CLIP="cat"
  WRITE_CLIP=""
fi

# ---------- Read clipboard ----------
echo "📋 Reading from clipboard..."
RAW="$($READ_CLIP)"

if [[ -z "$RAW" ]]; then
  echo "❌ Error: Clipboard is empty!"
  echo "   Please copy the Flutter debug output first."
  exit 1
fi

echo "✓ Clipboard read (${#RAW} chars)"

# ---------- Clean & extract curl ----------
echo "🔍 Extracting curl command..."
RESULT="$(echo "$RAW" \
  | sed -E 's/^flutter:\s*//' \
  | sed -E 's/^[[:space:]]*(║|╔|╚|╣|═)+[[:space:]]*//' \
  | sed -E 's/[[:space:]]+(║|╔|╚|╣|═)+$//' \
  | grep -v '^[[:space:]]*$' \
  | awk '
      BEGIN { started=0; count=0 }
      /^curl -X/ { started=1 }
      started && NF {
        print
        count++
        if (!/\\$/) exit
      }
      END { if (count == 0) print "" }
  '
)"

if [[ -z "$RESULT" ]]; then
  echo "❌ Error: No curl command found in clipboard"
  echo "   Make sure the output contains 'curl -X'"
  exit 1
fi

echo "✓ Curl command extracted"

# ---------- Write result ----------
if [[ -n "$WRITE_CLIP" ]]; then
  echo "📝 Copying to clipboard using: $WRITE_CLIP"
  
  if echo "$RESULT" | $WRITE_CLIP 2>/dev/null; then
    echo ""
    echo "✅ SUCCESS! Clean cURL copied to clipboard"
    echo "📌 You can now paste it with Cmd+V or Ctrl+V"
  else
    echo "⚠️  Warning: Failed to copy to clipboard"
    echo "📌 Cleaned cURL command:"
    echo ""
    echo "$RESULT"
  fi
else
  echo ""
  echo "⚠️  No clipboard support available"
  echo "📌 Cleaned cURL command:"
  echo ""
  echo "$RESULT"
fi

echo ""
echo "Done!"

