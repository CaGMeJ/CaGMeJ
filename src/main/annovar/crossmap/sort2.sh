set -xv
set -e

tmp=
for i in `seq -f %02g $(( $1 * 10 ))  $(( $1 * 10 + 9 ))`
do
    tmp="$tmp ${3}${i}${4}"
done
sort -m -V -k 1,3 -T $2 $tmp > ${3}${1}${4}.tmp
