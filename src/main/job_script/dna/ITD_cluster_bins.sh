sleep $sleep_time
module use /usr/local/package/modulefiles
module load $container_module_file
export SINGULARITY_BINDPATH=$container_bindpath
export APPTAINER_BINDPATH=$container_bindpath

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
   $container_bin exec $itd_img samtools view -b -L $exon_bed_file $tumor_bam > $patient/global/exon_only.bam
   $container_bin exec $itd_img samtools index $patient/global/exon_only.bam
   bfile=$patient/global/exon_only.bam
fi
$container_bin exec $itd_img samtools view -b -f 4 $bfile > $patient/global/temp.bam || exit $?
$container_bin exec $itd_img bamtools convert -in $patient/global/temp.bam -format fastq > $patient/global/unused_reads.fq || exit $?
$container_bin exec $itd_img fq2fasta $patient/global/unused_reads.fq $patient/global/fq_reads.fq || exit $?
$container_bin exec $itd_img filterN $patient/global/fq_reads.fq $patient/global/N_fq_reads.fq $c || exit $?
$container_bin exec $itd_img cluster_dup_first $patient/global/N_fq_reads.fq $patient/global/cluster_N_fq_reads.txt $kmer || exit $?
$container_bin exec $itd_img python /ITD-Assembler-master/bin/extract_soft_clip.py $bfile > $patient/global/pre_sclip_reads.txt || exit $?
$container_bin exec $itd_img cluster_sclip $patient/global/pre_sclip_reads.txt $patient/global/cluster_N_fq_reads.txt || exit $?
