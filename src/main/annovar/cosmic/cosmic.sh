#https://annovar.openbioinformatics.org/en/latest/user-guide/filter/から
#prepare_annovar_user.plをダウンロードして以下のように修正
#730 line: convert2annovar.pl  -> ./convert2annovar.pl
#index_annovar.txtはhttps://github.com/WGLab/doc-ANNOVAR/issues/15からダウンロードします。
perl prepare_annovar_user.pl -dbtype cosmic CosmicMutantExport.tsv -vcf CosmicCodingMuts.normal.vcf > hg38_cosmic94_coding.raw.txt
perl prepare_annovar_user.pl -dbtype cosmic CosmicNCV.tsv -vcf CosmicNonCodingVariants.normal.vcf > hg38_cosmic94_noncoding.raw.txt

perl index_annovar.txt  hg38_cosmic94_coding.raw.txt  -out  hg38_cosmic94_coding.txt -filetype A
perl index_annovar.txt  hg38_cosmic94_noncoding.raw.txt  -out  hg38_cosmic94_noncoding.txt -filetype A
