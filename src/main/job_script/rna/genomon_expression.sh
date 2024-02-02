
sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$singularity_bindpath
export PYTHONNOUSERSITE=1
set -xv

if [ ! -e  ${output_dir}/genomon_expression ]; then
    mkdir -p    ${output_dir}/genomon_expression
fi

singularity exec $genomon_rna_img genomon_expression \
     $genomon_expression_option \
     --refExon_bed $refExon_ex_bed \
     $bam_file  \
     ${output_dir}/genomon_expression/$sample_name/$sample_name

mv ${output_dir}/genomon_expression/$sample_name/${sample_name}.sym2fpkm.txt ${output_dir}/genomon_expression/$sample_name/${sample_name}.genomonExpression.result.txt 
