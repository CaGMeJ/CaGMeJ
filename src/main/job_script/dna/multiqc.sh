sleep $sleep_time
module use /usr/local/package/modulefiles
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
export PYTHONNOUSERSITE=1
workdir=`pwd`
set -xv

cd $output_dir/qc
$container_bin exec $multiqc_img multiqc .

cd $workdir
