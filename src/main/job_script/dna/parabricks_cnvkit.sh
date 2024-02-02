sleep $sleep_time
export PATH=/usr/local/package/python/3.6.5/bin:$PATH
source /etc/profile.d/modules.sh
module use $modulefiles
module load $parabricks_version
export SINGULARITY_BINDPATH=$singularity_bindpath
export OMP_NUM_THREADS=1
set -xv

bam_dir=${output_dir}/bam
output_dir=${output_dir}/cnvkit/${tumor_name}
ref_fa=${ref_fa}


if [ ! -e $output_dir ]; then
 mkdir -p  $output_dir
fi
 

if [ $tumor_bam = "None" ]; then
    tumor_file=${bam_dir}/${tumor_name}/${tumor_name}.markdup.bam
else
    tumor_file=$tumor_bam
fi

if $monitoring_enable ; then
     pbrun cnvkit   --tmp-dir /work/  \
                    --in-bam  $tumor_file \
                    --ref ${ref_fa} \
                    --output-dir  ${output_dir} &
     source $monitoring_script/monitoring.sh
else
     pbrun cnvkit   --tmp-dir /work/  \
                    --in-bam  $tumor_file \
                    --ref ${ref_fa} \
                    --output-dir  ${output_dir}
fi
