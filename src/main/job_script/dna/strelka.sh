sleep ${sleep_time}
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
set -xv
set -e

if [ -e ${output_dir}/strelka/${tumor_name}_${normal_name}.strelka_work ]; then
    rm -r  ${output_dir}/strelka/${tumor_name}_${normal_name}.strelka_work 
fi

mkdir -p ${output_dir}/strelka

$container_bin exec $strelka_img python2 /strelka-2.9.10.centos6_x86_64/bin/configureStrelkaSomaticWorkflow.py \
    --normalBam  ${normal_bam}  \
    --tumorBam ${tumor_bam}  \
    --referenceFasta $ref_fa \
    --runDir  ${output_dir}/strelka/${tumor_name}_${normal_name}.strelka_work \
    --indelCandidates $output_dir/manta/somatic/${tumor_name}_${normal_name}/results/variants/candidateSmallIndels.vcf.gz \
    ${strelka_configure_option}

$container_bin exec $strelka_img python2 ${output_dir}/strelka/${tumor_name}_${normal_name}.strelka_work/runWorkflow.py ${strelka_run_option}
