#$ -cwd
#$ -l s_vmem=10G

set -e

fasta=SCRIPT_DIR/database/GRCh38/Homo_sapiens_assembly38.fasta
chain=hg19ToHg38.over.chain.gz
python tfbTobed.py hg19_${1}.bed  hg19_${1}.txt
CrossMap.py bed $chain  hg19_${1}.bed  hg38_${1}.bed
python bedTotfb.py hg38_${1}.txt hg38_${1}.bed 
