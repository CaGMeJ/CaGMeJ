#!/bin/bash
#$ -cwd
#$ -l s_vmem=128G 

pipeline_dir=SCRIPT_DIR/build/main
tool_dir=SCRIPT_DIR/build/tool
conda_dir=SCRIPT_DIR/build/miniconda3
img_and_csv_conf=SCRIPT_DIR/build/main/config/img_and_csv.cfg
img_and_csv_conf_rna=SCRIPT_DIR/build/main/config/img_and_csv_rna.cfg
 
set -xv
set -e

target_pipeline=$1
sample_conf=$2
project_dir=$3
nextflow_parabricks_conf=$4
flag_del_tmp_dir=$5
flag_visual=$6
genomon_conf=$7
java=$8
heap_size="$9"

python_dir=$pipeline_dir/python
nextflow_dir=$pipeline_dir/nextflow
shellscript_dir=$pipeline_dir/shellscript
R_script=$pipeline_dir/R_script
monitoring_script=$pipeline_dir/monitor
fastqc_script_dir=$pipeline_dir/fastqc

phrap=$tool_dir/phrap/phrap


export NXF_OPTS="$heap_size" 

if [ $target_pipeline = "dna" ]; then

    set +xv
    eval "$(${conda_dir}/bin/conda shell.bash hook)"
    conda activate CaGMeJ
    module load $java
    set -xv

    job_script=$pipeline_dir/job_script/dna

    cd $project_dir

    python -B $python_dir/ref_fa_create.py $sample_conf  $project_dir  $nextflow_parabricks_conf|| exit $?
    

    nextflow_option="-c $nextflow_parabricks_conf 
                     -c $project_dir/config/nextflow_conf.cfg
                     -c $img_and_csv_conf
                     --genomon_conf $genomon_conf
                     --genomon_sample_conf $sample_conf 
                     --nextflow_parabricks_conf $nextflow_parabricks_conf
                     --nextflow_dir $nextflow_dir  
                     --output_dir $project_dir
                     --python_dir   $python_dir  
                     --conda_dir $conda_dir
                     --job_script $job_script
                     --monitoring_script $monitoring_script
                     --fastqc_script_dir $fastqc_script_dir
                     --R_script $R_script
                     --shellscript $shellscript_dir
                     --phrap $phrap
                     -with-report report.html -with-trace -resume"

    nextflow  run $nextflow_dir/dna_pipeline.nf $nextflow_option

    python -B $python_dir/dna_clean_up.py $project_dir $nextflow_parabricks_conf $project_dir/config/nextflow_conf.cfg

fi

if [ $target_pipeline = "rna" ]; then

    set +xv
    eval "$(${conda_dir}/bin/conda shell.bash hook)"
    conda activate CaGMeJ
    module load $java
    set -xv

    job_script=$pipeline_dir/job_script/rna

    cd $project_dir

    python -B $python_dir/rna_sample_conf.py $sample_conf  $project_dir $nextflow_parabricks_conf  || exit $?
    

    nextflow_option="--output_dir $project_dir
                     --job_script $job_script
                     --fastqc_script_dir  $fastqc_script_dir
                     -c $img_and_csv_conf_rna
                     -c $nextflow_parabricks_conf 
                     --R_SCRIPT $R_script
                     -c  $project_dir/config/nextflow_conf.cfg 
                     -with-report report.html -with-trace -resume"

    nextflow  run $nextflow_dir/rna_pipeline.nf $nextflow_option

fi

if ! $flag_visual ; then
    source $shellscript_dir/dotfile_visualization.sh $project_dir/work
fi

if $flag_del_tmp_dir ; then
    source $shellscript_dir/cleanup.sh
fi


set +xv

conda deactivate
