set -e
sort -k 1,3 -V  $1 | \
    grep -e ^[1-9][[:space:]]  -e ^1[0-9][[:space:]] -e ^2[0-2][[:space:]] -e ^X[[:space:]] -e ^Y[[:space:]]  \
    > $2
