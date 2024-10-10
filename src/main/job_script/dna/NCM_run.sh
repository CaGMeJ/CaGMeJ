
sleep $sleep_time
module use /usr/local/package/modulefiles
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath

set -xv
output_dir=${output_dir}/ngscheckmate
if [ ! -e  ${output_dir} ]; then
 mkdir -p   ${output_dir}
fi

$container_bin exec $ngscheckmate_img python /NGSCheckMate-master/ncm.py -V     -d ${output_dir} -O ${output_dir}  -bed $NCM_bed
