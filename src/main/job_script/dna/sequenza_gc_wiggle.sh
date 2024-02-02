sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles/
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$singularity_bindpath

set -xv
file_name=`basename $ref_fa`
gc_file=${file_name%.*}.gc${window_size}Base.wig.gz 

output_dir=${output_dir}/sequenza

if [ ! -e "${output_dir}" ]; then
 mkdir -p  "${output_dir}"
fi

cp $ref_fa ${output_dir}

singularity exec $sequenza_utils_img sequenza-utils  gc_wiggle -w ${window_size} -f  ${output_dir}/${file_name} -o  ${output_dir}/${gc_file}


