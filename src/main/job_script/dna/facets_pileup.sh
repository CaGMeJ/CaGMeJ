sleep $sleep_time
module use /usr/local/package/modulefiles
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath

set -xv
output_dir=${output_dir}/facets

if [ ! -e  ${output_dir}/$tumor_name ]; then
 mkdir -p  ${output_dir}/$tumor_name
fi

set +e
for out in `ls $output_dir/$tumor_name/${tumor_name}.${chr}.csv*`
do
    rm $out
done
set -e

$container_bin exec $facets_img /snp-pileup_region $facets_pileup_vcf $snp_pileup_option $output_dir/$tumor_name/${tumor_name}.${chr}.csv  $chr $normal_bam $tumor_bam

for csv_file in `ls $output_dir/$tumor_name/${tumor_name}.${chr}.csv*`
do
    gzip -dc $csv_file | awk '{if(split($0, a, ",") != 12){print $0;exit 1}}'
done
