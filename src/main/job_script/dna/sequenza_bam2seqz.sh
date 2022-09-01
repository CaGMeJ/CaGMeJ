sleep $sleep_time

source /etc/profile.d/modules.sh
module use /usr/local/package/modulefiles/
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$SINGULARITY_BINDPATH,/home,/share

set -xv

if [ ! $gc_file ]; then
    file_name=`basename $ref_fa`
    gc_file=${file_name%.*}.gc${window_size}Base.wig.gz
    gc_file=${output_dir}/sequenza/$gc_file
fi

tumor_file=$tumor_bam
normal_file=$normal_bam


if [ ! -e ${output_dir}/sequenza/${tumor_name}/seqz ]; then
 mkdir -p  ${output_dir}/sequenza/${tumor_name}/seqz
fi

tumor_bam_hg19=${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_${chr}.hg19
normal_bam_hg19=${output_dir}/sequenza/${normal_name}/seqz/${normal_name}_${chr}.hg19

# normal vs non_matching_normal
if [ ${normal_name} = non_matching_normal ]  ; then

    bam2seqz_option="$bam2seqz_option
                     -t  ${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_all.hg19.sorted.bam
                     -n  ${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_all.hg19.sorted.bam 
                     -n2 ${non_matching_normal_file}"
# tumor vs normal
else 

    bam2seqz_option="$bam2seqz_option
                     -t ${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_all.hg19.sorted.bam 
                     -n ${output_dir}/sequenza/${normal_name}/seqz/${normal_name}_all.hg19.sorted.bam"
fi
 

seqz_file=${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_${chr}_out.seqz.gz
seqz_small_file=${output_dir}/sequenza/${tumor_name}/seqz/${tumor_name}_${chr}_small_out.seqz.gz


singularity exec  $sequenza_utils_img sequenza-utils  bam2seqz \
                -gc ${gc_file} \
                -F ${ref_fa} \
                $bam2seqz_option \
                -C ${chr}  \
                -o ${seqz_file} || exit $?

if [ `zcat ${seqz_file} | head -2 | wc -l` = 1 ]; then
    cp  ${seqz_file} ${seqz_small_file}
    return
fi

singularity exec  $sequenza_utils_img sequenza-utils  seqz_binning \
                -w ${window_size} \
                -s ${seqz_file} \
                -o ${seqz_small_file} || exit $?

