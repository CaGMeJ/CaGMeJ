sleep $sleep_time
export PATH=/usr/local/package/python/3.6.5/bin:$PATH
source /etc/profile.d/modules.sh
module use $modulefiles
module load $parabricks_version
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
set -xv

haplotype_dir=${output_dir}/haplotype/${sample_name}
bam_dir=${output_dir}/haplotype/${sample_name}

source $haplotype_option_list

if [ ! -e $haplotype_dir ]; then
 mkdir -p  $haplotype_dir
fi

for interval in "${!option_list[@]}"; do
    haplotype_option="${option_list["$interval"]}"
    if [ "`echo -e "$haplotype_option" | grep "\-\-gvcf"`" ]; then
        vcf_file=${haplotype_dir}/${sample_name}.${interval}.g.vcf
    else
        vcf_file=${haplotype_dir}/${sample_name}.${interval}.vcf
    fi

    if $monitoring_enable ; then
        pbrun haplotypecaller   --tmp-dir /work  \
                                --ref ${ref_fa} \
                                 --in-bam $sample_bam \
                                ${haplotype_option} \
                                --out-variants $vcf_file &
        source $monitoring_script/monitoring.sh
    else
        pbrun haplotypecaller   --tmp-dir /work  \
                                --ref ${ref_fa} \
                                --in-bam $sample_bam \
                                ${haplotype_option} \
                                --out-variants $vcf_file 
    fi
    $parabricks_container_bin exec $tabix_img bgzip -f $vcf_file
    $parabricks_container_bin exec $tabix_img tabix -f -p vcf ${vcf_file}.gz
    md5sum  ${vcf_file}.gz >  ${vcf_file}.gz.md5
    md5sum  ${vcf_file}.gz.tbi >  ${vcf_file}.gz.tbi.md5
done
