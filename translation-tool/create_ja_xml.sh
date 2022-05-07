#!/bin/bash

EN_JP_TEXT="$1"
DAT_DIR="$2"
OUTPUT_DIR="$3"
TARGET_TAG="${4:-text}"

[[ -f "$EN_JP_TEXT" ]] || exit 1
[[ -d "$DAT_DIR" ]] || exit 1
[[ -z "$OUTPUT_DIR" ]] && exit 1

REPLACE_TEXT_PY=/tmp/replace_text.$$.py
trap "/bin/rm $REPLACE_TEXT_PY" EXIT
cat - <<EOT >$REPLACE_TEXT_PY
import sys
import re

jp_text = {}
for line in open(sys.argv[1], 'br'):
    sp = line.split(b'\t')
    #print(f"{len(sp)} {line}", file=sys.stderr)
    if len(sp) == 2:
        #print(f"translate list [{sp[0]}]", file=sys.stderr)
        jp_text[sp[0]] = sp[1].strip()
target_tag = sys.argv[2].encode('utf-8')

text_re = re.compile(rb'(.*<' + target_tag + rb'[^>]*>)(.*)(</' + target_tag + rb'>.*)')
n = 0
for line in sys.stdin.buffer:
    n += 1
    line = line.rstrip()
    #print(type(line), file=sys.stderr)
    m = text_re.match(line)
    if m:
        print(f"line {n} match. [{m.group(2)}]", file=sys.stderr)
        if m.group(2) in jp_text:
            print((m.group(1) + jp_text[m.group(2)] + m.group(3)).decode('utf-8', 'ignore'))
            #sys.stdout.buffer.write( + b'\n')
            continue
    print(line.decode('utf-8', 'ignore'))
    #sys.stdout.buffer.write(line + b'\n')
EOT

mkdir -p "$OUTPUT_DIR"

grep -H "<${TARGET_TAG}.*</${TARGET_TAG}" ${DAT_DIR}/*.xml* |
sed 's/:.*//'                 |
sort -u                       |
while read filename; do
    echo "$filename -> $OUTPUT_DIR/$(basename $filename)"
    python $REPLACE_TEXT_PY $EN_JP_TEXT $TARGET_TAG < "${filename}" > "$OUTPUT_DIR/$(basename $filename)"
done
