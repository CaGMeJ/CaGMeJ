sleep $sleep_time

set -e
set -xv
set -o pipefail
haplotype_dir=${output_dir}/haplotype/${sample_name}
source $haplotype_option_list
for interval in "${!option_list[@]}"; do
    haplotype_option="${option_list["$interval"]}"
    if [ "`echo -e "$haplotype_option" | grep "\-\-gvcf"`" ]; then
        vcf_file=${haplotype_dir}/${sample_name}.${interval}.g.vcf.gz
    else
        vcf_file=${haplotype_dir}/${sample_name}.${interval}.vcf.gz
    fi
    ${annovar}/table_annovar.pl  $vcf_file ${humandb} --outfile $vcf_file  -buildver ${build_version} -vcfinput $annovar_param

    if [ -f $vcf_file ]; then
        vcf=`gzip -dc $vcf_file | grep -v "^#"  | wc -l`
    else
        exit 1
    fi
    if [ -f ${vcf_file}.hg38_multianno.vcf ]; then
        anno_vcf=`cat ${vcf_file}.${build_version}_multianno.vcf | grep -v "^#"  | wc -l`
    else
        exit 1
    fi
    if [ $vcf != $anno_vcf ]; then
        exit 1
    fi
    if [ "`echo -e "$haplotype_option" | grep "\-\-gvcf"`" ]; then
        rm ${vcf_file}.refGene.invalid_input
        rm ${vcf_file}.invalid_input 
    fi
done
set +xv
