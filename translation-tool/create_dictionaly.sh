#!/bin/bash
#
# FTLのMODの <text>....</text> の英和翻訳をtransコマンドで翻訳する.
#
# 翻訳結果は、
#   英語Text TAB 日本語翻訳Text 
# になる.
#

INPUT_DIR="$1"
TARTGET_TAG="$2"
shift 2

LANGUAGE=en:ja
TAB=$(echo -e "\t")
TMPDIR=/tmp/generate_translation.tmp.$$/
mkdir -p $TMPDIR
#trap "/bin/rm -rf $TMPDIR" EXIT

info() {
    echo -e "$(date +'%y/%m/%d %H:%M:%S'): $@" >&2 
}

warn() {
    echo -e "$(date +'%y/%m/%d %H:%M:%S'): $(tput setaf 1)$@$(tput sgr0)" >&2 
}


grep -h "<${TARTGET_TAG}[^>]*>.*</${TARTGET_TAG}>" ${INPUT_DIR}/*.xml* |
sed 's#<!--.*##'                                                       |
grep "<${TARTGET_TAG}[^>]*>.*</${TARTGET_TAG}>"                        |
sed 's#.*<'${TARTGET_TAG}'[^>]*>\(.*\)</'${TARTGET_TAG}'>.*#\1#'       |
sort -u > $TMPDIR/new_en_text.txt

cat "$@" $TMPDIR/new_en_text.txt |
sort -u                          |
gawk -F"$TAB" '
    $1 != EN_TEXT {
        if (EN_TEXT != "") {
            print EN_TEXT "\t" JP_TEXT
        }
        EN_TEXT = $1
    }
    $2 != "" {
        JP_TEXT = $2
    }
    END {
        if (EN_TEXT != "") {
            print EN_TEXT "\t" JP_TEXT
        }
    }
' > $TMPDIR/merged_text.txt

TOTAL=$(wc -l < $TMPDIR/merged_text.txt)
NO=1

cat $TMPDIR/merged_text.txt |
while IFS="$TAB" read en_text jp_text; do
    [[ "$en_text" == "" ]] && continue
    if [[ "$jp_text" == "" ]]; then
        RETRY=0
        while [[ "$jp_text" == "" ]]; do
            sleep $((RANDOM % 5 + 5 + RETRY * 5))
            jp_text="$(echo $en_text | trans -no-ansi -b 2>/dev/null)"
            (( RETRY++ ))
            if [[ $RETRY -gt 5 ]]; then
                warn "変換失敗."
            fi
        done
    fi
    printf "%s\t%s\n" "$en_text" "$jp_text"
    echo -e $TEXT
    # info "[$NO/$TOTAL] $TEXT"
    echo -n "." >&2
    (( NO++ ))
    unset en_text
    unset jp_text
done > $TMPDIR/tranlated1.txt

# 翻訳の調整
< $TMPDIR/tranlated1.txt python -c '
import sys
import re

re_kakko              = re.compile(r"([(（][^)）]*[)）] *)")
re_prototype_excnahge = re.compile(r"\(Prototype\) Exchange your (.*)\.")
re_prototype_sell     = re.compile(r"\(Prototype\) Sell your (.*)\.")
re_utf                = re.compile(r"u[0-9a-f][0-9a-f][0-9a-f][0-9a-f]")

for line in sys.stdin:
    line = line.rstrip()
    sp = line.split("\t")
    if len(sp) == 2:
        left = sp[0]
        right = sp[1]
        # (xxxx) は特別扱い
        if line[0] == "(":
            m = re_kakko.match(left)
            if m:
                right = re_kakko.sub(m.group(1), right)
            # (Prototype) Exchange your ... は、翻訳書き換え
            m = re_prototype_excnahge.match(left)
            if m:
                right = "(Prototype) " + m.group(1) + "を交換します。"
            # (Prototype) Sell your ... は、翻訳書き換え
            m = re_prototype_sell.match(left)
            if m:
                right = "(Prototype) " + m.group(1) + "を売ります。"
        # = などがuXXXXになっているので変換
        m = re_utf.search(right)
        if m:
            right = re.sub(r"u003d", "=", right)
            right = re.sub(r"u200b", "", right)
        line = left + "\t" + right
    # 表示
    print(line)
' |
sed '/^ *$/d' |
sort -u

