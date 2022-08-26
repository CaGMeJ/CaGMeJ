sleep $sleep_time
source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles/
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$SINGULARITY_BINDPATH,/home,/share

set -xv

genome_lib_dir=`dirname $genome_lib_dir`
input_dir=${output_dir}/star/${sample_name}
input_file=${input_dir}/${sample_name}.Chimeric.out.junction
output_dir=${output_dir}/fusion/${sample_name}

if [ ! -e $output_dir ]; then
 mkdir -p  $output_dir
fi


singularity exec $STAR_img  STAR-Fusion  \
                      --genome_lib_dir  ${genome_lib_dir} \
                      --chimeric_junction  ${input_file}  \
                      --output_dir  ${output_dir}  

set +xv
