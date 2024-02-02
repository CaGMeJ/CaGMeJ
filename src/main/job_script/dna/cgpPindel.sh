sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$singularity_bindpath
set -xv
set -e

out_dir=$output_dir/cgppindel/${tumor_name}

if [ -e $out_dir ]; then
    rm -r  $out_dir
fi
mkdir -p $out_dir

MT_NAME=$tumor_name
WT_NAME=$normal_name

singularity exec $cgpPindel_img \
        pindel.pl -o $out_dir \
        -r $ref_fa \
        -t $tumor_bam \
        -n $normal_bam \
        $pindel_option

singularity exec $cgpPindel_img \
       FlagVcf.pl -i $out_dir/${MT_NAME}_vs_${WT_NAME}.vcf.gz \
                  -o $out_dir/${MT_NAME}_vs_${WT_NAME}.pindel.flagged.vcf \
                  $FlagVcf_option

singularity exec $cgpPindel_img \
        bgzip -f $out_dir/${MT_NAME}_vs_${WT_NAME}.pindel.flagged.vcf

singularity exec $cgpPindel_img \
        tabix -f -p vcf $out_dir/${MT_NAME}_vs_${WT_NAME}.pindel.flagged.vcf.gz 
