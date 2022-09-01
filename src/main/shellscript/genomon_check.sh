GENOMON_VERSION=2.6.3
export LOCAL=/share/pub/genomon/.genomon_local/genomon_pipeline-${GENOMON_VERSION}/local
export PYTHONHOME=${LOCAL}/python/2.7.10
export PYTHONPATH=${LOCAL}/python2.7-packages/lib/python
export PATH=${PYTHONHOME}/bin:${LOCAL}/bin:${PATH}
export LD_LIBRARY_PATH=${LOCAL}/python2.7-packages/lib:${LOCAL}/lib:${LD_LIBRARY_PATH}
export DRMAA_LIBRARY_PATH=/geadmin/N1GE/lib/lx-amd64/libdrmaa.so.1.0
export BIN_PATH=${LOCAL}/python2.7-packages/bin
echo "Genomon is checking parameters ..."
${BIN_PATH}/genomon_pipeline --param_check $analysis_type $sample_conf $output_dir $genomon_conf || exit $?
echo "Parameters check is complete." 
