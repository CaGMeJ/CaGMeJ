#$ -cwd
#$ -l s_vmem=10G

#1) pythonがbiopythonとcrossmapが使えるようにパスを通したりなど準備してください>。
#2) index_annovar.txtはhttps://github.com/WGLab/doc-ANNOVAR/issues/15から
#   ダウンロードします。

fasta=SCRIPT_DIR/database/GRCh38/Homo_sapiens_assembly38.fasta

chain=hg19ToHg38.over.chain.gz

python hgvd.py DB20180529XY.tab > DB20180529XY.vcf
python hgvd.py DBexome20170802.tab > DBexome20170802.vcf

CrossMap.py vcf $chain  DBexome20170802.vcf  $fasta hg38_HGVD.vcf

CrossMap.py vcf $chain  DB20180529XY.vcf  $fasta hg38_HGVD_XY.vcf

python vcf2annovar.py hg38_HGVD.vcf hg38_HGVD.raw.txt
python vcf2annovar.py hg38_HGVD_XY.vcf hg38_HGVD_XY.raw.txt

perl index_annovar.txt hg38_HGVD.raw.txt  -out hg38_HGVD.txt -filetype A
perl index_annovar.txt hg38_HGVD_XY.raw.txt  -out hg38_HGVD_XY.txt -filetype A
