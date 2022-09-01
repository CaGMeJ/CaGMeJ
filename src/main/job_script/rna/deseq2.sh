sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles/
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$SINGULARITY_BINDPATH,/home,/share
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


singularity exec $deseq2_img bash -c "R -q --vanilla --args ${expression_dir}/htseq ${output_dir} \
                      ${geneset} \
                      ${pseudo_count} \
                      ${tumor_list} \
                      ${normal_list}  < ${R_SCRIPT}/deseq2.R" || exit $?
set +xv
 
