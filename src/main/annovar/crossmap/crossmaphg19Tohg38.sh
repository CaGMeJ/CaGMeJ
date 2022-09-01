#$ -cwd
#$ -l s_vmem=10G

#1) change1.sh,change2.sh,change3.shスクリプト内の
#   hg19_${1}.txtが変換するhg19のデータベースのパスです。
#2) pythonがbiopythonとcrossmapが使えるようにパスを通したりなど準備してください>。
#3) 引数にデータベース名(snp131など)を設定して使うことを想定しています。

set -e 

fasta=/home/kks_th/CaGMeJ/1.1.0/database/GRCh38/Homo_sapiens_assembly38.fasta
chain=hg19ToHg38.over.chain.gz

data_list="
snp131
snp138
snp131NonFlagged
snp138NonFlagged
"

for i in $data_list
do
   qsub change1.sh $i 
done

data_list="
cg46
cg69
"
for i in $data_list
do
   qsub change2.sh $i
done

data_list="
tfbsConsSites
targetScanS
"
for i in $data_list
do
   qsub change3.sh $i
done
