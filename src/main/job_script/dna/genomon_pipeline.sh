sleep $sleep_time
readonly GENOMON_VERSION="2.6.3"
sample_conf=`python -c "import os;print(os.path.splitext(os.path.basename(\"$sample_conf\"))[0])"`
sample_conf=$project_dir/config/${sample_conf}.bamimport.csv


export LOCAL=/share/pub/genomon/.genomon_local/genomon_pipeline-${GENOMON_VERSION}/local
export PYTHONHOME=${LOCAL}/python/2.7.10
export PYTHONPATH=${LOCAL}/python2.7-packages/lib/python
export PATH=${PYTHONHOME}/bin:${LOCAL}/bin:${PATH}
export LD_LIBRARY_PATH=${LOCAL}/python2.7-packages/lib:${LOCAL}/lib:${LD_LIBRARY_PATH}
export DRMAA_LIBRARY_PATH=/geadmin/N1GE/lib/lx-amd64/libdrmaa.so.1.0
export BIN_PATH=${LOCAL}/python2.7-packages/bin

set -xv
set -e
work_dir=`pwd`
cd $output_dir
cmd="${BIN_PATH}/genomon_pipeline $ruffus_option $target_pipeline $sample_conf $project_dir $genomon_conf"
echo "$cmd"
$cmd
cd $work_dir 
