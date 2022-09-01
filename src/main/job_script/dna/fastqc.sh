sleep $sleep_time
fastqc_dir=$output_dir/qc/fastqc
output_dir=$fastqc_dir/fastqc/$sample_name

if [ ! -e $output_dir ];then
    mkdir -p $output_dir
fi

source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles/
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$SINGULARITY_BINDPATH,/home,/share
set -xv
singularity exec $fastqc_img fastqc $fastqc_option -o $output_dir $fastq
set +xv
