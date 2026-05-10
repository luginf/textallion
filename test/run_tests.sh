#!/usr/bin/env bash
# Non-regression tests for Textallion.
# Generates outputs and diffs them against reference files in test/ok/.
# PDF is excluded (non-deterministic); HTML and TEX are compared.

set -e
cd "$(dirname "$0")"

PASS=0
FAIL=0
ERRORS=""

check() {
    local file="$1"
    if [ ! -f "ok/${file}" ]; then
        echo "  [SKIP] no reference for ${file}"
        return
    fi
    if diff -q "ok/${file}" "${file}" > /dev/null 2>&1; then
        echo "  [OK]   ${file}"
        PASS=$((PASS + 1))
    else
        echo "  [FAIL] ${file}"
        diff "ok/${file}" "${file}" | head -20
        FAIL=$((FAIL + 1))
        ERRORS="${ERRORS} ${file}"
    fi
}

echo "=== Building examples ==="
export TEXTALLIONDOC=examples
make html
make pdf
check examples.html
check examples.tex

echo ""
echo "=== Building sample_cyoa ==="
export TEXTALLIONDOC=sample_cyoa
make cyoa-html
make cyoa-pdf
check sample_cyoa.html
check sample_cyoa.tex

echo ""
echo "=== Building exemple_lettre ==="
export TEXTALLIONDOC=exemple_lettre
make lettre
check exemple_lettre.html 2>/dev/null || true
check exemple_lettre.tex

echo ""
rm -f ./*.toc ./*.out ./*.log ./*.aux ./*.idx ./*.tns ./*.ilg ./*.ind

echo "==============================="
echo "Passed: ${PASS}  Failed: ${FAIL}"
if [ "${FAIL}" -gt 0 ]; then
    echo "Failing files:${ERRORS}"
    exit 1
fi
