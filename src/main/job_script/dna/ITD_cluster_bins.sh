sleep $sleep_time
module use /usr/local/package/modulefiles
module load singularity/3.7.0
export SINGULARITY_BINDPATH=$singularity_bindpath

set -xv
if [ ! -e $output_dir/ITD/$tumor_name ]; then
    mkdir -p  $output_dir/ITD/$tumor_name
fi

patient=$output_dir/ITD/$tumor_name
bfile=$tumor_bam
c=$cluster_bins_c
kmer=$cluster_bins_pkmer
annotation_bed_file=$annotation_bed_file
exon_only=$exon_only

if [ ! -e $patient/global ]; then
   mkdir -p $patient/global
fi

if [ $exon_only ]; then
   singularity exec $itd_img samtools view -b -L $exon_bed_file $tumor_bam > $patient/global/exon_only.bam
   singularity exec $itd_img samtools index $patient/global/exon_only.bam
   bfile=$patient/global/exon_only.bam
fi
singularity exec $itd_img samtools view -b -f 4 $bfile > $patient/global/temp.bam || exit $?
singularity exec $itd_img bamtools convert -in $patient/global/temp.bam -format fastq > $patient/global/unused_reads.fq || exit $?
singularity exec $itd_img fq2fasta $patient/global/unused_reads.fq $patient/global/fq_reads.fq || exit $?
singularity exec $itd_img filterN $patient/global/fq_reads.fq $patient/global/N_fq_reads.fq $c || exit $?
singularity exec $itd_img cluster_dup_first $patient/global/N_fq_reads.fq $patient/global/cluster_N_fq_reads.txt $kmer || exit $?
singularity exec $itd_img python /ITD-Assembler-master/bin/extract_soft_clip.py $bfile > $patient/global/pre_sclip_reads.txt || exit $?
singularity exec $itd_img cluster_sclip $patient/global/pre_sclip_reads.txt $patient/global/cluster_N_fq_reads.txt || exit $?
