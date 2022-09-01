#$ -cwd
#$ -l s_vmem=10G

#1) out_dirにhg38に変換したデータベースがあると想定しています。
#2) index_annovar.txtはhttps://github.com/WGLab/doc-ANNOVAR/issues/15から
#   ダウンロードします。

data_list="
hg38_snp138.txt
hg38_snp138NonFlagged.txt
hg38_snp131NonFlagged.txt
hg38_snp131.txt
"
set -e
out_dir={データがある場所}

for data in $data_list
do
    mv $out_dir/$data $out_dir/${data}.raw.txt
    perl index_annovar.txt $out_dir/${data}.raw.txt -out $out_dir/$data -filetype B 
done

data_list="
hg38_cg69
hg38_cg46
"
set -e

for data in $data_list
do
    perl index_annovar.txt $out_dir/${data}.raw.txt -out $out_dir/$data -filetype A
done
