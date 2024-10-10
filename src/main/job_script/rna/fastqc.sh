sleep $sleep_time
fastqc_dir=$output_dir/qc/fastqc
output_dir=$fastqc_dir/fastqc/$sample_name

if [ ! -e $output_dir ];then
    mkdir -p $output_dir
fi

source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles/
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
set -xv
$container_bin exec $fastqc_img fastqc $fastqc_option -o $output_dir $fastq
set +xv
