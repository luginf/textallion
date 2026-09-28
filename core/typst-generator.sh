#!/bin/sh
# typst-generator: build a Typst (.typ) document from an HTML file, using
# pandoc. Mirrors epub-generator.sh, for the same reason: rely on pandoc's
# converter instead of a hand-written txt2tags target (txt2tags itself has
# no "typst" target).
#
# Usage:
#   typst-generator INPUT.html OUTPUT.typ [options]
#
# Options:
#   --title TEXT     document title
#   --author TEXT    author (comma-separated for several)
#   --language CODE  language (e.g. fr, en)
#   --pdf FILE       also run "typst compile" on the result, into FILE
#                     (needs the typst CLI: https://github.com/typst/typst)

set -eu

usage() {
    echo "usage: typst-generator INPUT.html OUTPUT.typ [--title TEXT] [--author TEXT] [--language CODE] [--pdf FILE]" >&2
    exit 1
}

[ $# -ge 2 ] || usage

INPUT=$1
OUTPUT=$2
shift 2

TITLE=
AUTHOR=
LANGUAGE=
PDF=

while [ $# -gt 0 ]; do
    case $1 in
        --title) TITLE=$2; shift 2 ;;
        --author|--authors) AUTHOR=$2; shift 2 ;;
        --language) LANGUAGE=$2; shift 2 ;;
        --pdf) PDF=$2; shift 2 ;;
        *) echo "typst-generator: unknown option: $1" >&2; usage ;;
    esac
done

command -v pandoc >/dev/null 2>&1 || {
    echo "typst-generator: pandoc not found in PATH" >&2
    exit 1
}

[ -f "$INPUT" ] || {
    echo "typst-generator: input file not found: $INPUT" >&2
    exit 1
}

set -- pandoc "$INPUT" -o "$OUTPUT" --standalone

[ -n "$TITLE" ] && set -- "$@" --metadata title="$TITLE"
[ -n "$AUTHOR" ] && set -- "$@" --metadata author="$AUTHOR"
[ -n "$LANGUAGE" ] && set -- "$@" --metadata lang="$LANGUAGE"

"$@"

if [ -n "$PDF" ]; then
    command -v typst >/dev/null 2>&1 || {
        echo "typst-generator: --pdf was requested but the typst CLI was not found in PATH (get it from https://github.com/typst/typst)" >&2
        exit 1
    }
    typst compile "$OUTPUT" "$PDF"
fi
