#!/bin/sh
printf '%s;%s\n' "$(date +'%x %X')" "$(wc -l `find . -name '*.ml' -not -wholename '*_build*'` | tail -n 1 | sed -e 's/ \([0-9]*\) total.*/\1/g')"