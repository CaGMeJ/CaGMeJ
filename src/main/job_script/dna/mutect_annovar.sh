sleep $sleep_time

set -e
set -xv
set -o pipefail
sample_name=$tumor_name

${annovar}/table_annovar.pl  ${output_dir}/mutect/${sample_name}/${sample_name}.mutect.vcf.gz ${humandb} --outfile   ${output_dir}/mutect/${sample_name}/${sample_name}.mutect.vcf.gz  -buildver ${build_version} -vcfinput $annovar_param

vcf_file=${output_dir}/mutect/${sample_name}/${sample_name}.mutect.vcf.gz
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

set +xv
