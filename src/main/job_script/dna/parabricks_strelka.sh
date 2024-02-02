sleep ${sleep_time}
source /etc/profile.d/modules.sh
module use $modulefiles
module load $parabricks_version
set -xv

if [ -e ${output_dir}/strelka/${tumor_name}_${normal_name}.strelka_work ]; then
    rm -r  ${output_dir}/strelka/${tumor_name}_${normal_name}.strelka_work 
fi

mkdir -p ${output_dir}/strelka


pbrun strelka --ref  ${ref_fa}  \
              --in-tumor-bam ${tumor_bam} \
              --in-normal-bam ${normal_bam} \
              --indel-candidates $output_dir/manta/somatic/${tumor_name}_${normal_name}/results/variants/candidateSmallIndels.vcf.gz \
              --out-prefix  ${output_dir}/strelka/${tumor_name}_${normal_name}  \
              ${parabricks_strelka_option}


