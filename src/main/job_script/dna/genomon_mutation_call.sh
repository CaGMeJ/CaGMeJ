sleep $sleep_time
module use /usr/local/package/modulefiles
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath
export PYTHONNOUSERSITE=1

function fisher () {
    sub_command=$1

    if [ $sub_command = single ]; then
        $container_bin exec $genomon_img fisher single -R ${REGION} \
                       -o ${output_dir}/mutation/${tumor_name}/${tumor_name}.fisher_mutations.${REGION}.txt \
                       --ref_fa ${ref_fa} \
                       -1 ${tumor_bam} \
                       --samtools_path /usr/local/bin/samtools ${fisher_single_params} --samtools_params "`echo ${fisher_single_samtools_params}`"

    else if [ $sub_command = comparison ]; then
        $container_bin exec $genomon_img fisher comparison -R ${REGION} \
                       -o ${output_dir}//mutation/${tumor_name}/${tumor_name}.fisher_mutations.${REGION}.txt \
                       --ref_fa ${ref_fa} \
                       -2 ${normal_bam} \
                       -1 ${tumor_bam} \
                       --samtools_path /usr/local/bin/samtools  ${fisher_pair_params} --samtools_params "`echo ${fisher_pair_samtools_params}`"
    fi
    fi
}

function mutfilter () {
    sub_command=$1

    if [ $sub_command = realignment ]; then
        input_prefix=$2
        set +u
        option=$3
        set -u

        $container_bin exec $genomon_img mutfilter realignment --target_mutation_file ${output_dir}/mutation/${tumor_name}/${tumor_name}.fisher_${input_prefix}.${REGION}.txt \
                           -1 ${tumor_bam} \
                           $option \
                           --output ${output_dir}/mutation/${tumor_name}/${tumor_name}.realignment_mutations.${REGION}.txt \
                           --ref_genome ${ref_fa} \
                           --blat_path /usr/local/bin/blat ${mutfilter_realignment_params}
        #rm ${output_dir}/mutation/${tumor_name}/${tumor_name}.fisher_${input_prefix}.${REGION}.txt 
    else if [ $sub_command = simplerepeat ]; then
        input_prefix=$2

        $container_bin exec $genomon_img mutfilter simplerepeat --target_mutation_file ${output_dir}/mutation/${tumor_name}/${tumor_name}.${input_prefix}.${REGION}.txt \
                 --output ${output_dir}/mutation/${tumor_name}/${tumor_name}.simplerepeat_mutations.${REGION}.txt \
                 --simple_repeat_db ${simple_repeat_db}
        #rm  ${output_dir}/mutation/${tumor_name}/${tumor_name}.${input_prefix}.${REGION}.txt
    else if [ $sub_command = indel ]; then
        $container_bin exec $genomon_img mutfilter indel --target_mutation_file ${output_dir}/mutation/${tumor_name}/${tumor_name}.realignment_mutations.${REGION}.txt \
                      -2 ${normal_bam} \
                      --output ${output_dir}/mutation/${tumor_name}/${tumor_name}.indel_mutations.${REGION}.txt\
                      --samtools_path  /usr/local/bin/samtools ${mutfilter_indel_params} --samtools_params "`echo ${mutfilter_indel_samtools_params}`"
        #rm ${output_dir}/mutation/${tumor_name}/${tumor_name}.realignment_mutations.${REGION}.txt 
    else if [ $sub_command = breakpoint ]; then
        $container_bin exec $genomon_img mutfilter breakpoint --target_mutation_file ${output_dir}/mutation/${tumor_name}/${tumor_name}.indel_mutations.${REGION}.txt \
                               -2 ${normal_bam} \
                               --output ${output_dir}/mutation/${tumor_name}/${tumor_name}.breakpoint_mutations.${REGION}.txt ${mutfilter_breakpoint_params} 
        #rm ${output_dir}/mutation/${tumor_name}/${tumor_name}.indel_mutations.${REGION}.txt
    fi
    fi
    fi
    fi

}


#main
set -xv
set -e

if [ ! -e ${output_dir}/mutation/${tumor_name}/ ]; then
    mkdir -p ${output_dir}/mutation/${tumor_name}/
fi

if [ ${normal_bam} = None ]; then 
    fisher single 

    mutfilter realignment mutations

    mutfilter simplerepeat realignment_mutations

else
    fisher comparison 

    #mutfilter realignment mutations "-2 ${normal_bam}"
    in_mutation_file=${output_dir}/mutation/${tumor_name}/${tumor_name}.fisher_mutations.${REGION}.txt
    sort -k2n $in_mutation_file  > ${in_mutation_file}.sorted
    $container_bin exec $mutfilter_img python3 $python_dir/mutfilter/mutfilter_realignment.py  \
               ${in_mutation_file}.sorted \
               $tumor_bam \
               $normal_bam \
               $ref_fa \
               $read_length \
               $window \
               $exclude_sam_flags > ${output_dir}/mutation/${tumor_name}/${tumor_name}.realignment_mutations.${REGION}.txt
    rm ${in_mutation_file}.sorted

    mutfilter indel 

    mutfilter breakpoint

    mutfilter simplerepeat breakpoint_mutations
fi

