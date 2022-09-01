#$ -cwd
#$ -l s_vmem=30G

set -e

fasta=SCRIPT_DIR/database/GRCh38/Homo_sapiens_assembly38.fasta
chain=hg19ToHg38.over.chain.gz
python fathmmTobed.py hg19_${1}.bed  hg19_${1}.txt
CrossMap.py bed $chain  hg19_${1}.bed  hg38_${1}.bed
python bedTofathmm.py hg38_${1}.txt hg38_${1}.bed  $fasta
sort -k 1,3 -V hg38_${1}.txt > hg38_${1}.raw.txt
