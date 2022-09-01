clinvar={clinvarのバージョン}
out_dir={出力先ディレクトリ}
cd {annovarのperlスクリプトのある場所}
vt decompose $out_dir/${clinvar}.vcf.gz -o $out_dir/temp.split.vcf
awk '{if(/^#/){print $0}
   else if( /^MT/){gsub( /^MT/, "M", $0 );print "chr"$0}
   else if( /^HLA/){print $0}
   else if(! /^NW/){print "chr"$0}
   }' $out_dir/temp.split.vcf > $out_dir/temp.split2.vcf
bgzip -f $out_dir/temp.split2.vcf
tabix $out_dir/temp.split2.vcf.gz
vt decompose $out_dir/temp.split2.vcf.gz -o $out_dir/temp.split3.vcf
perl prepare_annovar_user.pl   -dbtype clinvar_preprocess2 $out_dir/temp.split3.vcf -out $out_dir/temp.split4.vcf
vt normalize $out_dir/temp.split4.vcf -r {GRCh38のfastaファイル} -o $out_dir/temp.norm.vcf -w 2000000
#https://annovar.openbioinformatics.org/en/latest/user-guide/filter/から
#prepare_annovar_user.plをダウンロードして以下のように修正
#730 line: convert2annovar.pl  -> ./convert2annovar.pl
perl prepare_annovar_user.pl -dbtype clinvar2 $out_dir/temp.norm.vcf -out $out_dir/hg38_${clinvar}_raw.txt
#https://github.com/WGLab/doc-ANNOVAR/issues/15から
#index_annovar.txtをダウンロード
perl index_annovar.txt $out_dir/hg38_${clinvar}_raw.txt -out $out_dir/hg38_${clinvar}.txt -comment $out_dir/comment_${clinvar}.txt
