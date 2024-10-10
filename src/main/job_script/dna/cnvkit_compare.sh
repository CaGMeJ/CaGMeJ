sleep $sleep_time
module use /usr/local/package/modulefiles
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath

set -xv
set -e
output_dir=${output_dir}/cnvkit_compare/$tumor_name 
cwd=`pwd`
if [ ! -e  ${output_dir} ]; then
 mkdir -p  ${output_dir}
fi
cd ${output_dir}

male_reference="--male-reference $male_reference_flag"

$container_bin exec $cnvkit_img cnvkit.py \
            batch \
            $tumor_bam \
            --normal ${normal_bam} \
            --fasta $ref_fa \
            $male_reference \
            $cnvkit_compare_option \
            --output-dir ${output_dir}
pre_T=`basename $tumor_bam`
pre_T=${output_dir}/${pre_T%.bam}
pre_N=`basename $normal_bam`
pre_N=${output_dir}/${pre_N%.bam}
for suffix in antitargetcoverage.cnn targetcoverage.cnn
do
    for pre in ${pre_T} ${pre_N}
    do
        if [ ! -s ${pre}.${suffix} ]; then
            exit 1
        fi
    done
done
if [ ! -s ${output_dir}/reference.cnn ]; then
    exit 1
fi 
if [ ! -s ${pre_T}.cnr ]; then
    exit 1
fi

if [ `cat ${pre_T}.cnr | wc -l` -gt 1 ]; then

    if [ ! -s ${pre_T}.cns ]; then
        exit 1
    fi

    head -n 1  ${pre_T}.cnr > ${output_dir}/${tumor_name}.cnr
    head -n 1  ${pre_T}.cns > ${output_dir}/${tumor_name}.cns

    grep $grep_option   ${pre_T}.cnr >>  ${output_dir}/${tumor_name}.cnr
    grep $grep_option  ${pre_T}.cns >> ${output_dir}/${tumor_name}.cns

    $container_bin exec $cnvkit_img cnvkit.py scatter  -s ${output_dir}/${tumor_name}.cn{s,r} -o ${output_dir}/${tumor_name}-scatter.png

    sex_reference=
    if [ "$male_reference_flag" = N ]; then
        if [ `cat is_male_reference.txt` = True ]; then
            sex_reference="--male-reference"
        fi
    fi
    if [ "$male_reference_flag" = T ]; then
        sex_reference="--male-reference"
    fi
    $container_bin exec $cnvkit_img cnvkit.py diagram $sex_reference -s ${output_dir}/${tumor_name}.cn{s,r} -o ${output_dir}/${tumor_name}-diagram.pdf  

    $container_bin exec $cnvkit_img cnvkit.py export vcf $sex_reference ${output_dir}/${tumor_name}.markdup.cns ${cnvkit_export_option}  -o ${output_dir}/${tumor_name}.markdup.cns.vcf

    rm ${output_dir}/${tumor_name}.cns
    rm ${output_dir}/${tumor_name}.cnr
    
    if [ ! -s ${pre_T}.bintest.cns ]; then
        exit 1
    fi
    
fi
cd $cwd
