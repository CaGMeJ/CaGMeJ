#$ -cwd
#$ -l s_vmem=10G

#index_annovar.txtはhttps://github.com/WGLab/doc-ANNOVAR/issues/15からダウンロードします。
#tumorportal.pyと同じディレクトリにmafファイルがあることを想定しています。
python tumorportal.py > tumorportal.txt

set -e
fasta=/home/kks_th/CaGMeJ/1.1.0/database/GRCh38/Homo_sapiens_assembly38.fasta
chain=hg19ToHg38.over.chain.gz
python fathmmTobed.py hg19_tumorportal.bed  tumorportal.txt
CrossMap.py bed $chain  hg19_tumorportal.bed    hg38_tumorportal.bed 

python bedTofathmm.py hg38_tumorportal.raw.txt hg38_tumorportal.bed  $fasta
perl index_annovar.txt hg38_tumorportal.raw.txt -out hg38_tumorportal.txt -filetype A
