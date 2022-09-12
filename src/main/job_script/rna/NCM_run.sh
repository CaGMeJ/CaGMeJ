
sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=/cshare1,/home,/share

set -xv
output_dir=${output_dir}/ngscheckmate
if [ ! -e  ${output_dir} ]; then
 mkdir -p   ${output_dir}
fi

singularity exec $ngscheckmate_img python /NGSCheckMate-master/ncm.py -V     -d ${output_dir} -O ${output_dir}  -bed $NCM_bed
