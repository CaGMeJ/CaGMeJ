sleep $sleep_time
export PATH=/usr/local/package/python/3.6.5/bin:$PATH
source /etc/profile.d/modules.sh
module use $modulefiles
module load $parabricks_version
export SINGULARITY_BINDPATH=/cshare1,/home,/share

set -xv

bam_dir=${output_dir}/bam
output_dir=${output_dir}/deepvariant/${sample_name}

if [ ! -e $output_dir ]; then
 mkdir -p  $output_dir
fi


if $monitoring_enable ; then
    pbrun deepvariant   --tmp-dir /work/  \
                        --in-bam  $bam_file \
                        --ref ${ref_fa} \
                        --out-variants  ${output_dir}/${sample_name}.deepvariant.vcf &
    source $monitoring_script/monitoring.sh
else
    pbrun deepvariant   --tmp-dir /work/  \
                         --in-bam  $bam_file \
                         --ref ${ref_fa} \
                         --out-variants  ${output_dir}/${sample_name}.deepvariant.vcf
fi

singularity exec $tabix_img bgzip -f  ${output_dir}/${sample_name}.deepvariant.vcf
singularity exec $tabix_img tabix -f -p vcf  ${output_dir}/${sample_name}.deepvariant.vcf.gz

set +xv
