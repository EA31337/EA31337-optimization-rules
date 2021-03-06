#!/usr/bin/env bash
# Script to test rules for any errors.
set -e
[ "$TRACE" ] && set -x
ROOT="$(git rev-parse --show-toplevel)"
SETURL="https://raw.githubusercontent.com/EA31337-Tester/EA31337-Lite-Sets/master/EURUSD/default/10000USD/20-spread/5-digits/2014-2015/EA31337-Lite.set"
SETFILE="$ROOT/EA31337-Lite.set.test"
VM_DIR=$(find "$ROOT" -name _VM -type d -print -quit)
TESTER_INI="$VM_DIR/conf/mt4-tester.ini.test"
EA_INI="$VM_DIR/conf/ea.ini.test"
cd "$ROOT"

# Get a set file.
if [ ! -f "${SETFILE%.*}" ]; then
  curl -o "${SETFILE%.*}" "$SETURL"
fi

# Copy files.
cp -f "${SETFILE%.*}" "${SETFILE}"
cp -f "${TESTER_INI%.*}" "${TESTER_INI}"
cp -f "${EA_INI%.*}" "${EA_INI}"

. "$VM_DIR"/scripts/.funcs.inc.sh
. "$VM_DIR"/scripts/.vars.inc.sh
. ./Common/.init.rules.inc

# Invoke each rule.
find "$ROOT" -type f -name "*$1*.rule" -maxdepth 3 -print0 | sort -z | while IFS= read -r -d '' rule_file; do
  echo "Testing $(basename ${rule_file} .rule)..."
  . "$rule_file"
done
find "$ROOT" -type f -name "*.test" -delete
trap - 1 2 3 15 ERR EXIT
echo $0 OK
