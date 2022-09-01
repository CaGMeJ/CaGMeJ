sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$SINGULARITY_BINDPATH,/home,/share
export PYTHONNOUSERSITE=1
workdir=`pwd`
set -xv

cd $output_dir/qc
singularity exec $multiqc_img multiqc .

cd $workdir
