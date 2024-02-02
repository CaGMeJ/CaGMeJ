sleep ${sleep_time}
set -xv
python -B ${python_dir}/strelka/strelka_add_GT.py \
    ${output_dir}/strelka/${tumor_name}_${normal_name}.strelka_work/results/variants/somatic.snvs.vcf.gz \
    > snvs.tmp.vcf
python -B ${python_dir}/strelka/strelka_add_GT.py \
    ${output_dir}/strelka/${tumor_name}_${normal_name}.strelka_work/results/variants/somatic.indels.vcf.gz \
    > indels.tmp.vcf

${annovar}/table_annovar.pl  \
   snvs.tmp.vcf \
   ${humandb} \
   --outfile   ${output_dir}/strelka/${tumor_name}_${normal_name}.strelka_work/results/variants/somatic.snvs.vcf.gz  \
   -buildver ${build_version} \
   -vcfinput ${annovar_param}

${annovar}/table_annovar.pl  \
   indels.tmp.vcf \
   ${humandb} \
   --outfile   ${output_dir}/strelka/${tumor_name}_${normal_name}.strelka_work/results/variants/somatic.indels.vcf.gz  \
   -buildver ${build_version} \
   -vcfinput ${annovar_param}

rm snvs.tmp.vcf indels.tmp.vcf
