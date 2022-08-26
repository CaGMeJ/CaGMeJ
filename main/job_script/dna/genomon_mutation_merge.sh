sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$SINGULARITY_BINDPATH,/home,/share
export PYTHONNOUSERSITE=1

function genomon_mut_header () {
    normal_bam=$1
   
    mut_header=""
    if [ $normal_bam = None ]
    then
       mut_header="Chr,Start,End,Ref,Alt,depth,variantNum,bases,A_C_G_T,misRate,strandRatio,10%_posterior_quantile,posterior_mean,90%_posterior_quantile,readPairNum,variantPairNum,otherPairNum,10%_posterior_quantile(realignment),posterior_mean(realignment),90%_posterior_quantile(realignment),simple_repeat_pos,simple_repeat_seq"
    else
       mut_header="Chr,Start,End,Ref,Alt,depth_tumor,variantNum_tumor,depth_normal,variantNum_normal,bases_tumor,bases_normal,A_C_G_T_tumor,A_C_G_T_normal,misRate_tumor,strandRatio_tumor,misRate_normal,strandRatio_normal,P-value(fisher)"
       mut_header="${mut_header},readPairNum_tumor,variantPairNum_tumor,otherPairNum_tumor,readPairNum_normal,variantPairNum_normal,otherPairNum_normal,P-value(fisher_realignment),indel_mismatch_count,indel_mismatch_rate,bp_mismatch_count,distance_from_breakpoint,simple_repeat_pos,simple_repeat_seq"
    fi
    echo $mut_header
}


function print_meta_info () {
    software_versions="$@"
    info="# Version: ${software_versions}\n"
    info="$info# Analysis Date: `date`\n"
    info="$info# User: `whoami`"
    echo $info
}


#main
set -xv
set -e

if [ ! -e  ${output_dir}/mutation/${tumor_name} ]; then
    mkdir -p ${output_dir}/mutation/${tumor_name}
fi

mut_header=`genomon_mut_header $normal_bam`

print_header=""
tmp_header=`echo $mut_header | tr "," "\t"` || exit $?
if $annovar_enable
then
    for i in `ls ${output_dir}/mutation/${tumor_name}/${tumor_name}_mutations_candidate.*.${build_version}_multianno.txt`
    do
        print_header=`head -n 1 $i | sed -e "s/\tOtherinfo[0-9][0-9]//g"  -e "s/\tOtherinfo[0-9]//g"`
        break 
    done
    tmp_header=`echo "$tmp_header" | cut  -f6- ` || exit $?
    print_header=${print_header}'\t'${tmp_header}
else
    print_header=${tmp_header}
fi

software_versions="GenomonFisher-0.2.0 GenomonMutationFilter-0.2.1(modified) MutationUtil-0.5.0 GenomonMutationAnnotation-0.1.0"
 
echo -e "`print_meta_info $software_versions`
$print_header" \
> ${output_dir}/mutation/${tumor_name}/${tumor_name}.genomon_mutation.result.txt || exit $?

for interval in `cat $interval_list`
do
    REGION=$interval
    if $annovar_enable
    then
        awk 'NR>1 {print}' ${output_dir}/mutation/${tumor_name}/${tumor_name}_mutations_candidate.${REGION}.${build_version}_multianno.txt >> ${output_dir}/mutation/${tumor_name}/${tumor_name}.genomon_mutation.result.txt || exit $?
    else
        cat ${output_dir}/mutation/${tumor_name}/${tumor_name}_mutations_candidate.${REGION}.${build_version}_multianno.txt >> ${output_dir}/mutation/${tumor_name}/${tumor_name}.genomon_mutation.result.txt || exit $?
    fi
done

mutil_filter_option="-i ${output_dir}/mutation/${tumor_name}/${tumor_name}.genomon_mutation.result.txt 
                    -o ${output_dir}/mutation/${tumor_name}/${tumor_name}.genomon_mutation.result.filt.txt"

if [ $normal_bam = None ] ; then 
    mutil_filter_option="$mutil_filter_option ${mutil_single_params}" 
else
    mutil_filter_option="$mutil_filter_option ${mutil_pair_params}" 
fi

singularity exec $genomon_img mutil filter $mutil_filter_option || exit $?
