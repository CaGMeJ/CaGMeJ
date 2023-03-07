
sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=/cshare1,/home,/share
export PYTHONNOUSERSITE=1
set -xv

if [ ! -e  ${output_dir}/genomon_fusion ]; then
    mkdir -p    ${output_dir}/genomon_fusion
fi

chimeric_out_sam_file=`echo $bam_file | sed -e "s/Aligned.sortedByCoord.out.bam/Chimeric.out.sam/g"`

singularity exec $genomon_rna_img fusionfusion \
    --star $chimeric_out_sam_file \
    --out  ${output_dir}/genomon_fusion/$sample_name \
    --reference_genome $ref_fa \
    $fusionfusion_option \
    --refGene_bed $refGene_bed \
    --ensGene_bed $ensGene_bed \
    --refExon_bed $refExon_bed \
    --ensExon_bed $ensExon_bed 

mv ${output_dir}/genomon_fusion/$sample_name/star.fusion.result.txt ${output_dir}/genomon_fusion/$sample_name/${sample_name}.star.fusion.result.txt 
mv ${output_dir}/genomon_fusion/$sample_name/fusion_fusion.result.txt ${output_dir}/genomon_fusion/$sample_name/${sample_name}.genomonFusion.result.txt 

singularity exec $genomon_rna_img fusion_utils filt \
    ${output_dir}/genomon_fusion/$sample_name/${sample_name}.genomonFusion.result.txt \
    ${output_dir}/genomon_fusion/$sample_name/${sample_name}.fusion.fusion.result.filt.txt \
    $fusion_utils_filt_option \
    --refGene_bed $refGene_bed \
    --ensGene_bed $ensGene_bed \
    --refExon_bed $refExon_bed \
    --ensExon_bed $ensExon_bed 

mv ${output_dir}/genomon_fusion/$sample_name/${sample_name}.fusion.fusion.result.filt.txt ${output_dir}/genomon_fusion/$sample_name/${sample_name}.genomonFusion.result.filt.txt
