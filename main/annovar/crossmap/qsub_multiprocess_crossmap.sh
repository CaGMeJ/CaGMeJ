#$ -cwd
#$ -l s_vmem=64G
set -e
set -xv

#1) hg19_txtが変換するhg19のデータベースのパスです。
#2) pythonがbiopythonとcrossmapが使えるようにパスを通したりなど準備してください。
#3) 引数に文字列(eigenやfathmm)を設定して使うことを想定しています。

fasta=SCRIPT_DIR/database/GRCh38/Homo_sapiens_assembly38.fasta
chain=hg19ToHg38.over.chain.gz

hg19_prefix=hg19_${1}
hg38_prefix=hg38_${1}
hg19_bed=hg19_${1}.bed
hg38_bed=hg38_${1}.bed
hg19_txt=hg19_${1}.txt
qsub_command="qsub -cwd -v PYTHONPATH=$PYTHONPATH -l s_vmem=10G -S /usr/local/package/python/3.6.5/bin/python -sync yes"
cpu=50
line=`cat $hg19_txt | wc -l`
line=$(( $line / $cpu + 1 )) 

split --additional-suffix=.split.txt -d  -l $line $hg19_txt hg19_${1}

seq -f '%02g' 0 $(( $cpu - 1 )) |  xargs -L 1 -P $cpu -I {}  $qsub_command fathmmTobed.py  "${hg19_prefix}{}.split.bed"  "${hg19_prefix}{}.split.txt"  $fasta

seq -f '%02g' 0 $(( $cpu - 1 ))  | xargs -L 1 -P $cpu -I {}  $qsub_command CrossMap.py bed $chain   "${hg19_prefix}{}.split.bed"   "${hg38_prefix}{}.split.bed"


seq -f '%02g' 0 $(( $cpu - 1 )) |  xargs -L 1 -P $cpu -I {}  $qsub_command bedTofathmm.py  "${hg38_prefix}{}.split.txt"  "${hg38_prefix}{}.split.bed"  $fasta

echo -n > "${hg38_prefix}.txt"

seq -f '%02g' 0 $(( $cpu - 1 )) |  xargs -L 1 -P $cpu -I {} $qsub_command2  sort.sh  "${hg38_prefix}{}.split.txt"  "${hg38_prefix}{}.no_sorted.txt" 

seq  0 4 |  xargs -L 1 -P 5 -I {} $qsub_command2  sort2.sh {}  `pwd` "${hg38_prefix}" ".no_sorted.txt"

sort -k 1,3 -V -T `pwd` -m `echo ${hg38_prefix}{0..4}.no_sorted.txt.tmp` > "${hg38_prefix}.txt"

line=`cat ${hg38_prefix}.txt | wc -l`
line=$(( $line / $cpu + 1 )) 

split --additional-suffix=.no_sorted.split.txt -d  -l $line ${hg38_prefix}.txt  ${hg38_prefix}

seq -f '%02g' 0 $(( $cpu - 1 ))  | xargs -L 1 -P $cpu -I {} $qsub_command  multi_index_annovar.py ${hg38_prefix} "{}"

echo -n > ${hg38_prefix}.tmp.txt.idx

for i in  `seq -f '%02g' 0 $(( $cpu - 1 ))` 
do
 cat "${hg38_prefix}${i}.no_sorted.split.txt.idx" >> "${hg38_prefix}.tmp.txt.idx"
done

sort -k 1,2 "${hg38_prefix}.tmp.txt.idx" > "${hg38_prefix}.tmp2.txt.idx"

python arrange.py   "${hg38_prefix}.txt"  "${hg38_prefix}.tmp2.txt.idx" > "${hg38_prefix}.txt.idx"

rm ${hg38_prefix}.tmp.txt.idx "${hg38_prefix}.tmp2.txt.idx"

echo -n > "${hg38_prefix}.bed.unmap"
echo -n > "${hg38_prefix}.bed"
echo -n > "${hg19_prefix}.txt"
echo -n > "${hg19_prefix}.bed"

seq -f '%02g' 0 $(( $cpu - 1 )) |  xargs -L 1 -P 1 -I {} cat "${hg38_prefix}{}.split.bed.unmap" >> "${hg38_prefix}.bed.unmap"

seq -f '%02g' 0 $(( $cpu - 1 )) |  xargs -L 1 -P 1 -I {} cat "${hg38_prefix}{}.split.bed" >> "${hg38_prefix}.bed"

seq -f '%02g' 0 $(( $cpu - 1 )) |  xargs -L 1 -P 1 -I {} cat "${hg19_prefix}{}.split.txt" >> "${hg19_prefix}.txt"

seq -f '%02g' 0 $(( $cpu - 1 )) |  xargs -L 1 -P 1 -I {} cat "${hg19_prefix}{}.split.bed" >> "${hg19_prefix}.bed"

seq -f '%02g' 0 $(( $cpu - 1 )) |  xargs -L 1 -P 1 -I {} rm "${hg19_prefix}{}.split.bed" "${hg38_prefix}{}.split.bed" "${hg38_prefix}{}.split.bed.unmap" "${hg38_prefix}{}.split.txt.idx" "${hg38_prefix}{}.split.txt" "${hg19_prefix}{}.split.txt" "${hg19_prefix}{}.split.bed" "${hg38_prefix}{}.no_sorted.txt" "${hg38_prefix}{}.no_sorted.split.txt"  "${hg38_prefix}{}.no_sorted.split.txt.idx"

rm "${hg38_prefix}.no_sorted.txt"
rm ${hg38_prefix}{0..4}.no_sorted.txt.tmp



