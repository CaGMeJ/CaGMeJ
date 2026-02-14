sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles/
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
export OMP_NUM_THREADS=1
set -xv
group_name="${tumor_name}_${normal_name}"
expression_dir=${output_dir}/expression
output_dir=${expression_dir}/deseq2/${group_name}

if [ ! -e "${output_dir}" ]; then
 mkdir -p  "${output_dir}"
fi

if [ ! -e "${output_dir}/geneset" ]; then
 mkdir -p  "${output_dir}/geneset"
fi


$container_bin exec $deseq2_img bash -c "R -q --vanilla --args ${expression_dir}/htseq ${output_dir} \
                      ${geneset} \
                      ${pseudo_count} \
                      ${tumor_list} \
                      ${normal_list}  < ${R_SCRIPT}/deseq2.R" || exit $?
set +xv
 
