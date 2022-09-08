#$ -cwd
#$ -l s_vmem=5G

output_dir=humandb

DATABASE_LIST="
ljb26_all
cosmic70
esp6500siv2_all
avsnp150
exac03
exac03nontcga
exac03nonpsych
gnomad_exome
gnomad_genome
mcap
revel
kaviar_20150923
gme
dbscsnv11
refGene
icgc28
hrcr1
intervar_20180118
"

for DATABASE in $DATABASE_LIST
do
  ./annotate_variation.pl -buildver hg38 -downdb -webfrom annovar $DATABASE $output_dir
done


DATABASE_LIST="
refGene
cytoBand
genomicSuperDups
wgRna
1000g2015aug
"


for DATABASE in $DATABASE_LIST
do
 ./annotate_variation.pl -buildver hg38 -downdb $DATABASE $output_dir
done

DATABASE_LIST="
tfbsConsSites
targetScanS
"
for DATABASE in $DATABASE_LIST
do
  ./annotate_variation.pl -buildver hg19 -downdb $DATABASE $output_dir
done

DATABASE_LIST="
eigen
cg46
cg69
fathmm
snp131
snp138
snp131NonFlagged
snp138NonFlagged
"
for DATABASE in $DATABASE_LIST
do
  ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar $DATABASE $output_dir
done
