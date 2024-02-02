sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$singularity_bindpath
export PYTHONNOUSERSITE=1

function print_meta_info () {
    software_versions="$@"
    info="# Version: ${software_versions}\n"
    info="${info}# Analysis Date: `date`\n"
    info="${info}# User: `whoami`"
    echo $info
}

set -xv
set -e

if [ ! -e  ${output_dir}/sv/${tumor_name} ]; then
    mkdir -p ${output_dir}/sv/${tumor_name}
fi

singularity exec $genomon_img GenomonSV parse \
                ${tumor_bam} \
                ${output_dir}/sv/${tumor_name}/${tumor_name} \
                ${genomon_sv_parse_param} || exit $?

if [ $normal_name != None ]; then
     genomon_sv_filt_param="$genomon_sv_filt_param --matched_control_bam $normal_bam"
fi

singularity exec $genomon_img GenomonSV filt \
                 ${tumor_bam} \
                 ${output_dir}/sv/${tumor_name}/${tumor_name} \
                 ${ref_fa} \
                 ${genomon_sv_filt_param} || exit $?

mv  ${output_dir}/sv/${tumor_name}/${tumor_name}.genomonSV.result.txt  ${output_dir}/sv/${tumor_name}/${tumor_name}.genomonSV.result.txt.tmp || exit $?

software_versions="GenomonSV-0.6.1b1(modified) sv_utils-0.5.1(modified)"
echo -e "`print_meta_info $software_versions`" >  ${output_dir}/sv/${tumor_name}/${tumor_name}.genomonSV.result.txt || exit $?

cat  ${output_dir}/sv/${tumor_name}/${tumor_name}.genomonSV.result.txt.tmp >>  ${output_dir}/sv/${tumor_name}/${tumor_name}.genomonSV.result.txt || exit $?

rm -rf  ${output_dir}/sv/${tumor_name}/${tumor_name}.genomonSV.result.txt.tmp
 
singularity exec $genomon_img sv_utils filter \
            ${output_dir}/sv/${tumor_name}/${tumor_name}.genomonSV.result.txt \
            ${output_dir}/sv/${tumor_name}/${tumor_name}.genomonSV.result.filt.txt.tmp \
            ${sv_utils_param} || exit $?

mv  ${output_dir}/sv/${tumor_name}/${tumor_name}.genomonSV.result.filt.txt.tmp  ${output_dir}/sv/${tumor_name}/${tumor_name}.genomonSV.result.filt.txt
