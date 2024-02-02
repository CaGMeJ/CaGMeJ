sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$singularity_bindpath

set -xv
if [ `cat ${output_dir}/facets/$tumor_name/${tumor_name}.out.purity.tsv | wc -l` -gt 2 ]; then
    exit 1
fi
purity=`awk -F "," 'NR>1{print $2}' ${output_dir}/facets/$tumor_name/${tumor_name}.out.purity.tsv`
output_dir=${output_dir}/cnvkit_compare/$tumor_name 
cwd=`pwd`
if [ ! -e  ${output_dir} ]; then
 mkdir -p  ${output_dir}
fi
cd ${output_dir}

if [ `cat ${output_dir}/${tumor_name}.markdup.cnr | wc -l` -gt 1 ]; then
    purity=`python -c "print('{:.3f}'.format($purity))"`
    sex_reference=
    if [ "$male_reference_flag" = N ]; then
        if [ `cat is_male_reference.txt` = True ]; then
            sex_reference="--male-reference"
        fi
    fi
    if [ "$male_reference_flag" = T ]; then
        sex_reference="--male-reference"
    fi
    singularity  exec $cnvkit_img cnvkit.py call \
        ${output_dir}/${tumor_name}.markdup.cns \
        $sex_reference \
        -m clonal \
        --purity $purity \
        -o ${output_dir}/${tumor_name}.purity_calibrated.call.cns

    head -n 1  ${output_dir}/${tumor_name}.markdup.cnr > ${output_dir}/${tumor_name}.cnr
    head -n 1  ${output_dir}/${tumor_name}.purity_calibrated.call.cns > ${output_dir}/${tumor_name}.cns

    grep $grep_option   ${output_dir}/${tumor_name}.markdup.cnr >>  ${output_dir}/${tumor_name}.cnr
    grep $grep_option  ${output_dir}/${tumor_name}.purity_calibrated.call.cns >> ${output_dir}/${tumor_name}.cns

    singularity exec $cnvkit_img cnvkit.py scatter  -s ${output_dir}/${tumor_name}.cn{s,r} -o ${output_dir}/${tumor_name}-scatter_purity_calibrated.png
 
    singularity exec $cnvkit_img cnvkit.py diagram $sex_reference -s ${output_dir}/${tumor_name}.cn{s,r} -o ${output_dir}/${tumor_name}-diagram_purity_calibrated.pdf  

    singularity exec $cnvkit_img cnvkit.py export vcf $sex_reference ${output_dir}/${tumor_name}.purity_calibrated.call.cns ${cnvkit_export_option}  -o ${output_dir}/${tumor_name}.purity_calibrated.call.cns.vcf

    rm ${output_dir}/${tumor_name}.cns
    rm ${output_dir}/${tumor_name}.cnr
fi
cd $cwd
