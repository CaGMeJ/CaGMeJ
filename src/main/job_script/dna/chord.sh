sleep $sleep_time
module use /usr/local/package/modulefiles
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
export R_LIBS_USER='-'
set -xv
set +e

if [ ! -e $output_dir/chord/$sample_name  ]; then
    mkdir -p $output_dir/chord/$sample_name 
fi

mutect_vcf=$output_dir/mutect/$sample_name/${sample_name}.mutect.filtered.vcf.gz
gridss_vcf=$output_dir/gridss/$sample_name/${sample_name}.high_and_low_confidence_somatic.gridss.vcf.bgz

$container_bin exec $tabix_img  tabix -H $mutect_vcf  > tmp.mutect.vcf
for id in $chord_chr_list
do
    $container_bin exec $tabix_img  tabix $mutect_vcf ${id}  | grep PASS   >> tmp.mutect.vcf
done

$container_bin exec $tabix_img tabix -H $gridss_vcf  > tmp.gridss.vcf
for id in $chord_chr_list
do
    $container_bin exec $tabix_img  tabix  $gridss_vcf  ${id} | grep PASS   >> tmp.gridss.vcf
done
set -e
$container_bin exec $chord_img Rscript $R_script/chord/chord.R \
                 $sample_name \
                 tmp.mutect.vcf \
                 tmp.gridss.vcf \
                 $output_dir/chord

rm tmp.mutect.vcf tmp.gridss.vcf 
