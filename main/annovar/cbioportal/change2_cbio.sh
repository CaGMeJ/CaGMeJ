#$ -cwd
#$ -l s_vmem=30G

set -e
fasta=SCRIPT_DIR/database/GRCh38/Homo_sapiens_assembly38.fasta
chain=hg19ToHg38.over.chain.gz
python fathmmTobed.py hg19_${1}.bed  hg19_${1}.txt
CrossMap.py bed $chain  hg19_${1}.bed  hg38_${1}.bed
python bedTofathmm.py hg38_${1}.raw.txt hg38_${1}.bed  $fasta
perl index_annovar.txt hg38_${1}.raw.txt -out hg38_${1}.txt -filetype A
