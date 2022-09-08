sleep $sleep_time
export PATH=/usr/local/package/python/3.6.5/bin:$PATH
source /etc/profile.d/modules.sh
module use /opt/parabricks/modulefiles/
module load parabricks_pipeline/$parabricks_version
export SINGULARITY_BINDPATH=/cshare1,/home,/share

set -xv

bam_dir=${output_dir}/bam
mutect_dir=${output_dir}/mutect
output_dir=${mutect_dir}/${tumor_name}
sample_name=$tumor_name


if [ ! -e $output_dir ]; then
 mkdir -p  $output_dir
fi



tumor_file=${bam_dir}/${tumor_name}/${tumor_name}.markdup.bam
if [ ! $tumor_bam = $tumor_file ]; then
    tumor_file=$tumor_bam
    tumor_name=`singularity exec $samtools_img samtools view -H $tumor_file  | grep '^@RG' | awk '{for (i=1; i<=NF; i++) if($i ~ "SM:" )printf(substr($i,4) "\n")}' | sort | uniq `
else
    tumor_name=`singularity exec $samtools_img samtools view -H $tumor_file  | grep '^@RG' | awk '{for (i=1; i<=NF; i++) if($i ~ "SM:" )printf(substr($i,4) "\n")}' | sort | uniq `
fi

normal_file=${bam_dir}/${normal_name}/${normal_name}.markdup.bam
if [ ! $normal_bam = $normal_file ]; then
    normal_file=$normal_bam
    normal_name=`singularity exec $samtools_img samtools view -H $normal_file  | grep '^@RG' | awk '{for (i=1; i<=NF; i++) if($i ~ "SM:" )printf(substr($i,4) "\n")}' | sort | uniq`
else
    normal_name=`singularity exec $samtools_img samtools view -H $normal_file  | grep '^@RG' | awk '{for (i=1; i<=NF; i++) if($i ~ "SM:" )printf(substr($i,4) "\n")}' | sort | uniq`
fi

if $monitoring_enable ; then
    pbrun mutectcaller   --tmp-dir /work  \
                         --in-tumor-bam $tumor_file \
                         --in-normal-bam $normal_file \
                         --tumor-name ${tumor_name} \
                         --normal-name ${normal_name} \
                         --ref ${ref_fa} \
                         --out-vcf ${output_dir}/${sample_name}.mutect.vcf &
    source $monitoring_script/monitoring.sh
else
   pbrun mutectcaller   --tmp-dir /work  \
                         --in-tumor-bam $tumor_file \
                         --in-normal-bam $normal_file \
                         --tumor-name ${tumor_name} \
                         --normal-name ${normal_name} \
                         --ref ${ref_fa} \
                         --out-vcf ${output_dir}/${sample_name}.mutect.vcf
fi

singularity exec $tabix_img bgzip -f ${output_dir}/${sample_name}.mutect.vcf
singularity exec $tabix_img tabix -f -p vcf ${output_dir}/${sample_name}.mutect.vcf.gz

export JAVA_TOOL_OPTIONS="-XX:+UseSerialGC -Xmx2g -Xms32m" 
singularity exec $gatk_img /gatk-4.1.0.0/gatk FilterMutectCalls \
    -O ${output_dir}/${sample_name}.mutect.filtered.vcf.gz \
    -R  $ref_fa \
    -V ${output_dir}/${sample_name}.mutect.vcf.gz

set +xv
