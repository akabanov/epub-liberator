#!/usr/bin/env bash

set -euo pipefail

# Get the directory to process (default to current directory)
TARGET_DIR="${1:-.}"

# Convert to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# Create fixed directory
FIXED_DIR="$TARGET_DIR/fixed"
mkdir -p "$FIXED_DIR"

echo "Processing EPUB files in: $TARGET_DIR"
echo "Output directory: $FIXED_DIR"
echo ""

# Process each EPUB file in the directory (non-recursive)
for epub_file in "$TARGET_DIR"/*.epub; do
    # Check if any epub files exist (glob didn't match)
    [ -e "$epub_file" ] || { echo "No EPUB files found in $TARGET_DIR"; exit 0; }

    # Get the base filename
    basename_orig="$(basename "$epub_file")"

    # Remove _OceanofPDF.com_ from the filename
    basename_fixed="${basename_orig//_OceanofPDF.com_/}"

    output_file="$FIXED_DIR/$basename_fixed"

    echo "Processing: $basename_orig"
    echo "  -> $basename_fixed"

    # Create a temporary directory for this specific epub
    temp_dir="$(mktemp -d)"

    # Extract the EPUB to temp directory
    unzip -q "$epub_file" -d "$temp_dir"

    # Process XHTML files - remove OceanofPDF.com promotional divs
    if [ -d "$temp_dir/OEBPS/Text" ]; then
        find "$temp_dir/OEBPS/Text" -type f -name "*.xhtml" | while read -r xhtml_file; do
            # Remove the exact OceanofPDF.com div string
            sed 's|<div style="float: none; margin: 10px 0px 10px 0px; text-align: center;"><p><a href="https://oceanofpdf\.com"><i>OceanofPDF\.com</i></a></p></div>||g' "$xhtml_file" > "$xhtml_file.tmp"
            mv -f "$xhtml_file.tmp" "$xhtml_file"
        done
    fi

    # Process CSS files - remove lines with line-height:1.2;
    if [ -d "$temp_dir/OEBPS/Styles" ]; then
        find "$temp_dir/OEBPS/Styles" -type f -name "*.css" | while read -r css_file; do
            # Remove lines containing line-height:1.2;
            if grep -q "line-height:1\.2;" "$css_file"; then
                grep -v "line-height:1\.2;" "$css_file" > "$css_file.tmp"
                mv -f "$css_file.tmp" "$css_file"
            fi
        done
    fi

    # Recreate the EPUB file
    # EPUB files must have mimetype as first file, uncompressed
    (
        cd "$temp_dir"
        # Add mimetype first (uncompressed)
        zip -0 -X -q "$output_file" mimetype
        # Add everything else (compressed)
        zip -r -9 -X -q "$output_file" . -x mimetype
    )

    # Clean up temp directory for this file
    rm -rf "$temp_dir"

    echo "  ✓ Done"
    echo ""
done

echo "Processing complete!"
