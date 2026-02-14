#$ -cwd
#$ -l s_vmem=10G

#1) index_annovar.txtはhttps://github.com/WGLab/doc-ANNOVAR/issues/15から
#   ダウンロードします。

python vcf2annovar.py Homo_sapiens_assembly38.dbsnp138.vcf > hg38_dbsnp138.raw.txt

perl index_annovar.txt hg38_dbsnp138.raw.txt  -out hg38_dbsnp138.txt -filetype A
