#!/bin/sh
# epub-generator: build an EPUB from an HTML file using pandoc.
# Replaces the Calibre "ebook-convert" + "ebook-meta" pair used by textallion.
#
# Usage:
#   epub-generator INPUT.html OUTPUT.epub [options]
#
# Options:
#   --title TEXT        dc:title
#   --authors TEXT       dc:creator
#   --language CODE      dc:language (e.g. fr, en)
#   --tags TEXT          comma-separated list -> multiple dc:subject
#   --comments TEXT       dc:description
#   --producer TEXT       dc:publisher
#   --cover FILE          cover image (jpg/png)
#   --css FILE            stylesheet to embed
#   --toc-depth N         table of contents depth (default 3)
#   --split-level N       chapter split level, 1-6 (default 1)

set -eu

usage() {
    echo "usage: epub-generator INPUT.html OUTPUT.epub [--title TEXT] [--authors TEXT] [--language CODE] [--tags TEXT] [--comments TEXT] [--producer TEXT] [--cover FILE] [--css FILE] [--toc-depth N] [--split-level N]" >&2
    exit 1
}

[ $# -ge 2 ] || usage

INPUT=$1
OUTPUT=$2
shift 2

TITLE=
AUTHORS=
LANGUAGE=
TAGS=
COMMENTS=
PRODUCER=
COVER=
CSS=
TOC_DEPTH=3
SPLIT_LEVEL=1

while [ $# -gt 0 ]; do
    case $1 in
        --title) TITLE=$2; shift 2 ;;
        --authors) AUTHORS=$2; shift 2 ;;
        --language) LANGUAGE=$2; shift 2 ;;
        --tags) TAGS=$2; shift 2 ;;
        --comments) COMMENTS=$2; shift 2 ;;
        --producer) PRODUCER=$2; shift 2 ;;
        --cover) COVER=$2; shift 2 ;;
        --css) CSS=$2; shift 2 ;;
        --toc-depth) TOC_DEPTH=$2; shift 2 ;;
        --split-level) SPLIT_LEVEL=$2; shift 2 ;;
        *) echo "epub-generator: unknown option: $1" >&2; usage ;;
    esac
done

command -v pandoc >/dev/null 2>&1 || {
    echo "epub-generator: pandoc not found in PATH" >&2
    exit 1
}

[ -f "$INPUT" ] || {
    echo "epub-generator: input file not found: $INPUT" >&2
    exit 1
}

METAFILE=$(mktemp)
trap 'rm -f "$METAFILE"' EXIT

xml_escape() {
    printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'
}

if [ -n "$TAGS" ]; then
    OLDIFS=$IFS
    IFS=,
    for tag in $TAGS; do
        tag=$(echo "$tag" | sed -e 's/^ *//' -e 's/ *$//')
        [ -n "$tag" ] && printf '<dc:subject>%s</dc:subject>\n' "$(xml_escape "$tag")" >> "$METAFILE"
    done
    IFS=$OLDIFS
fi
[ -n "$COMMENTS" ] && printf '<dc:description>%s</dc:description>\n' "$(xml_escape "$COMMENTS")" >> "$METAFILE"
[ -n "$PRODUCER" ] && printf '<dc:publisher>%s</dc:publisher>\n' "$(xml_escape "$PRODUCER")" >> "$METAFILE"

set -- pandoc "$INPUT" -o "$OUTPUT" --toc-depth="$TOC_DEPTH" --split-level="$SPLIT_LEVEL"

[ -n "$TITLE" ] && set -- "$@" --metadata title="$TITLE"
[ -n "$AUTHORS" ] && set -- "$@" --metadata author="$AUTHORS"
[ -n "$LANGUAGE" ] && set -- "$@" --metadata lang="$LANGUAGE"
[ -s "$METAFILE" ] && set -- "$@" --epub-metadata="$METAFILE"
[ -n "$COVER" ] && set -- "$@" --epub-cover-image="$COVER"
[ -n "$CSS" ] && set -- "$@" --css="$CSS"

"$@"
