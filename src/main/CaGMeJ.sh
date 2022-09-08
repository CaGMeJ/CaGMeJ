#!/bin/bash
#$ -cwd


script_dir=SCRIPT_DIR/build/main
shellscript_dir=$script_dir/shellscript

source $shellscript_dir/option_analysis.sh "$@"

if [ ! -e $output_dir ]; then
 mkdir -p  $output_dir
fi

if [ ! -e $output_dir/log ]; then
 mkdir -p  $output_dir/log
fi

output_dir=$(cd ${output_dir}; pwd)


qsub -o $output_dir/log -e $output_dir/log $qsub_option $script_dir/qsub_CaGMeJ.sh  $analysis_type  $sample_conf  $output_dir  $nextflow_conf $flag_del_tmp_dir  $flag_visual $genomon_conf "$heap_size"
