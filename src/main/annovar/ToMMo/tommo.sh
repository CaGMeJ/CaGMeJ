#$ -cwd
#$ -l s_vmem=10G

#1) index_annovar.txtはhttps://github.com/WGLab/doc-ANNOVAR/issues/15から
#   ダウンロードします。

fasta=SCRIPT_DIR/database/GRCh38/Homo_sapiens_assembly38.fasta

chain=hg19ToHg38.over.chain.gz

CrossMap.py vcf $chain  tommo-8.3kjpn-20200831-af_snvall-autosome.vcf.gz  $fasta hg38_ToMMo.vcf

python vcf2annovar.py hg38_ToMMo.vcf > hg38_ToMMo.raw.txt

perl index_annovar.txt hg38_ToMMo.raw.txt  -out hg38_ToMMo.txt -filetype A
